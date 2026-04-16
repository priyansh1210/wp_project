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
        ResultSet rs = st.executeQuery(
            "SELECT m.id, m.name, m.email, m.username, m.profile_image, m.image_type, m.created_at, " +
            "(SELECT COUNT(*) FROM borrow_history bh WHERE bh.member_id=m.id AND bh.status='BORROWED') AS active_borrows " +
            "FROM members m ORDER BY m.id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | User Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="users"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <!-- Tabs -->
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:24px;">
                <div class="tab-buttons">
                    <button class="tab-btn active" data-tab-group="users" data-tab-target="usersPanel">Users</button>
                    <button class="tab-btn" data-tab-group="users" data-tab-target="deletionLogPanel">Deletion Log</button>
                </div>
                <div class="search-box">
                    <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                    <input type="text" class="search-input" data-table="usersTable" placeholder="Search by ID or Name">
                </div>
            </div>

            <!-- Users Tab -->
            <div class="tab-panel" id="usersPanel" data-tab-group="users">
                <div class="page-header">
                    <h1>User Management</h1>
                    <div class="page-header-actions">
                        <button class="btn-add" onclick="openModal('addUserModal')">
                            <span class="icon"><img src="img/icon-add.svg" alt="Add" style="width:14px;height:14px;vertical-align:middle;filter:invert(1)"></span> Add User
                        </button>
                    </div>
                </div>

                <div class="data-table-wrapper">
                    <table class="data-table" id="usersTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Username</th>
                                <th>Active Borrows</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% while (rs.next()) {
                            int uid = rs.getInt("id");
                            String uname = rs.getString("name");
                            String uemail = rs.getString("email");
                            String uusername = rs.getString("username") != null ? rs.getString("username") : uemail;
                            int activeBorrows = rs.getInt("active_borrows");
                            String uJoined = rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : "N/A";
                            String uPhotoDataUrl = "";
                            byte[] uImg = rs.getBytes("profile_image");
                            String uMime = rs.getString("image_type");
                            if (uImg != null && uImg.length > 0) {
                                if (uMime == null || uMime.isEmpty()) uMime = "image/jpeg";
                                uPhotoDataUrl = "data:" + uMime + ";base64," + java.util.Base64.getEncoder().encodeToString(uImg);
                            }
                        %>
                            <tr>
                                <td><%= uid %></td>
                                <td><%= uname %></td>
                                <td><%= uemail %></td>
                                <td><%= uusername %></td>
                                <td><%= activeBorrows %></td>
                                <td>
                                    <div class="action-btns">
                                        <% if (activeBorrows > 0) { %>
                                        <button class="action-btn delete-btn" onclick="alert('Cannot delete: member has <%= activeBorrows %> book(s) not yet returned.')" title="Cannot delete - active borrows"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px;opacity:0.4"></button>
                                        <% } else { %>
                                        <button class="action-btn delete-btn" onclick="openDeleteMemberModal(<%= uid %>, '<%= uname.replace("'","\\'") %>')" title="Delete"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px"></button>
                                        <% } %>
                                        <button class="action-btn view-btn" onclick="openModal('viewUserModal-<%= uid %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                    </div>
                                </td>
                            </tr>

                            <!-- View User Modal -->
                            <div class="modal-overlay" id="viewUserModal-<%= uid %>">
                                <div class="modal">
                                    <div class="modal-header">
                                        <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Users" style="width:20px;height:20px;vertical-align:middle"></span> View User</h2>
                                        <button class="modal-close">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <!-- Virtual ID Card -->
                                        <div style="max-width:420px;margin:0 auto;background:linear-gradient(135deg,#111 0%,#333 100%);color:#fff;border-radius:12px;padding:20px;box-shadow:0 4px 16px rgba(0,0,0,0.15)">
                                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.2);padding-bottom:10px">
                                                <div style="font-size:11px;letter-spacing:2px;opacity:0.7">THE ARCHIVE CO.</div>
                                                <div style="font-size:11px;letter-spacing:1px;opacity:0.7">MEMBER ID</div>
                                            </div>
                                            <div style="display:flex;gap:16px;align-items:center">
                                                <div style="width:90px;height:110px;border-radius:6px;overflow:hidden;background:#555;flex-shrink:0;border:2px solid rgba(255,255,255,0.3)">
                                                    <% if (!uPhotoDataUrl.isEmpty()) { %>
                                                        <img src="<%= uPhotoDataUrl %>" alt="Photo" style="width:100%;height:100%;object-fit:cover">
                                                    <% } else { %>
                                                        <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px;color:#fff"><%= uname.length() > 0 ? uname.substring(0,1).toUpperCase() : "?" %></div>
                                                    <% } %>
                                                </div>
                                                <div style="flex:1;min-width:0">
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">NAME</div>
                                                    <div style="font-size:16px;font-weight:600;margin-bottom:8px;word-break:break-word"><%= uname %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">USER ID</div>
                                                    <div style="font-size:14px;font-weight:500;margin-bottom:8px">#<%= String.format("%06d", uid) %></div>
                                                    <div style="font-size:11px;opacity:0.6;letter-spacing:1px">REGISTERED</div>
                                                    <div style="font-size:12px;font-weight:500"><%= uJoined %></div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Member Details -->
                                        <div style="margin-top:16px">
                                            <div class="view-meta">
                                                <div class="view-details">
                                                    <div class="detail-row"><span class="detail-label">Email :</span><span class="detail-value"><%= uemail %></span></div>
                                                    <div class="detail-row"><span class="detail-label">Username :</span><span class="detail-value"><%= uusername %></span></div>
                                                    <div class="detail-row"><span class="detail-label">Active Borrows :</span><span class="detail-value"><%= activeBorrows %></span></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button class="btn-confirm" onclick="closeModal('viewUserModal-<%= uid %>')">CLOSE</button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Deletion Log Tab -->
            <div class="tab-panel hidden" id="deletionLogPanel" data-tab-group="users">
                <div class="page-header">
                    <h1>Deletion Log</h1>
                    <p style="color:#666;margin:0">Audit trail of deleted members, visible to all admins.</p>
                </div>
                <div class="data-table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Member ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Reason</th>
                                <th>Deleted By</th>
                                <th>Deleted At</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Statement stLog = conn.createStatement();
                            ResultSet rsLog = stLog.executeQuery(
                                "SELECT member_id, name, email, reason, deleted_by_admin_name, deleted_at " +
                                "FROM deleted_members ORDER BY deleted_at DESC");
                            boolean hasLog = false;
                            while (rsLog.next()) {
                                hasLog = true;
                        %>
                            <tr>
                                <td><%= rsLog.getInt("member_id") %></td>
                                <td><%= rsLog.getString("name") != null ? rsLog.getString("name") : "-" %></td>
                                <td><%= rsLog.getString("email") != null ? rsLog.getString("email") : "-" %></td>
                                <td style="max-width:280px;white-space:normal"><%= rsLog.getString("reason") %></td>
                                <td><%= rsLog.getString("deleted_by_admin_name") != null ? rsLog.getString("deleted_by_admin_name") : "-" %></td>
                                <td><%= rsLog.getTimestamp("deleted_at") %></td>
                            </tr>
                        <% }
                            if (!hasLog) { %>
                            <tr><td colspan="6" class="text-center" style="padding:40px;color:#999;">No deletions recorded yet</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add User Modal -->
<div class="modal-overlay" id="addUserModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Users" style="width:20px;height:20px;vertical-align:middle"></span> Add User</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="AddMemberServlet" method="post">
            <div class="modal-body">
                <div class="form-group"><input type="text" name="name" placeholder="Name" required></div>
                <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
                <div class="form-row">
                    <div class="form-group"><input type="text" name="username" placeholder="Username" required></div>
                    <div class="form-group"><input type="password" name="password" placeholder="Password" required></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">ADD</button>
            </div>
        </form>
    </div>
</div>


<!-- Delete Member Modal (with reason) -->
<div class="modal-overlay delete-modal" id="deleteMemberModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-delete.svg" alt="Delete" style="width:20px;height:20px;vertical-align:middle"></span> Delete Member</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="DeleteMemberServlet" method="post">
            <input type="hidden" name="id" id="deleteMemberId">
            <div class="modal-body">
                <p>You are about to delete <strong id="deleteMemberName"></strong>. Please provide a reason (min 5 characters). This will be logged and visible to all admins.</p>
                <div class="form-group" style="margin-top:12px">
                    <label>Reason</label>
                    <textarea name="reason" required minlength="5" rows="3" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;resize:vertical" placeholder="e.g., Duplicate account, user request, policy violation..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">CONFIRM DELETE</button>
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
                <div class="form-group"><label>Enter Current Password</label><input type="password" name="currentPassword" required></div>
                <div class="form-group"><label>Enter New Password</label><input type="password" name="newPassword" required></div>
                <div class="form-group"><label>Confirm New Password</label><input type="password" name="confirmPassword" required></div>
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
function openDeleteMemberModal(id, name) {
    document.getElementById('deleteMemberId').value = id;
    document.getElementById('deleteMemberName').textContent = name;
    var form = document.querySelector('#deleteMemberModal form');
    if (form) form.querySelector('textarea[name="reason"]').value = '';
    openModal('deleteMemberModal');
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
