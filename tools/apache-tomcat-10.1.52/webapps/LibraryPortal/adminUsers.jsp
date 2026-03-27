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
        ResultSet rs = st.executeQuery("SELECT * FROM members ORDER BY id");
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

            <div class="page-header">
                <h1>User Management</h1>
                <div class="page-header-actions">
                    <button class="btn-add" onclick="openModal('addUserModal')">
                        <span class="icon"><img src="img/icon-add.svg" alt="Add" style="width:14px;height:14px;vertical-align:middle;filter:invert(1)"></span> Add User
                    </button>
                    <div class="search-box">
                        <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                        <input type="text" class="search-input" data-table="usersTable" placeholder="Search by ID or Name">
                    </div>
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
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% while (rs.next()) {
                        int uid = rs.getInt("id");
                        String uname = rs.getString("name");
                        String uemail = rs.getString("email");
                        String uusername = rs.getString("username") != null ? rs.getString("username") : uemail;
                    %>
                        <tr>
                            <td><%= uid %></td>
                            <td><%= uname %></td>
                            <td><%= uemail %></td>
                            <td><%= uusername %></td>
                            <td>
                                <div class="action-btns">
                                    <button class="action-btn edit-btn" onclick="populateEditForm('editUserModal', {id:'<%= uid %>', name:'<%= uname.replace("'","\\'") %>', email:'<%= uemail.replace("'","\\'") %>', username:'<%= uusername.replace("'","\\'") %>'})" title="Edit"><img src="img/icon-edit.svg" alt="Edit" style="width:14px;height:14px"></button>
                                    <button class="action-btn delete-btn" onclick="confirmDelete('DeleteMemberServlet?id=<%= uid %>')" title="Delete"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px"></button>
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
                                    <div class="view-meta">
                                        <div class="view-details">
                                            <div class="detail-row"><span class="detail-label">User ID :</span><span class="detail-value"><%= uid %></span></div>
                                            <div class="detail-row"><span class="detail-label">Name :</span><span class="detail-value"><%= uname %></span></div>
                                            <div class="detail-row"><span class="detail-label">Email :</span><span class="detail-value"><%= uemail %></span></div>
                                            <div class="detail-row"><span class="detail-label">Username :</span><span class="detail-value"><%= uusername %></span></div>
                                        </div>
                                        <div class="view-saved-by">
                                            Saved by :<br>
                                            <strong><%= session.getAttribute("adminName") %></strong>
                                            (Admin)
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

<!-- Edit User Modal -->
<div class="modal-overlay" id="editUserModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Users" style="width:20px;height:20px;vertical-align:middle"></span> Update User</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="UpdateMemberServlet" method="post">
            <input type="hidden" name="id">
            <div class="modal-body">
                <div class="form-group"><input type="text" name="name" placeholder="Name" required></div>
                <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
                <div class="form-row">
                    <div class="form-group"><input type="text" name="username" placeholder="Username"></div>
                    <div class="form-group"><input type="password" name="password" placeholder="Password"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">UPDATE</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal-overlay delete-modal" id="deleteModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-delete.svg" alt="Delete" style="width:20px;height:20px;vertical-align:middle"></span> Delete Confirmation</h2>
            <button class="modal-close">&times;</button>
        </div>
        <div class="modal-body">
            <p>"Are you certain you wish to proceed with the deletion of the selected entry?"</p>
        </div>
        <div class="modal-footer">
            <button class="btn-confirm" onclick="executeDelete()">CONFIRM</button>
        </div>
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
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
