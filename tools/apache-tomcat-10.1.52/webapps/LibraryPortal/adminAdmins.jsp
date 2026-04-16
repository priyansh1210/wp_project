<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("login.jsp?role=admin&error=Please login first");
        return;
    }
    int currentAdminId = Integer.parseInt(session.getAttribute("adminId").toString());
    String msg = request.getParameter("msg");
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM admin ORDER BY id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Admin Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="admins"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <div class="page-header">
                <h1>Admin Management</h1>
                <div class="page-header-actions">
                    <button class="btn-add" onclick="openModal('addAdminModal')">
                        <span class="icon"><img src="img/icon-add.svg" alt="Add" style="width:14px;height:14px;vertical-align:middle;filter:invert(1)"></span> Add Admin
                    </button>
                    <div class="search-box">
                        <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                        <input type="text" class="search-input" data-table="adminsTable" placeholder="Search by ID or Name">
                    </div>
                </div>
            </div>

            <div class="data-table-wrapper">
                <table class="data-table" id="adminsTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Username</th>
                            <th>Contact</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% while (rs.next()) {
                        int aid = rs.getInt("id");
                        String aname = rs.getString("name") != null ? rs.getString("name") : "";
                        String afirst = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                        String alast = rs.getString("last_name") != null ? rs.getString("last_name") : "";
                        String aemail = rs.getString("email") != null ? rs.getString("email") : "";
                        String ausername = rs.getString("username") != null ? rs.getString("username") : aemail;
                        String acontact = rs.getString("contact_no") != null ? rs.getString("contact_no") : "";
                        boolean isSelf = (aid == currentAdminId);
                    %>
                        <tr>
                            <td><%= aid %><%= isSelf ? " (you)" : "" %></td>
                            <td><%= aname %></td>
                            <td><%= aemail %></td>
                            <td><%= ausername %></td>
                            <td><%= acontact %></td>
                            <td>
                                <div class="action-btns">
                                    <button class="action-btn edit-btn" onclick="populateEditForm('editAdminModal', {id:'<%= aid %>', firstName:'<%= afirst.replace("'","\\'") %>', lastName:'<%= alast.replace("'","\\'") %>', contactNo:'<%= acontact.replace("'","\\'") %>', email:'<%= aemail.replace("'","\\'") %>', username:'<%= ausername.replace("'","\\'") %>'})" title="Edit"><img src="img/icon-edit.svg" alt="Edit" style="width:14px;height:14px"></button>
                                    <% if (!isSelf) { %>
                                    <button class="action-btn delete-btn" onclick="confirmDelete('DeleteAdminServlet?id=<%= aid %>')" title="Delete"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px"></button>
                                    <% } %>
                                    <button class="action-btn view-btn" onclick="openModal('viewAdminModal-<%= aid %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                </div>
                            </td>
                        </tr>

                        <!-- View Admin Modal -->
                        <div class="modal-overlay" id="viewAdminModal-<%= aid %>">
                            <div class="modal">
                                <div class="modal-header">
                                    <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Admins" style="width:20px;height:20px;vertical-align:middle"></span> View Admin</h2>
                                    <button class="modal-close">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <div class="view-meta">
                                        <div class="view-details">
                                            <div class="detail-row"><span class="detail-label">Admin ID :</span><span class="detail-value"><%= aid %></span></div>
                                            <div class="detail-row"><span class="detail-label">Name :</span><span class="detail-value"><%= aname %></span></div>
                                            <div class="detail-row"><span class="detail-label">Email :</span><span class="detail-value"><%= aemail %></span></div>
                                            <div class="detail-row"><span class="detail-label">Username :</span><span class="detail-value"><%= ausername %></span></div>
                                            <div class="detail-row"><span class="detail-label">Contact :</span><span class="detail-value"><%= acontact %></span></div>
                                        </div>
                                        <div class="view-saved-by">
                                            Viewed by :<br>
                                            <strong><%= session.getAttribute("adminName") %></strong>
                                            (Admin)
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn-confirm" onclick="closeModal('viewAdminModal-<%= aid %>')">CLOSE</button>
                                </div>
                            </div>
                        </div>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

<!-- Add Admin Modal -->
<div class="modal-overlay" id="addAdminModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Admins" style="width:20px;height:20px;vertical-align:middle"></span> Add Admin</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="AddAdminServlet" method="post">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group"><input type="text" name="firstName" placeholder="First Name" required></div>
                    <div class="form-group"><input type="text" name="lastName" placeholder="Last Name" required></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><input type="tel" name="contactNo" placeholder="Contact No (e.g. 9876543210)" pattern="[6-9][0-9]{9}" maxlength="10" title="Enter a valid 10-digit Indian mobile number starting with 6-9" oninput="this.value=this.value.replace(/[^0-9]/g,'')"></div>
                    <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><input type="text" name="username" placeholder="Username" required></div>
                    <div class="form-group"><input type="password" name="password" placeholder="Password (min 4 chars)" required></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">ADD</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Admin Modal -->
<div class="modal-overlay" id="editAdminModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-users.svg" alt="Admins" style="width:20px;height:20px;vertical-align:middle"></span> Update Admin</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="UpdateAdminServlet" method="post">
            <input type="hidden" name="id">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group"><input type="text" name="firstName" placeholder="First Name" required></div>
                    <div class="form-group"><input type="text" name="lastName" placeholder="Last Name" required></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><input type="tel" name="contactNo" placeholder="Contact No (e.g. 9876543210)" pattern="[6-9][0-9]{9}" maxlength="10" title="Enter a valid 10-digit Indian mobile number starting with 6-9" oninput="this.value=this.value.replace(/[^0-9]/g,'')"></div>
                    <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><input type="text" name="username" placeholder="Username"></div>
                    <div class="form-group"><input type="password" name="password" placeholder="New Password (leave blank to keep)"></div>
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
