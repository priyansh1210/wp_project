<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp?role=member&error=Please login first");
        return;
    }
    int memberId = (int) session.getAttribute("memberId");
    String memberName = "", memberEmail = "", memberUsername = "", memberJoined = "", photoDataUrl = "";
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
            byte[] img = rs.getBytes("profile_image");
            String mime = rs.getString("image_type");
            if (img != null && img.length > 0) {
                if (mime == null || mime.isEmpty()) mime = "image/jpeg";
                photoDataUrl = "data:" + mime + ";base64," + java.util.Base64.getEncoder().encodeToString(img);
            }
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

            <!-- Virtual ID Card -->
            <div style="margin-bottom:24px">
                <div style="max-width:420px;background:linear-gradient(135deg,#111 0%,#333 100%);color:#fff;border-radius:12px;padding:20px;box-shadow:0 4px 16px rgba(0,0,0,0.15)">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.2);padding-bottom:10px">
                        <div style="font-size:11px;letter-spacing:2px;opacity:0.7">THE ARCHIVE CO.</div>
                        <div style="font-size:11px;letter-spacing:1px;opacity:0.7">MEMBER ID</div>
                    </div>
                    <div style="display:flex;gap:16px;align-items:center">
                        <div style="width:90px;height:110px;border-radius:6px;overflow:hidden;background:#555;flex-shrink:0;border:2px solid rgba(255,255,255,0.3)">
                            <% if (!photoDataUrl.isEmpty()) { %>
                                <img src="<%= photoDataUrl %>" alt="Photo" style="width:100%;height:100%;object-fit:cover">
                            <% } else { %>
                                <div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px;color:#fff"><%= memberName.length() > 0 ? memberName.substring(0,1).toUpperCase() : "?" %></div>
                            <% } %>
                        </div>
                        <div style="flex:1;min-width:0">
                            <div style="font-size:11px;opacity:0.6;letter-spacing:1px">NAME</div>
                            <div style="font-size:16px;font-weight:600;margin-bottom:8px;word-break:break-word"><%= memberName %></div>
                            <div style="font-size:11px;opacity:0.6;letter-spacing:1px">USER ID</div>
                            <div style="font-size:14px;font-weight:500;margin-bottom:8px">#<%= String.format("%06d", memberId) %></div>
                            <div style="font-size:11px;opacity:0.6;letter-spacing:1px">REGISTERED</div>
                            <div style="font-size:12px;font-weight:500"><%= memberJoined %></div>
                        </div>
                    </div>
                </div>
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
