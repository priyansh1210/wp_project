<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("login.jsp?role=admin&error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("adminName");

    // Fetch stats
    int totalUsers = 0, totalBooks = 0, totalBranches = 0, totalBorrowed = 0, totalReturned = 0;
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");

        // Users count
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM members");
        if (rs.next()) totalUsers = rs.getInt(1);

        // Books count
        rs = st.executeQuery("SELECT COUNT(*) FROM books");
        if (rs.next()) totalBooks = rs.getInt(1);

        // Branches count
        rs = st.executeQuery("SELECT COUNT(*) FROM branches");
        if (rs.next()) totalBranches = rs.getInt(1);

        // Borrowed count
        rs = st.executeQuery("SELECT COUNT(*) FROM borrow_history WHERE status='BORROWED'");
        if (rs.next()) totalBorrowed = rs.getInt(1);

        // Returned count
        rs = st.executeQuery("SELECT COUNT(*) FROM borrow_history WHERE status='RETURNED'");
        if (rs.next()) totalReturned = rs.getInt(1);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Admin Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="dashboard"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <div class="dashboard-grid">
                <!-- Pie Chart -->
                <div class="chart-section">
                    <div class="pie-chart-container">
                        <canvas id="pieChart" width="300" height="300"
                                data-borrowed="<%= totalBorrowed %>"
                                data-returned="<%= totalReturned %>"></canvas>
                    </div>
                    <div class="chart-legend">
                        <div class="chart-legend-item">
                            <div class="chart-legend-dot" style="background:#1a1a1a"></div>
                            Total Borrowed Books
                        </div>
                        <div class="chart-legend-item">
                            <div class="chart-legend-dot" style="background:#666"></div>
                            Total Returned Books
                        </div>
                    </div>
                </div>

                <!-- Stat Cards -->
                <div class="stat-cards">
                    <div class="stat-card">
                        <div>
                            <div class="stat-number"><%= String.format("%04d", totalUsers) %></div>
                            <div class="stat-label">Total User Base</div>
                        </div>
                        <div class="stat-icon"><img src="img/icon-users.svg" alt="Users" style="width:28px;height:28px"></div>
                    </div>
                    <div class="stat-card">
                        <div>
                            <div class="stat-number"><%= String.format("%04d", totalBooks) %></div>
                            <div class="stat-label">Total Book Count</div>
                        </div>
                        <div class="stat-icon"><img src="img/icon-books.svg" alt="Books" style="width:28px;height:28px"></div>
                    </div>
                    <div class="stat-card">
                        <div>
                            <div class="stat-number"><%= String.format("%04d", totalBranches) %></div>
                            <div class="stat-label">Branch Count</div>
                        </div>
                        <div class="stat-icon"><img src="img/icon-branches.svg" alt="Branches" style="width:28px;height:28px"></div>
                    </div>
                </div>

                <!-- Overdue Borrowers -->
                <div class="info-section overdue-section">
                    <h3>Overdue Borrowers</h3>
                    <div class="info-list">
                        <%
                            ResultSet rsOverdue = st.executeQuery(
                                "SELECT bh.id, m.name, bh.id as borrow_id FROM borrow_history bh " +
                                "JOIN members m ON bh.member_id = m.id " +
                                "WHERE bh.status='BORROWED' ORDER BY bh.borrow_date LIMIT 5");
                            while (rsOverdue.next()) {
                        %>
                        <div class="info-list-item">
                            <div class="item-avatar"><img src="img/icon-avatar.svg" alt="User" style="width:20px;height:20px"></div>
                            <div class="item-details">
                                <div class="item-name"><%= rsOverdue.getString("name") %></div>
                                <div class="item-sub">Borrowed ID : <%= rsOverdue.getInt("borrow_id") %></div>
                            </div>
                            <div class="item-actions">
                                <button title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Admins List -->
                <div class="info-section admins-section">
                    <h3>The Archive Co. Admins</h3>
                    <div class="info-list">
                        <%
                            ResultSet rsAdmins = st.executeQuery("SELECT id, name FROM admin LIMIT 5");
                            while (rsAdmins.next()) {
                        %>
                        <div class="info-list-item">
                            <div class="item-avatar"><img src="img/icon-avatar.svg" alt="User" style="width:20px;height:20px"></div>
                            <div class="item-details">
                                <div class="item-name"><%= rsAdmins.getString("name") %></div>
                                <div class="item-sub">Admin ID : <%= rsAdmins.getInt("id") %></div>
                            </div>
                            <span class="item-badge">Active</span>
                            <div class="item-actions">
                                <button><img src="img/icon-edit.svg" alt="Edit" style="width:14px;height:14px"></button>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Branch Network -->
                <div class="info-section branch-section">
                    <h3>Branch Network</h3>
                    <div class="info-list">
                        <%
                            ResultSet rsBranch = st.executeQuery("SELECT id, name, location FROM branches LIMIT 5");
                            while (rsBranch.next()) {
                        %>
                        <div class="info-list-item">
                            <div class="item-avatar"><img src="img/icon-branches.svg" alt="Branch" style="width:20px;height:20px"></div>
                            <div class="item-details">
                                <div class="item-name"><%= rsBranch.getString("name") %></div>
                                <div class="item-sub">Branch ID : <%= rsBranch.getInt("id") %></div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
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
                <div class="form-group">
                    <label>Enter Current Password</label>
                    <input type="password" name="currentPassword" placeholder="Enter Current Password" required>
                </div>
                <div class="form-group">
                    <label>Enter New Password</label>
                    <input type="password" name="newPassword" placeholder="Enter New Password" required>
                </div>
                <div class="form-group">
                    <label>Confirm New Password</label>
                    <input type="password" name="confirmPassword" placeholder="Confirm New Password" required>
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
