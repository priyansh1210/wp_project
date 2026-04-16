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

        // Get distinct genres for filter pills
        ResultSet rsGenres = st.executeQuery("SELECT DISTINCT genre FROM books WHERE genre IS NOT NULL AND genre != '' ORDER BY genre");
        List<String> genres = new ArrayList<>();
        while (rsGenres.next()) genres.add(rsGenres.getString("genre"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Browse Books</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/memberSidebar.jsp"><jsp:param name="page" value="books"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/memberTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <div class="page-header">
                <h1>Browse Books</h1>
                <div class="search-box">
                    <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:18px;height:18px"></span>
                    <input type="text" id="bookSearch" placeholder="Search books..." oninput="searchBooks()">
                </div>
            </div>

            <!-- Genre Filter Pills -->
            <div class="genre-filters">
                <button class="genre-pill active" data-genre="all">All</button>
                <% for (String genre : genres) { %>
                    <button class="genre-pill" data-genre="<%= genre %>"><%= genre %></button>
                <% } %>
            </div>

            <!-- Book Cards Grid -->
            <div class="book-grid" id="bookGrid">
            <%
                ResultSet rsBooks = st.executeQuery("SELECT * FROM books ORDER BY title");
                while (rsBooks.next()) {
                    int bookId = rsBooks.getInt("id");
                    String title = rsBooks.getString("title");
                    String genre = rsBooks.getString("genre") != null ? rsBooks.getString("genre") : "";
                    String language = rsBooks.getString("language") != null ? rsBooks.getString("language") : "English";
                    String author = rsBooks.getString("author") != null ? rsBooks.getString("author") : "";
                    int available = rsBooks.getInt("available");
            %>
                <div class="book-card" data-genre="<%= genre %>" data-title="<%= title.toLowerCase() %>">
                    <div class="book-icon"><img src="img/icon-open-book.svg" alt="Book" style="width:32px;height:32px"></div>
                    <div class="book-title"><%= title %></div>
                    <div class="book-meta">
                        <span><%= genre %></span>
                        <span><%= language %></span>
                        <% if (!author.isEmpty()) { %><span>by <%= author %></span><% } %>
                    </div>
                    <span class="book-availability <%= available > 0 ? "available" : "unavailable" %>">
                        <%= available > 0 ? "Available (" + available + ")" : "Not Available" %>
                    </span>
                    <form action="BorrowBookServlet" method="post" style="margin-top:8px">
                        <input type="hidden" name="bookId" value="<%= bookId %>">
                        <% if (available > 0) { %>
                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;font-size:12px;color:#555">
                            <label for="days-<%= bookId %>">Days:</label>
                            <input type="number" id="days-<%= bookId %>" name="days" min="1" max="30" value="14" required style="width:60px;padding:4px 6px;border:1px solid #ccc;border-radius:4px">
                            <span style="color:#999">(1-30)</span>
                        </div>
                        <% } %>
                        <button type="submit" class="btn-borrow" <%= available <= 0 ? "disabled" : "" %>>
                            <%= available > 0 ? "BORROW" : "UNAVAILABLE" %>
                        </button>
                    </form>
                </div>
            <% } %>
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
<script>
function searchBooks() {
    var query = document.getElementById('bookSearch').value.toLowerCase();
    document.querySelectorAll('.book-card').forEach(function(card) {
        var title = card.getAttribute('data-title');
        card.style.display = title.includes(query) ? '' : 'none';
    });
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
