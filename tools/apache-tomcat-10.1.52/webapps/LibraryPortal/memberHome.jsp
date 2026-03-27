<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.io.*, java.util.Base64" %>
<%
    // Session check
    if (session.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    int memberId = (int) session.getAttribute("memberId");
    String memberName = (String) session.getAttribute("memberName");
    String memberEmail = (String) session.getAttribute("memberEmail");
    String memberJoined = (String) session.getAttribute("memberJoined");

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
    } catch(Exception e) { e.printStackTrace(); }

    // Get profile image
    String profileImgSrc = "";
    if (conn != null) {
        PreparedStatement ps = conn.prepareStatement("SELECT profile_image, image_type FROM members WHERE id=?");
        ps.setInt(1, memberId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            byte[] imgData = rs.getBytes("profile_image");
            String imgType = rs.getString("image_type");
            if (imgData != null && imgData.length > 0) {
                profileImgSrc = "data:" + imgType + ";base64," + Base64.getEncoder().encodeToString(imgData);
            }
        }
        rs.close(); ps.close();
    }

    // Get all books
    List<Map<String, String>> books = new ArrayList<>();
    Set<String> genres = new TreeSet<>();
    if (conn != null) {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM books ORDER BY title");
        while (rs.next()) {
            Map<String, String> book = new HashMap<>();
            book.put("id", rs.getString("id"));
            book.put("title", rs.getString("title"));
            book.put("author", rs.getString("author"));
            book.put("isbn", rs.getString("isbn"));
            book.put("genre", rs.getString("genre"));
            book.put("quantity", rs.getString("quantity"));
            book.put("available", rs.getString("available"));
            books.add(book);
            if (rs.getString("genre") != null) genres.add(rs.getString("genre"));
        }
        rs.close(); st.close();
    }

    // Get borrow history
    List<Map<String, String>> history = new ArrayList<>();
    int borrowedCount = 0;
    if (conn != null) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT bh.*, b.title, b.author FROM borrow_history bh JOIN books b ON bh.book_id = b.id WHERE bh.member_id=? ORDER BY bh.borrow_date DESC"
        );
        ps.setInt(1, memberId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> h = new HashMap<>();
            h.put("id", rs.getString("id"));
            h.put("title", rs.getString("title"));
            h.put("author", rs.getString("author"));
            h.put("borrowDate", rs.getString("borrow_date"));
            h.put("returnDate", rs.getString("return_date") != null ? rs.getString("return_date") : "-");
            h.put("status", rs.getString("status"));
            history.add(h);
            if ("BORROWED".equals(rs.getString("status"))) borrowedCount++;
        }
        rs.close(); ps.close();
    }

    if (conn != null) conn.close();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | My Library</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="floating-books"></div>

    <!-- HEADER -->
    <header class="header">
        <a href="memberHome.jsp" class="logo">
            <span class="logo-icon">&#128218;</span>
            <span class="logo-text">The Archive <span>Co.</span></span>
        </a>
        <div class="nav-actions">
            <span style="color: var(--text-muted); font-size: 0.9rem;">&#128075; Hello, <strong style="color: var(--accent);"><%= memberName %></strong></span>
            <a href="LogoutServlet" class="btn btn-glass">&#128682; Logout</a>
        </div>
    </header>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="dashboard">

            <% String msg = request.getParameter("success"); %>
            <% String err = request.getParameter("error"); %>
            <% if (msg != null) { %><div class="alert alert-success">&#9989; <%= msg %></div><% } %>
            <% if (err != null) { %><div class="alert alert-error">&#10060; <%= err %></div><% } %>

            <!-- PROFILE + STATS -->
            <div class="profile-section">
                <div class="glass-card profile-card">
                    <div class="profile-avatar">
                        <% if (!profileImgSrc.isEmpty()) { %>
                            <img src="<%= profileImgSrc %>" alt="Profile">
                        <% } else { %>
                            <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:3rem;background:rgba(201,168,76,0.1);border-radius:50%;">&#128100;</div>
                        <% } %>
                    </div>
                    <h2 class="profile-name"><%= memberName %></h2>
                    <p class="profile-email"><%= memberEmail %></p>
                    <p class="profile-joined">&#128197; Joined: <%= memberJoined != null ? memberJoined.substring(0, 10) : "N/A" %></p>
                </div>

                <div class="profile-stats">
                    <div class="stats-grid">
                        <div class="glass-card stat-card">
                            <span class="stat-icon">&#128218;</span>
                            <span class="stat-number"><%= books.size() %></span>
                            <span class="stat-label">Total Books</span>
                        </div>
                        <div class="glass-card stat-card">
                            <span class="stat-icon">&#128214;</span>
                            <span class="stat-number"><%= borrowedCount %></span>
                            <span class="stat-label">Currently Borrowed</span>
                        </div>
                        <div class="glass-card stat-card">
                            <span class="stat-icon">&#128203;</span>
                            <span class="stat-number"><%= history.size() %></span>
                            <span class="stat-label">Total Borrows</span>
                        </div>
                        <div class="glass-card stat-card">
                            <span class="stat-icon">&#127775;</span>
                            <span class="stat-number"><%= genres.size() %></span>
                            <span class="stat-label">Genres</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 3D BOOK CAROUSEL -->
            <h2 class="section-title">&#128218; Explore Books</h2>

            <!-- Genre Filter Pills -->
            <div class="genre-pills">
                <button class="genre-pill active" data-genre="">All Genres</button>
                <% for (String g : genres) { %>
                    <button class="genre-pill" data-genre="<%= g %>"><%= g %></button>
                <% } %>
            </div>

            <% if (!books.isEmpty()) { %>
            <div class="carousel-section">
                <div class="carousel-container">
                    <div class="carousel-track">
                        <% for (Map<String, String> book : books) {
                            int avail = Integer.parseInt(book.get("available"));
                        %>
                        <div class="carousel-card" data-title="<%= book.get("title") %>" data-author="<%= book.get("author") %>" data-genre="<%= book.get("genre") %>">
                            <div>
                                <span class="card-genre"><%= book.get("genre") %></span>
                                <h3 class="card-title"><%= book.get("title") %></h3>
                                <p class="card-author">by <%= book.get("author") %></p>
                            </div>
                            <div class="card-meta">
                                <span class="card-isbn">ISBN: <%= book.get("isbn") %></span>
                                <span class="card-avail <%= avail > 0 ? "available" : "unavailable" %>">
                                    <%= avail > 0 ? avail + " available" : "Unavailable" %>
                                </span>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <p class="carousel-hint">&#8592; Drag to explore the collection &#8594;</p>
            </div>
            <% } else { %>
                <div class="empty-state glass-card">
                    <div class="empty-icon">&#128218;</div>
                    <p>No books in the library yet. Check back soon!</p>
                </div>
            <% } %>

            <!-- BORROWING HISTORY -->
            <h2 class="section-title">&#128203; My Borrowing History</h2>

            <% if (!history.isEmpty()) { %>
            <div class="glass-card table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Book Title</th>
                            <th>Author</th>
                            <th>Borrow Date</th>
                            <th>Return Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int idx = 1; for (Map<String, String> h : history) { %>
                        <tr>
                            <td><%= idx++ %></td>
                            <td><%= h.get("title") %></td>
                            <td><%= h.get("author") %></td>
                            <td><%= h.get("borrowDate") != null ? h.get("borrowDate").substring(0, 10) : "-" %></td>
                            <td><%= !"-".equals(h.get("returnDate")) ? h.get("returnDate").substring(0, 10) : "-" %></td>
                            <td><span class="status-badge <%= "BORROWED".equals(h.get("status")) ? "borrowed" : "returned" %>"><%= h.get("status") %></span></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
                <div class="empty-state glass-card">
                    <div class="empty-icon">&#128203;</div>
                    <p>You haven't borrowed any books yet. Explore our collection above!</p>
                </div>
            <% } %>

        </div>
    </div>

    <!-- FOOTER -->
    <footer class="footer">
        <p class="footer-quote">"So many books, so little time." - Frank Zappa</p>
        <p>&copy; 2025 The Archive Co. Library Portal | MIT Bengaluru</p>
    </footer>

    <script src="js/main.js"></script>
</body>
</html>
