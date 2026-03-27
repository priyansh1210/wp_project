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
        ResultSet rs = st.executeQuery("SELECT * FROM branches ORDER BY id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Branch Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="branches"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <div class="page-header">
                <h1>Branch Management</h1>
                <div class="page-header-actions">
                    <button class="btn-add" onclick="openModal('addBranchModal')">
                        <span class="icon"><img src="img/icon-add.svg" alt="Add" style="width:14px;height:14px;vertical-align:middle;filter:invert(1)"></span> Add Branch
                    </button>
                    <div class="search-box">
                        <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                        <input type="text" class="search-input" data-table="branchesTable" placeholder="Search by Name">
                    </div>
                </div>
            </div>

            <div class="data-table-wrapper">
                <table class="data-table" id="branchesTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Contact No</th>
                            <th>Location</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% while (rs.next()) {
                        int bid = rs.getInt("id");
                        String bname = rs.getString("name");
                        String bcontact = rs.getString("contact_no") != null ? rs.getString("contact_no") : "";
                        String blocation = rs.getString("location") != null ? rs.getString("location") : "";
                    %>
                        <tr>
                            <td><%= bid %></td>
                            <td><%= bname %></td>
                            <td><%= bcontact %></td>
                            <td><%= blocation %></td>
                            <td>
                                <div class="action-btns">
                                    <button class="action-btn edit-btn" onclick="populateEditForm('editBranchModal', {id:'<%= bid %>', name:'<%= bname.replace("'","\\'") %>', contact_no:'<%= bcontact.replace("'","\\'") %>', location:'<%= blocation.replace("'","\\'") %>'})" title="Edit"><img src="img/icon-edit.svg" alt="Edit" style="width:14px;height:14px"></button>
                                    <button class="action-btn delete-btn" onclick="confirmDelete('DeleteBranchServlet?id=<%= bid %>')" title="Delete"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px"></button>
                                    <button class="action-btn view-btn" onclick="openModal('viewBranchModal-<%= bid %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                </div>
                            </td>
                        </tr>

                        <!-- View Branch Modal -->
                        <div class="modal-overlay" id="viewBranchModal-<%= bid %>">
                            <div class="modal">
                                <div class="modal-header">
                                    <h2><span class="modal-icon"><img src="img/icon-branches.svg" alt="Branch" style="width:20px;height:20px;vertical-align:middle"></span> View Branch</h2>
                                    <button class="modal-close">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <div class="view-meta">
                                        <div class="view-details">
                                            <div class="detail-row"><span class="detail-label">Branch ID :</span><span class="detail-value"><%= bid %></span></div>
                                            <div class="detail-row"><span class="detail-label">Name :</span><span class="detail-value"><%= bname %></span></div>
                                            <div class="detail-row"><span class="detail-label">Contact No :</span><span class="detail-value"><%= bcontact %></span></div>
                                            <div class="detail-row"><span class="detail-label">Location :</span><span class="detail-value"><%= blocation %></span></div>
                                        </div>
                                        <div class="view-saved-by">
                                            Listed by :<br>
                                            <strong><%= session.getAttribute("adminName") %></strong>
                                            (Admin)
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn-confirm" onclick="closeModal('viewBranchModal-<%= bid %>')">CLOSE</button>
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

<!-- Add Branch Modal -->
<div class="modal-overlay" id="addBranchModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-branches.svg" alt="Branch" style="width:20px;height:20px;vertical-align:middle"></span> Add Branch</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="AddBranchServlet" method="post">
            <div class="modal-body">
                <div class="form-group"><input type="text" name="name" placeholder="Name" required></div>
                <div class="form-group"><input type="text" name="contact_no" placeholder="Contact No"></div>
                <div class="form-group"><input type="text" name="location" placeholder="Location"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">ADD</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Branch Modal -->
<div class="modal-overlay" id="editBranchModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-branches.svg" alt="Branch" style="width:20px;height:20px;vertical-align:middle"></span> Update Branch</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="UpdateBranchServlet" method="post">
            <input type="hidden" name="id">
            <div class="modal-body">
                <div class="form-group"><input type="text" name="name" placeholder="Name" required></div>
                <div class="form-group"><input type="text" name="contact_no" placeholder="Contact No"></div>
                <div class="form-group"><input type="text" name="location" placeholder="Location"></div>
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
