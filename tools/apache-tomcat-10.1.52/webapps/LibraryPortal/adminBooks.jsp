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
        // Fetch distinct book types for filters
        Statement stTypes = conn.createStatement();
        ResultSet rsTypes = stTypes.executeQuery("SELECT DISTINCT genre FROM books ORDER BY genre");
        List<String> bookTypes = new ArrayList<>();
        while (rsTypes.next()) {
            String g = rsTypes.getString("genre");
            if (g != null && !g.isEmpty()) bookTypes.add(g);
        }
        rsTypes.close();
        stTypes.close();

        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM books ORDER BY id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Book Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/adminSidebar.jsp"><jsp:param name="page" value="books"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/adminTopbar.jsp"/>

        <div class="page-content">
            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>

            <div class="page-header">
                <h1>Book Management</h1>
                <div class="page-header-actions">
                    <button class="btn-add" onclick="openModal('addBookModal')">
                        <span class="icon"><img src="img/icon-add.svg" alt="Add" style="width:14px;height:14px;vertical-align:middle;filter:invert(1)"></span> Add Book
                    </button>
                    <div class="search-box">
                        <span class="search-icon"><img src="img/icon-search.svg" alt="Search" style="width:16px;height:16px"></span>
                        <input type="text" class="search-input" data-table="booksTable" placeholder="Search by ID or Type">
                    </div>
                </div>
            </div>

            <!-- Type Filters -->
            <div class="tab-buttons" style="margin-bottom:16px;flex-wrap:wrap">
                <button class="tab-btn active" onclick="filterBooksByType(this, 'All')">All</button>
                <% for (String bType : bookTypes) { %>
                    <button class="tab-btn" onclick="filterBooksByType(this, '<%= bType.replace("'","\\'") %>')"><%= bType %></button>
                <% } %>
            </div>

            <div class="data-table-wrapper">
                <table class="data-table" id="booksTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Language</th>
                            <th>Availability</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% while (rs.next()) {
                        int bookId = rs.getInt("id");
                        String title = rs.getString("title");
                        String type = rs.getString("genre");
                        String language = rs.getString("language") != null ? rs.getString("language") : "English";
                        int qty = rs.getInt("quantity");
                        int avail = rs.getInt("available");
                        String author = rs.getString("author");
                        String isbn = rs.getString("isbn");
                    %>
                        <tr>
                            <td><%= bookId %></td>
                            <td><%= title %></td>
                            <td><%= type %></td>
                            <td><%= language %></td>
                            <td>
                                <span class="<%= avail > 0 ? "status-available" : "status-borrowed" %>">
                                    <%= avail > 0 ? "Available" : "Borrowed" %>
                                </span>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <button class="action-btn edit-btn" onclick="populateEditForm('editBookModal', {id:'<%= bookId %>', title:'<%= title.replace("'","\\'") %>', author:'<%= author != null ? author.replace("'","\\'") : "" %>', genre:'<%= type != null ? type.replace("'","\\'") : "" %>', language:'<%= language.replace("'","\\'") %>', quantity:'<%= qty %>', available:'<%= avail %>'})" title="Edit"><img src="img/icon-edit.svg" alt="Edit" style="width:14px;height:14px"></button>
                                    <button class="action-btn delete-btn" onclick="confirmDelete('DeleteBookServlet?id=<%= bookId %>')" title="Delete"><img src="img/icon-delete.svg" alt="Delete" style="width:14px;height:14px"></button>
                                    <button class="action-btn view-btn" onclick="openModal('viewBookModal-<%= bookId %>')" title="View"><img src="img/icon-view.svg" alt="View" style="width:14px;height:14px"></button>
                                </div>
                            </td>
                        </tr>

                        <!-- View Book Modal for this row -->
                        <div class="modal-overlay" id="viewBookModal-<%= bookId %>">
                            <div class="modal">
                                <div class="modal-header">
                                    <h2><span class="modal-icon"><img src="img/icon-books.svg" alt="Books" style="width:20px;height:20px;vertical-align:middle"></span> View Book</h2>
                                    <button class="modal-close">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <div class="view-meta">
                                        <div class="view-details">
                                            <div class="detail-row"><span class="detail-label">Book ID :</span><span class="detail-value"><%= bookId %></span></div>
                                            <div class="detail-row"><span class="detail-label">Name :</span><span class="detail-value"><%= title %></span></div>
                                            <div class="detail-row"><span class="detail-label">Type :</span><span class="detail-value"><%= type %></span></div>
                                            <div class="detail-row"><span class="detail-label">Language :</span><span class="detail-value"><%= language %></span></div>
                                        </div>
                                        <div class="view-saved-by">
                                            Saved by :<br>
                                            <strong><%= session.getAttribute("adminName") %></strong>
                                            (Admin)
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn-confirm" onclick="closeModal('viewBookModal-<%= bookId %>')">CLOSE</button>
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

<!-- Add Book Modal -->
<div class="modal-overlay" id="addBookModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-books.svg" alt="Books" style="width:20px;height:20px;vertical-align:middle"></span> Add Book</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="AddBookServlet" method="post">
            <div class="modal-body">
                <div class="form-group">
                    <input type="text" name="title" placeholder="Name" required>
                </div>
                <div class="form-group">
                    <input type="text" name="language" placeholder="Language" value="English">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <input type="text" name="genre" placeholder="Type" required>
                    </div>
                    <div class="form-group">
                        <input type="number" name="quantity" placeholder="Quantity" value="1" min="1" required>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel">CANCEL</button>
                <button type="submit" class="btn-confirm">ADD</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Book Modal -->
<div class="modal-overlay" id="editBookModal">
    <div class="modal">
        <div class="modal-header">
            <h2><span class="modal-icon"><img src="img/icon-books.svg" alt="Books" style="width:20px;height:20px;vertical-align:middle"></span> Update Book</h2>
            <button class="modal-close">&times;</button>
        </div>
        <form action="UpdateBookServlet" method="post">
            <input type="hidden" name="id">
            <div class="modal-body">
                <div class="form-group">
                    <input type="text" name="title" placeholder="Name" required>
                </div>
                <div class="form-group">
                    <input type="text" name="language" placeholder="Language">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <input type="text" name="genre" placeholder="Type" required>
                    </div>
                    <div class="form-group">
                        <input type="number" name="quantity" placeholder="Quantity" min="1" required>
                    </div>
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
<script>
function filterBooksByType(btn, type) {
    // Update active button
    var buttons = btn.parentElement.querySelectorAll('.tab-btn');
    buttons.forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');

    // Filter table rows
    var rows = document.querySelectorAll('#booksTable tbody tr');
    rows.forEach(function(row) {
        if (type === 'All') {
            row.style.display = '';
        } else {
            var typeCell = row.querySelectorAll('td')[2]; // Type is the 3rd column
            if (typeCell && typeCell.textContent.trim() === type) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
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
