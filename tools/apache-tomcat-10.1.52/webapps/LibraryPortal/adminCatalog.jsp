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
                            ResultSet rs = st.executeQuery(
                                "SELECT bh.id, bh.member_id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status, " +
                                "(bh.due_date IS NOT NULL AND bh.due_date < NOW()) AS is_overdue " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id " +
                                "WHERE bh.status IN ('BORROWED','RETURN_PENDING','REJECTED') ORDER BY bh.borrow_date DESC");
                            while (rs.next()) {
                                boolean overdue = rs.getBoolean("is_overdue");
                                String bStatus = rs.getString("status");
                                String bLabel, bCls;
                                if ("RETURN_PENDING".equals(bStatus)) { bLabel = "Return Requested"; bCls = "status-pending"; }
                                else if ("REJECTED".equals(bStatus)) { bLabel = "Return Rejected"; bCls = "status-overdue"; }
                                else if (overdue) { bLabel = "Overdue"; bCls = "status-overdue"; }
                                else { bLabel = "Borrowed"; bCls = "status-borrowed"; }
                        %>
                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getInt("member_id") %></td>
                                <td><%= rs.getString("title") %></td>
                                <td><%= rs.getTimestamp("borrow_date") %></td>
                                <td><%= rs.getTimestamp("due_date") != null ? rs.getTimestamp("due_date") : "-" %></td>
                                <td><span class="<%= bCls %>"><%= bLabel %></span></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="action-btn view-btn" onclick="openModal('borrowViewModal-<%= rs.getInt("id") %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                    </div>
                                </td>
                            </tr>
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
                                "SELECT bh.id, bh.member_id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id " +
                                "WHERE bh.status IN ('BORROWED','RETURN_PENDING','REJECTED') AND bh.due_date IS NOT NULL AND bh.due_date < NOW() " +
                                "ORDER BY bh.due_date");
                            while (rsO.next()) {
                        %>
                            <tr>
                                <td><%= rsO.getInt("id") %></td>
                                <td><%= rsO.getInt("member_id") %></td>
                                <td><%= rsO.getString("title") %></td>
                                <td><%= rsO.getTimestamp("borrow_date") %></td>
                                <td><%= rsO.getTimestamp("due_date") != null ? rsO.getTimestamp("due_date") : "-" %></td>
                                <td><span class="status-overdue">Overdue</span></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="action-btn view-btn" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                    </div>
                                </td>
                            </tr>
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
