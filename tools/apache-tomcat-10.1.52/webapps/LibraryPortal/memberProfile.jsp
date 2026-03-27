<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp?role=member&error=Please login first");
        return;
    }
    int memberId = (int) session.getAttribute("memberId");
    String memberName = "", memberEmail = "", memberUsername = "", memberJoined = "";
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_portal", "root", "");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM members WHERE id = ?");
        ps.setInt(1, memberId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            memberName = rs.getString("name");
            memberEmail = rs.getString("email");
            memberUsername = rs.getString("username") != null ? rs.getString("username") : memberEmail;
            memberJoined = rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : "N/A";
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | My Profile</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="includes/memberSidebar.jsp"><jsp:param name="page" value="profile"/></jsp:include>

    <div class="main-content">
        <jsp:include page="includes/memberTopbar.jsp"/>

        <div class="page-content">
            <div class="page-header">
                <h1>My Profile</h1>
            </div>

            <div class="profile-section">
                <div class="profile-card">
                    <div class="profile-avatar-section">
                        <div class="profile-avatar"><%= memberName.length() > 0 ? memberName.substring(0, 1).toUpperCase() : "?" %></div>
                        <div>
                            <div class="profile-name"><%= memberName %></div>
                            <div class="profile-role">Member</div>
                        </div>
                    </div>
                    <div class="profile-details">
                        <div class="detail-row">
                            <span class="detail-label">User ID</span>
                            <span class="detail-value"><%= memberId %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Name</span>
                            <span class="detail-value"><%= memberName %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Email</span>
                            <span class="detail-value"><%= memberEmail %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Username</span>
                            <span class="detail-value"><%= memberUsername %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Member Since</span>
                            <span class="detail-value"><%= memberJoined %></span>
                        </div>
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
