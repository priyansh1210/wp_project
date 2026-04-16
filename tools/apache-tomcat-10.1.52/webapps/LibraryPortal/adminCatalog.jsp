<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("login.jsp?role=admin&error=Please login first");
        return;
    }
    String msg = request.getParameter("msg");
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
        Statement st = conn.createStatement();

        // Count pending return requests for tab badge
        ResultSet rsCount = st.executeQuery("SELECT COUNT(*) AS cnt FROM borrow_history WHERE status='RETURN_PENDING'");
        int pendingCount = 0;
        if (rsCount.next()) pendingCount = rsCount.getInt("cnt");
        rsCount.close();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Catalog</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="catalog"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <!-- Tabs -->
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:24px;">
                <div class="tab-buttons">
                    <button class="tab-btn active" data-tab-group="catalog" data-tab-target="returnReqPanel">Return Requests<% if (pendingCount > 0) { %> <span style="background:#e67e00;color:#fff;padding:1px 7px;border-radius:10px;font-size:11px;margin-left:4px"><%= pendingCount %></span><% } %></button>
                    <button class="tab-btn" data-tab-group="catalog" data-tab-target="borrowedPanel">Borrowed Books</button>
                    <button class="tab-btn" data-tab-group="catalog" data-tab-target="overduePanel">Overdue Borrowers</button>
                </div>
                <div class="search-box">
                    <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                    <input type="text" class="search-input" data-table="returnReqTable" placeholder="Search by ID">
                </div>
            </div>

            <!-- Return Requests Tab -->
            <div class="tab-panel" id="returnReqPanel" data-tab-group="catalog">
                <div class="data-table-wrapper">
                    <table class="data-table" id="returnReqTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>User ID</th>
                                <th>Member Name</th>
                                <th>Book</th>
                                <th>Borrow Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Statement stReq = conn.createStatement();
                            ResultSet rsReq = stReq.executeQuery(
                                "SELECT bh.id, bh.member_id, m.name AS member_name, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, " +
                                "(bh.due_date IS NOT NULL AND bh.due_date < NOW()) AS is_overdue " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id LEFT JOIN members m ON bh.member_id = m.id " +
                                "WHERE bh.status = 'RETURN_PENDING' ORDER BY bh.borrow_date DESC");
                            boolean hasReq = false;
                            while (rsReq.next()) {
                                hasReq = true;
                                boolean overdue = rsReq.getBoolean("is_overdue");
                        %>
                            <tr>
                                <td><%= rsReq.getInt("id") %></td>
                                <td><%= rsReq.getInt("member_id") %></td>
                                <td><%= rsReq.getString("member_name") != null ? rsReq.getString("member_name") : "-" %></td>
                                <td><%= rsReq.getString("title") %></td>
                                <td><%= rsReq.getTimestamp("borrow_date") %></td>
                                <td><%= rsReq.getTimestamp("due_date") != null ? rsReq.getTimestamp("due_date") : "-" %></td>
                                <td><span class="status-pending">Return Requested</span></td>
                                <td>
                                    <div class="action-btns" style="gap:6px">
                                        <form action="ApproveReturnServlet" method="post" style="display:inline">
                                            <input type="hidden" name="borrowId" value="<%= rsReq.getInt("id") %>">
                                            <button type="submit" class="btn-add" style="padding:5px 14px;font-size:12px">Approve</button>
                                        </form>
                                        <button class="btn-add" style="padding:5px 14px;font-size:12px;background:#b00" onclick="openRejectModal(<%= rsReq.getInt("id") %>, '<%= rsReq.getString("member_name") != null ? rsReq.getString("member_name").replace("'","\\'") : "" %>')">Reject</button>
                                    </div>
                                </td>
                            </tr>
                        <% }
                            if (!hasReq) {
                        %>
                            <tr><td colspan="8" class="text-center" style="padding:40px;color:#999;">No pending return requests</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Borrowed Books Tab -->
            <div class="tab-panel hidden" id="borrowedPanel" data-tab-group="catalog">
                <div class="data-table-wrapper">
                    <table class="data-table" id="catalogTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>User ID</th>
                                <th>Book</th>
                                <th>Borrow Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Statement stB = conn.createStatement();
                            ResultSet rs = stB.executeQuery(
                                "SELECT bh.id, bh.member_id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status, " +
                                "m.name AS mname, m.profile_image, m.image_type, m.created_at AS m_joined, " +
                                "(bh.due_date IS NOT NULL AND bh.due_date < NOW()) AS is_overdue " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id LEFT JOIN members m ON bh.member_id = m.id " +
                                "WHERE bh.status IN ('BORROWED','RETURN_PENDING','REJECTED') ORDER BY bh.borrow_date DESC");
                            while (rs.next()) {
                                boolean overdue = rs.getBoolean("is_overdue");
                                String bStatus = rs.getString("status");
                                String bLabel, bCls;
                                if ("RETURN_PENDING".equals(bStatus)) { bLabel = "Return Requested"; bCls = "status-pending"; }
                                else if ("REJECTED".equals(bStatus)) { bLabel = "Return Rejected"; bCls = "status-overdue"; }
                                else if (overdue) { bLabel = "Overdue"; bCls = "status-overdue"; }
                                else { bLabel = "Borrowed"; bCls = "status-borrowed"; }
                                int bMid = rs.getInt("member_id");
                                String bMname = rs.getString("mname") != null ? rs.getString("mname") : "Unknown";
                                String bMJoined = rs.getTimestamp("m_joined") != null ? rs.getTimestamp("m_joined").toString() : "N/A";
                                String bMPhoto = "";
                                byte[] bMImg = rs.getBytes("profile_image");
                                String bMMime = rs.getString("image_type");
                                if (bMImg != null && bMImg.length > 0) {
                                    if (bMMime == null || bMMime.isEmpty()) bMMime = "image/jpeg";
                                    bMPhoto = "data:" + bMMime + ";base64," + java.util.Base64.getEncoder().encodeToString(bMImg);
                                }
                                int bBorrowId = rs.getInt("id");
                        %>
                            <tr>
                                <td><%= bBorrowId %></td>
                                <td><%= bMid %></td>
                                <td><%= rs.getString("title") %></td>
                                <td><%= rs.getTimestamp("borrow_date") %></td>
                                <td><%= rs.getTimestamp("due_date") != null ? rs.getTimestamp("due_date") : "-" %></td>
                                <td><span class="<%= bCls %>"><%= bLabel %></span></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="action-btn view-btn" onclick="openModal('borrowViewModal-<%= bBorrowId %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                    </div>
                                </td>
                            </tr>
                            <!-- Virtual ID Card Modal -->
                            <div class="modal-overlay" id="borrowViewModal-<%= bBorrowId %>">
                                <div class="modal">
                                    <div class="modal-header">
                                        <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="User" style="width:20px;height:20px;vertical-align:middle"></span> Member Virtual ID</h2>
                                        <button class="modal-close">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <div style="max-width:420px;margin:0 auto;background:linear-gradient(135deg,#111 0%,#333 100%);color:#fff;border-radius:12px;padding:20px;box-shadow:0 4px 16px rgba(0,0,0,0.15)">
                                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.2);padding-bottom:10px">
                                                <div style="font-size:11px;letter-spacing:2px;opacity:0.7">THE ARCHIVE CO.</div>
                                                <div style="font-size:11px;letter-spacing:1px;opacity:0.7">MEMBER ID</div>
                                            </div>
                                            <div style="display:flex;gap:16px;align-items:center">
                                                <div style="width:90px;height:110px;border-radius:6px;overflow:hidden;background:#555;flex-shrink:0;border:2px solid rgba(255,255,255,0.3)">
                                                    <% if (!bMPhoto.isEmpty()) { %>
                                                        <img src="<%= bMPhoto %>" alt="Photo" style="width:100%;height:100%;object-fit:cover">
                                                    <% } else { %>
                                                        <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px;color:#fff"><%= bMname.length() > 0 ? bMname.substring(0,1).toUpperCase() : "?" %></div>
                                                    <% } %>
                                                </div>
                                                <div style="flex:1;min-width:0">
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">NAME</div>
                                                    <div style="font-size:16px;font-weight:600;margin-bottom:8px;word-break:break-word"><%= bMname %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">USER ID</div>
                                                    <div style="font-size:14px;font-weight:500;margin-bottom:8px">#<%= String.format("%06d", bMid) %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">REGISTERED</div>
                                                    <div style="font-size:12px;font-weight:500"><%= bMJoined %></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button class="btn-confirm" onclick="closeModal('borrowViewModal-<%= bBorrowId %>')">CLOSE</button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Overdue Tab -->
            <div class="tab-panel hidden" id="overduePanel" data-tab-group="catalog">
                <div class="data-table-wrapper">
                    <table class="data-table" id="overdueTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>User ID</th>
                                <th>Book</th>
                                <th>Borrow Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Statement stO = conn.createStatement();
                            ResultSet rsO = stO.executeQuery(
                                "SELECT bh.id, bh.member_id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status, " +
                                "m.name AS mname, m.profile_image, m.image_type, m.created_at AS m_joined " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id LEFT JOIN members m ON bh.member_id = m.id " +
                                "WHERE bh.status IN ('BORROWED','RETURN_PENDING','REJECTED') AND bh.due_date IS NOT NULL AND bh.due_date < NOW() " +
                                "ORDER BY bh.due_date");
                            while (rsO.next()) {
                                int oMid = rsO.getInt("member_id");
                                String oMname = rsO.getString("mname") != null ? rsO.getString("mname") : "Unknown";
                                String oMJoined = rsO.getTimestamp("m_joined") != null ? rsO.getTimestamp("m_joined").toString() : "N/A";
                                String oMPhoto = "";
                                byte[] oMImg = rsO.getBytes("profile_image");
                                String oMMime = rsO.getString("image_type");
                                if (oMImg != null && oMImg.length > 0) {
                                    if (oMMime == null || oMMime.isEmpty()) oMMime = "image/jpeg";
                                    oMPhoto = "data:" + oMMime + ";base64," + java.util.Base64.getEncoder().encodeToString(oMImg);
                                }
                                int oBorrowId = rsO.getInt("id");
                        %>
                            <tr>
                                <td><%= oBorrowId %></td>
                                <td><%= oMid %></td>
                                <td><%= rsO.getString("title") %></td>
                                <td><%= rsO.getTimestamp("borrow_date") %></td>
                                <td><%= rsO.getTimestamp("due_date") != null ? rsO.getTimestamp("due_date") : "-" %></td>
                                <td><span class="status-overdue">Overdue</span></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="action-btn view-btn" onclick="openModal('overdueViewModal-<%= oBorrowId %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                    </div>
                                </td>
                            </tr>
                            <!-- Virtual ID Card Modal -->
                            <div class="modal-overlay" id="overdueViewModal-<%= oBorrowId %>">
                                <div class="modal">
                                    <div class="modal-header">
                                        <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="User" style="width:20px;height:20px;vertical-align:middle"></span> Member Virtual ID</h2>
                                        <button class="modal-close">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <div style="max-width:420px;margin:0 auto;background:linear-gradient(135deg,#111 0%,#333 100%);color:#fff;border-radius:12px;padding:20px;box-shadow:0 4px 16px rgba(0,0,0,0.15)">
                                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.2);padding-bottom:10px">
                                                <div style="font-size:11px;letter-spacing:2px;opacity:0.7">THE ARCHIVE CO.</div>
                                                <div style="font-size:11px;letter-spacing:1px;opacity:0.7">MEMBER ID</div>
                                            </div>
                                            <div style="display:flex;gap:16px;align-items:center">
                                                <div style="width:90px;height:110px;border-radius:6px;overflow:hidden;background:#555;flex-shrink:0;border:2px solid rgba(255,255,255,0.3)">
                                                    <% if (!oMPhoto.isEmpty()) { %>
                                                        <img src="<%= oMPhoto %>" alt="Photo" style="width:100%;height:100%;object-fit:cover">
                                                    <% } else { %>
                                                        <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px;color:#fff"><%= oMname.length() > 0 ? oMname.substring(0,1).toUpperCase() : "?" %></div>
                                                    <% } %>
                                                </div>
                                                <div style="flex:1;min-width:0">
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">NAME</div>
                                                    <div style="font-size:16px;font-weight:600;margin-bottom:8px;word-break:break-word"><%= oMname %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">USER ID</div>
                                                    <div style="font-size:14px;font-weight:500;margin-bottom:8px">#<%= String.format("%06d", oMid) %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">REGISTERED</div>
                                                    <div style="font-size:12px;font-weight:500"><%= oMJoined %></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button class="btn-confirm" onclick="closeModal('overdueViewModal-<%= oBorrowId %>')">CLOSE</button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

<!-- Reject Return Modal -->
<div class="modal-overlay delete-modal" id="rejectReturnModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-delete.svg" alt="Reject" style="width:20px;height:20px;vertical-align:middle"></span> Reject Return Request</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="RejectReturnServlet" method="post">
            <input type="hidden" name="borrowId" id="rejectBorrowId">
            <div class="modal-body">
                <p>You are rejecting the return request from <strong id="rejectMemberName"></strong>. The member will see this message.</p>
                <div class="form-group" style="margin-top:12px">
                    <label>Reason for rejection</label>
                    <textarea name="reason" required minlength="5" rows="3" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;resize:vertical" placeholder="e.g., Book has not been returned to the library, book is damaged..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">REJECT RETURN</button>
            </div>
        </form>
    </div>
</div>

<!-- Change Credentials Modal -->
<div class="modal-overlay" id="credentialsModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-gear.svg" alt="Settings" style="width:20px;height:20px;vertical-align:middle"></span> Change Credentials</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="ChangeCredentialsServlet" method="post">
            <input type="hidden" name="role" value="admin">
            <div class="modal-body">
                <div class="form-group">
                    <label>Enter Current Password</label>
                    <input type="password" name="currentPassword" required>
                </div>
                <div class="form-group">
                    <label>Enter New Password</label>
                    <input type="password" name="newPassword" required>
                </div>
                <div class="form-group">
                    <label>Confirm New Password</label>
                    <input type="password" name="confirmPassword" required>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">CONFIRM</button>
            </div>
        </form>
    </div>
</div>

<script src="js/main.js"></script>
<script>
function openRejectModal(borrowId, memberName) {
    document.getElementById('rejectBorrowId').value = borrowId;
    document.getElementById('rejectMemberName').textContent = memberName;
    var form = document.querySelector('#rejectReturnModal form');
    if (form) form.querySelector('textarea[name="reason"]').value = '';
    openModal('rejectReturnModal');
}
</script>
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
