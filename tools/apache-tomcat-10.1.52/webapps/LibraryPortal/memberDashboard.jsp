<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp?role=member&error=Please login first");
        return;
    }
    int memberId = (int) session.getAttribute("memberId");
    String memberName = (String) session.getAttribute("memberName");

    int totalBooks = 0, currentlyBorrowed = 0, totalBorrows = 0, availableBooks = 0;
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
        Statement st = conn.createStatement();

        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM books");
        if (rs.next()) totalBooks = rs.getInt(1);

        rs = st.executeQuery("SELECT SUM(available) FROM books");
        if (rs.next()) availableBooks = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM borrow_history WHERE member_id=" + memberId + " AND status='BORROWED'");
        if (rs.next()) currentlyBorrowed = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM borrow_history WHERE member_id=" + memberId);
        if (rs.next()) totalBorrows = rs.getInt(1);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Member Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/memberSidebar.jsp"><jsp:param name="page" value="dashboard"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/memberTopbar.jsp"/>

        <div class="page-content">
            <h1 style="margin-bottom:8px">Welcome, <%= memberName %>!</h1>
            <p style="color:#666; margin-bottom:32px">Here's your library overview</p>

            <!-- Stats -->
            <div class="member-stats">
                <div class="member-stat-card">
                    <div class="stat-icon"><img src="img/icon-books.svg" alt="Books" style="width:28px;height:28px"></div>
                    <div class="stat-number"><%= totalBooks %></div>
                    <div class="stat-label">Total Books</div>
                </div>
                <div class="member-stat-card">
                    <div class="stat-icon"><img src="img/icon-catalog.svg" alt="Available" style="width:28px;height:28px"></div>
                    <div class="stat-number"><%= availableBooks %></div>
                    <div class="stat-label">Available Books</div>
                </div>
                <div class="member-stat-card">
                    <div class="stat-icon"><img src="img/icon-borrowed.svg" alt="Borrowed" style="width:28px;height:28px"></div>
                    <div class="stat-number"><%= currentlyBorrowed %></div>
                    <div class="stat-label">Currently Borrowed</div>
                </div>
                <div class="member-stat-card">
                    <div class="stat-icon"><img src="img/icon-total-borrows.svg" alt="Borrows" style="width:28px;height:28px"></div>
                    <div class="stat-number"><%= totalBorrows %></div>
                    <div class="stat-label">Total Borrows</div>
                </div>
            </div>

            <!-- Recent Borrows -->
            <div class="page-header">
                <h1>Recent Activity</h1>
            </div>
            <div class="data-table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>Borrow Date</th>
                            <th>Return Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        ResultSet rsBorrow = st.executeQuery(
                            "SELECT b.title, bh.borrow_date, bh.return_date, bh.status " +
                            "FROM borrow_history bh JOIN books b ON bh.book_id = b.id " +
                            "WHERE bh.member_id = " + memberId + " ORDER BY bh.borrow_date DESC LIMIT 10");
                        boolean hasRows = false;
                        while (rsBorrow.next()) {
                            hasRows = true;
                            String status = rsBorrow.getString("status");
                    %>
                        <tr>
                            <td><%= rsBorrow.getString("title") %></td>
                            <td><%= rsBorrow.getTimestamp("borrow_date") %></td>
                            <td><%= rsBorrow.getTimestamp("return_date") != null ? rsBorrow.getTimestamp("return_date") : "-" %></td>
                            <td>
                                <span class="<%= "BORROWED".equals(status) ? "status-borrowed" : "status-available" %>">
                                    <%= status %>
                                </span>
                            </td>
                        </tr>
                    <% }
                        if (!hasRows) {
                    %>
                        <tr><td colspan="4" class="text-center" style="padding:40px;color:#999;">No borrow history yet. Start browsing books!</td></tr>
                    <% } %>
                    </tbody>
                </table>
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
            <input type="hidden" name="role" value="member">
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
