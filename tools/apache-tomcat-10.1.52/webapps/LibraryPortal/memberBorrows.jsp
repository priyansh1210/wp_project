<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp?role=member&error=Please login first");
        return;
    }
    int memberId = (int) session.getAttribute("memberId");
    String msg = request.getParameter("msg");
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
    <title>The Archive Co. | My Borrows</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/memberSidebar.jsp"><jsp:param name="page" value="borrows"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/memberTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <!-- Tabs -->
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:24px;">
                <div class="tab-buttons">
                    <button class="tab-btn active" data-tab-group="borrows" data-tab-target="currentPanel">Currently Borrowed</button>
                    <button class="tab-btn" data-tab-group="borrows" data-tab-target="historyPanel">History</button>
                </div>
                <div class="search-box">
                    <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                    <input type="text" class="search-input" data-table="borrowsTable" placeholder="Search">
                </div>
            </div>

            <!-- Currently Borrowed -->
            <div class="tab-panel" id="currentPanel" data-tab-group="borrows">
                <div class="data-table-wrapper">
                    <table class="data-table" id="borrowsTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Book</th>
                                <th>Borrow Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            ResultSet rsCurrent = st.executeQuery(
                                "SELECT bh.id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.status, bh.reject_message, " +
                                "(bh.due_date IS NOT NULL AND bh.due_date < NOW()) AS is_overdue " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id " +
                                "WHERE bh.member_id = " + memberId + " AND bh.status IN ('BORROWED','RETURN_PENDING','REJECTED') " +
                                "ORDER BY bh.borrow_date DESC");
                            boolean hasCurrent = false;
                            while (rsCurrent.next()) {
                                hasCurrent = true;
                                boolean overdue = rsCurrent.getBoolean("is_overdue");
                                String cStatus = rsCurrent.getString("status");
                                String rejectMsg = rsCurrent.getString("reject_message");
                        %>
                            <tr>
                                <td><%= rsCurrent.getInt("id") %></td>
                                <td><%= rsCurrent.getString("title") %></td>
                                <td><%= rsCurrent.getTimestamp("borrow_date") %></td>
                                <td><%= rsCurrent.getTimestamp("due_date") != null ? rsCurrent.getTimestamp("due_date") : "-" %></td>
                                <td>
                                    <% if ("RETURN_PENDING".equals(cStatus)) { %>
                                        <span class="status-pending">Return Requested</span>
                                    <% } else if ("REJECTED".equals(cStatus)) { %>
                                        <span class="status-overdue">Return Rejected</span>
                                    <% } else if (overdue) { %>
                                        <span class="status-overdue">Overdue</span>
                                    <% } else { %>
                                        <span class="status-borrowed">Borrowed</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("RETURN_PENDING".equals(cStatus)) { %>
                                        <button class="btn-add" style="padding:6px 16px;font-size:12px;opacity:0.5" disabled>Return Requested</button>
                                    <% } else if ("REJECTED".equals(cStatus)) { %>
                                        <div style="font-size:11px;color:#b00;margin-bottom:4px" title="<%= rejectMsg %>"><strong>Rejected:</strong> <%= rejectMsg %></div>
                                        <form action="ReturnBookServlet" method="post" style="display:inline">
                                            <input type="hidden" name="borrowId" value="<%= rsCurrent.getInt("id") %>">
                                            <button type="submit" class="btn-add" style="padding:6px 16px;font-size:12px">Request Again</button>
                                        </form>
                                    <% } else { %>
                                        <form action="ReturnBookServlet" method="post" style="display:inline">
                                            <input type="hidden" name="borrowId" value="<%= rsCurrent.getInt("id") %>">
                                            <button type="submit" class="btn-add" style="padding:6px 16px;font-size:12px">Return</button>
                                        </form>
                                    <% } %>
                                </td>
                            </tr>
                        <% }
                            if (!hasCurrent) {
                        %>
                            <tr><td colspan="6" class="text-center" style="padding:40px;color:#999;">No books currently borrowed</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- History -->
            <div class="tab-panel hidden" id="historyPanel" data-tab-group="borrows">
                <div class="data-table-wrapper">
                    <table class="data-table" id="historyTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Book</th>
                                <th>Borrow Date</th>
                                <th>Due Date</th>
                                <th>Return Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Statement st2 = conn.createStatement();
                            ResultSet rsHist = st2.executeQuery(
                                "SELECT bh.id, COALESCE(b.title, '[Removed Book]') AS title, bh.borrow_date, bh.due_date, bh.return_date, bh.status, " +
                                "(bh.status='BORROWED' AND bh.due_date IS NOT NULL AND bh.due_date < NOW()) AS is_overdue " +
                                "FROM borrow_history bh LEFT JOIN books b ON bh.book_id = b.id " +
                                "WHERE bh.member_id = " + memberId + " ORDER BY bh.borrow_date DESC");
                            boolean hasHist = false;
                            while (rsHist.next()) {
                                hasHist = true;
                                String status = rsHist.getString("status");
                                boolean overdue = rsHist.getBoolean("is_overdue");
                                String label, cls;
                                if ("RETURN_PENDING".equals(status)) { label = "Return Requested"; cls = "status-pending"; }
                                else if ("REJECTED".equals(status)) { label = "Return Rejected"; cls = "status-overdue"; }
                                else if (overdue) { label = "Overdue"; cls = "status-overdue"; }
                                else if ("BORROWED".equals(status)) { label = "Borrowed"; cls = "status-borrowed"; }
                                else { label = "Returned"; cls = "status-available"; }
                        %>
                            <tr>
                                <td><%= rsHist.getInt("id") %></td>
                                <td><%= rsHist.getString("title") %></td>
                                <td><%= rsHist.getTimestamp("borrow_date") %></td>
                                <td><%= rsHist.getTimestamp("due_date") != null ? rsHist.getTimestamp("due_date") : "-" %></td>
                                <td><%= rsHist.getTimestamp("return_date") != null ? rsHist.getTimestamp("return_date") : "-" %></td>
                                <td><span class="<%= cls %>"><%= label %></span></td>
                            </tr>
                        <% }
                            if (!hasHist) {
                        %>
                            <tr><td colspan="6" class="text-center" style="padding:40px;color:#999;">No borrow history</td></tr>
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
