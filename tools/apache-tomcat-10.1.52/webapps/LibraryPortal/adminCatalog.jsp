<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("login.jsp?role=admin&error=Please login first");
        return;
    }
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
        Statement st = conn.createStatement();
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
            <!-- Tabs -->
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:24px;">
                <div class="tab-buttons">
                    <button class="tab-btn active" data-tab-group="catalog" data-tab-target="borrowedPanel">Borrowed Books</button>
                    <button class="tab-btn" data-tab-group="catalog" data-tab-target="overduePanel">Overdue Borrowers</button>
                </div>
                <div class="search-box">
                    <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                    <input type="text" class="search-input" data-table="catalogTable" placeholder="Search by ID">
                </div>
            </div>

            <!-- Borrowed Books Tab -->
            <div class="tab-panel" id="borrowedPanel" data-tab-group="catalog">
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
                                "WHERE bh.status = 'BORROWED' ORDER BY bh.borrow_date DESC");
                            while (rs.next()) {
                                boolean overdue = rs.getBoolean("is_overdue");
                        %>
                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getInt("member_id") %></td>
                                <td><%= rs.getString("title") %></td>
                                <td><%= rs.getTimestamp("borrow_date") %></td>
                                <td><%= rs.getTimestamp("due_date") != null ? rs.getTimestamp("due_date") : "-" %></td>
                                <td><span class="<%= overdue ? "status-overdue" : "status-borrowed" %>"><%= overdue ? "Overdue" : "Borrowed" %></span></td>
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
                            ResultSet rsO = st.executeQuery(
                                "SELECT bh.id, bh.member_id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id " +
                                "WHERE bh.status = 'BORROWED' AND bh.due_date IS NOT NULL AND bh.due_date < NOW() " +
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
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
