<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.io.*, java.util.Base64" %>
<%
    // Session check
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("login.jsp?error=Please login as admin first");
        return;
    }
    int adminId = (int) session.getAttribute("adminId");
    String adminName = (String) session.getAttribute("adminName");
    String adminEmail = (String) session.getAttribute("adminEmail");

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
    } catch(Exception e) { e.printStackTrace(); }

    // Get admin profile image
    String adminImgSrc = "";
    if (conn != null) {
        PreparedStatement ps = conn.prepareStatement("SELECT profile_image, image_type FROM admin WHERE id=?");
        ps.setInt(1, adminId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            byte[] imgData = rs.getBytes("profile_image");
            String imgType = rs.getString("image_type");
            if (imgData != null && imgData.length > 0) {
                adminImgSrc = "data:" + imgType + ";base64," + Base64.getEncoder().encodeToString(imgData);
            }
        }
        rs.close(); ps.close();
    }

    // Get all members
    List<Map<String, String>> members = new ArrayList<>();
    if (conn != null) {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT id, name, email, created_at, profile_image, image_type FROM members ORDER BY created_at DESC");
        while (rs.next()) {
            Map<String, String> m = new HashMap<>();
            m.put("id", rs.getString("id"));
            m.put("name", rs.getString("name"));
            m.put("email", rs.getString("email"));
            m.put("created_at", rs.getString("created_at"));
            byte[] imgData = rs.getBytes("profile_image");
            String imgType = rs.getString("image_type");
            if (imgData != null && imgData.length > 0) {
                m.put("image", "data:" + imgType + ";base64," + Base64.getEncoder().encodeToString(imgData));
            } else {
                m.put("image", "");
            }
            members.add(m);
        }
        rs.close(); st.close();
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

    // Stats
    int totalBorrowed = 0;
    if (conn != null) {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT COUNT(*) as cnt FROM borrow_history WHERE status='BORROWED'");
        if (rs.next()) totalBorrowed = rs.getInt("cnt");
        rs.close(); st.close();
    }

    if (conn != null) conn.close();
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
    <div class="floating-books"></div>

    <!-- HEADER -->
    <header class="header">
        <a href="adminHome.jsp" class="logo">
            <span class="logo-icon">&#128218;</span>
            <span class="logo-text">The Archive <span>Co.</span></span>
        </a>
        <div class="nav-actions">
            <span style="color: var(--text-muted); font-size: 0.9rem;">&#128737;&#65039; Admin: <strong style="color: var(--accent);"><%= adminName %></strong></span>
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

            <div class="dashboard-header">
                <div>
                    <h1>&#128737;&#65039; Admin Dashboard</h1>
                    <p class="welcome-text">Manage your library universe, <%= adminName %></p>
                </div>
                <button class="btn btn-primary btn-lg" onclick="openModal('addBookModal')">&#10133; Add New Book</button>
            </div>

            <!-- STATS -->
            <div class="stats-grid">
                <div class="glass-card stat-card">
                    <span class="stat-icon">&#128218;</span>
                    <span class="stat-number"><%= books.size() %></span>
                    <span class="stat-label">Total Books</span>
                </div>
                <div class="glass-card stat-card">
                    <span class="stat-icon">&#128101;</span>
                    <span class="stat-number"><%= members.size() %></span>
                    <span class="stat-label">Members</span>
                </div>
                <div class="glass-card stat-card">
                    <span class="stat-icon">&#128214;</span>
                    <span class="stat-number"><%= totalBorrowed %></span>
                    <span class="stat-label">Active Borrows</span>
                </div>
                <div class="glass-card stat-card">
                    <span class="stat-icon">&#127775;</span>
                    <span class="stat-number"><%= genres.size() %></span>
                    <span class="stat-label">Genres</span>
                </div>
            </div>

            <!-- MEMBERS TABLE -->
            <h2 class="section-title">&#128101; Registered Members</h2>

            <div class="toolbar">
                <div class="search-box">
                    <input type="text" data-table-search="membersTable" placeholder="Search members...">
                </div>
            </div>

            <% if (!members.isEmpty()) { %>
            <div class="glass-card table-container">
                <table class="data-table" id="membersTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Member</th>
                            <th>Email</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int idx = 1; for (Map<String, String> m : members) { %>
                        <tr>
                            <td><%= idx++ %></td>
                            <td>
                                <% if (!m.get("image").isEmpty()) { %>
                                    <img src="<%= m.get("image") %>" class="member-avatar-sm" alt="">
                                <% } else { %>
                                    <span style="margin-right:8px;">&#128100;</span>
                                <% } %>
                                <%= m.get("name") %>
                            </td>
                            <td><%= m.get("email") %></td>
                            <td><%= m.get("created_at") != null ? m.get("created_at").substring(0, 10) : "N/A" %></td>
                            <td class="actions">
                                <button class="btn btn-info btn-sm" onclick="openEditMember('<%= m.get("id") %>', '<%= m.get("name").replace("'", "\\'") %>', '<%= m.get("email").replace("'", "\\'") %>')">&#9997;&#65039; Edit</button>
                                <button class="btn btn-danger btn-sm" onclick="confirmDelete('DeleteMemberServlet?id=<%= m.get("id") %>', '<%= m.get("name").replace("'", "\\'") %>')">&#128465;&#65039; Delete</button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
                <div class="empty-state glass-card">
                    <div class="empty-icon">&#128101;</div>
                    <p>No members registered yet.</p>
                </div>
            <% } %>

            <!-- BOOKS TABLE -->
            <h2 class="section-title">&#128218; Library Books</h2>

            <div class="toolbar">
                <div class="search-box">
                    <input type="text" data-table-search="booksTable" placeholder="Search books...">
                </div>
            </div>

            <% if (!books.isEmpty()) { %>
            <div class="glass-card table-container">
                <table class="data-table" id="booksTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>ISBN</th>
                            <th>Genre</th>
                            <th>Qty</th>
                            <th>Available</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int bidx = 1; for (Map<String, String> book : books) { %>
                        <tr>
                            <td><%= bidx++ %></td>
                            <td><%= book.get("title") %></td>
                            <td><%= book.get("author") %></td>
                            <td style="font-size:0.8rem;opacity:0.6;"><%= book.get("isbn") %></td>
                            <td><span class="book-genre" style="margin:0;"><%= book.get("genre") %></span></td>
                            <td><%= book.get("quantity") %></td>
                            <td><%= book.get("available") %></td>
                            <td class="actions">
                                <button class="btn btn-info btn-sm" onclick="openEditBook('<%= book.get("id") %>', '<%= book.get("title").replace("'", "\\'") %>', '<%= book.get("author").replace("'", "\\'") %>', '<%= book.get("isbn") %>', '<%= book.get("genre") %>', '<%= book.get("quantity") %>', '<%= book.get("available") %>')">&#9997;&#65039; Edit</button>
                                <button class="btn btn-danger btn-sm" onclick="confirmDelete('DeleteBookServlet?id=<%= book.get("id") %>', '<%= book.get("title").replace("'", "\\'") %>')">&#128465;&#65039; Delete</button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
                <div class="empty-state glass-card">
                    <div class="empty-icon">&#128218;</div>
                    <p>No books in the library. Add your first book above!</p>
                </div>
            <% } %>

        </div>
    </div>

    <!-- ADD BOOK MODAL -->
    <div class="modal-overlay" id="addBookModal">
        <div class="glass-card modal">
            <h2>&#10133; Add New Book</h2>
            <form action="AddBookServlet" method="post" data-validate>
                <div class="form-group" data-required>
                    <label>Book Title</label>
                    <input type="text" name="title" placeholder="Enter book title">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Author</label>
                    <input type="text" name="author" placeholder="Enter author name">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group">
                    <label>ISBN</label>
                    <input type="text" name="isbn" placeholder="e.g. 978-0000000000">
                </div>
                <div class="form-group" data-required>
                    <label>Genre</label>
                    <input type="text" name="genre" placeholder="e.g. Fiction, Sci-Fi, Technology">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Quantity</label>
                    <input type="number" name="quantity" min="1" value="1" placeholder="Number of copies">
                    <span class="error-msg"></span>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-glass" onclick="closeModal('addBookModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">&#10133; Add Book</button>
                </div>
            </form>
        </div>
    </div>

    <!-- EDIT BOOK MODAL -->
    <div class="modal-overlay" id="editBookModal">
        <div class="glass-card modal">
            <h2>&#9997;&#65039; Edit Book</h2>
            <form action="UpdateBookServlet" method="post" data-validate>
                <input type="hidden" name="id" id="editBookId">
                <div class="form-group" data-required>
                    <label>Book Title</label>
                    <input type="text" name="title" id="editBookTitle" placeholder="Enter book title">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Author</label>
                    <input type="text" name="author" id="editBookAuthor" placeholder="Enter author name">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group">
                    <label>ISBN</label>
                    <input type="text" name="isbn" id="editBookIsbn" placeholder="e.g. 978-0000000000">
                </div>
                <div class="form-group" data-required>
                    <label>Genre</label>
                    <input type="text" name="genre" id="editBookGenre" placeholder="e.g. Fiction, Sci-Fi">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Quantity</label>
                    <input type="number" name="quantity" id="editBookQty" min="0" placeholder="Total copies">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Available</label>
                    <input type="number" name="available" id="editBookAvail" min="0" placeholder="Available copies">
                    <span class="error-msg"></span>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-glass" onclick="closeModal('editBookModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">&#128190; Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <!-- EDIT MEMBER MODAL -->
    <div class="modal-overlay" id="editMemberModal">
        <div class="glass-card modal">
            <h2>&#9997;&#65039; Edit Member</h2>
            <form action="UpdateMemberServlet" method="post" data-validate>
                <input type="hidden" name="id" id="editMemberId">
                <div class="form-group" data-required>
                    <label>Full Name</label>
                    <input type="text" name="name" id="editMemberName" placeholder="Member name">
                    <span class="error-msg"></span>
                </div>
                <div class="form-group" data-required>
                    <label>Email</label>
                    <input type="email" name="email" id="editMemberEmail" placeholder="Member email">
                    <span class="error-msg"></span>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-glass" onclick="closeModal('editMemberModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">&#128190; Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <!-- FOOTER -->
    <footer class="site-footer">
        <div class="footer-content">
            <div class="footer-left">
                <img src="img/logo.svg" alt="The Archive Co." class="footer-logo">
                <span class="footer-brand">The Archive Co.</span>
            </div>
            <div class="footer-center">
                &copy; <%= java.time.Year.now().getValue() %> The Archive Co. Library Portal. All rights reserved.
            </div>
            <div class="footer-right">
                Built for WP Lab Project &mdash; Harshika Bansal
            </div>
        </div>
    </footer>

    <script src="js/main.js"></script>
    <script>
        function openEditBook(id, title, author, isbn, genre, qty, avail) {
            document.getElementById('editBookId').value = id;
            document.getElementById('editBookTitle').value = title;
            document.getElementById('editBookAuthor').value = author;
            document.getElementById('editBookIsbn').value = isbn;
            document.getElementById('editBookGenre').value = genre;
            document.getElementById('editBookQty').value = qty;
            document.getElementById('editBookAvail').value = avail;
            openModal('editBookModal');
        }

        function openEditMember(id, name, email) {
            document.getElementById('editMemberId').value = id;
            document.getElementById('editMemberName').value = name;
            document.getElementById('editMemberEmail').value = email;
            openModal('editMemberModal');
        }
    </script>
</body>
</html>
