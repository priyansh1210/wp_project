<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Sign In</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    String role = request.getParameter("role");
    if (role == null) role = "member";
%>

<div class="auth-container">
    <!-- Left: Form Panel -->
    <div class="auth-light-panel">
        <img src="img/logo.svg" class="form-logo" alt="The Archive Co." style="color:#000">
        <h1>Welcome Back !!</h1>
        <p class="form-subtitle">Please enter your credentials to log in</p>

        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <div class="alert alert-success"><%= success %></div>
        <% } %>

        <!-- Role Toggle -->
        <div class="auth-role-toggle">
            <button type="button" id="toggleMember" class="<%= "member".equals(role) ? "active" : "" %>" onclick="switchRole('member')">Member</button>
            <button type="button" id="toggleAdmin" class="<%= "admin".equals(role) ? "active" : "" %>" onclick="switchRole('admin')">Admin</button>
        </div>

        <!-- Member Login Form -->
        <form id="memberForm" class="auth-form" action="MemberLoginServlet" method="post" style="<%= "admin".equals(role) ? "display:none" : "" %>">
            <div class="form-group">
                <input type="text" name="username" placeholder="Username" required>
            </div>
            <div class="form-group">
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <a href="forgotPassword.jsp?role=member" class="forgot-link">Forgot password?</a>
            <button type="submit" class="btn-primary">SIGN IN</button>
        </form>

        <!-- Admin Login Form -->
        <form id="adminForm" class="auth-form" action="AdminLoginServlet" method="post" style="<%= "admin".equals(role) ? "" : "display:none" %>">
            <div class="form-group">
                <input type="text" name="username" placeholder="Username" required>
            </div>
            <div class="form-group">
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <a href="forgotPassword.jsp?role=admin" class="forgot-link">Forgot password?</a>
            <button type="submit" class="btn-primary">SIGN IN</button>
        </form>
    </div>

    <!-- Right: Dark Branding Panel -->
    <div class="auth-dark-panel">
        <div class="logo-section">
            <img src="img/logo-white.svg" class="logo-icon" alt="The Archive Co.">
            <div class="brand-name">The Archive Co.</div>
            <div class="brand-sub">Library</div>
        </div>
        <p class="switch-text">New to our platform? Sign up now.</p>
        <a href="register.jsp?role=<%= role %>" class="btn-switch">SIGN UP</a>
    </div>
</div>

<script>
function switchRole(role) {
    document.getElementById('memberForm').style.display = role === 'member' ? '' : 'none';
    document.getElementById('adminForm').style.display = role === 'admin' ? '' : 'none';
    document.getElementById('toggleMember').className = role === 'member' ? 'active' : '';
    document.getElementById('toggleAdmin').className = role === 'admin' ? 'active' : '';
}
</script>
<script src="js/main.js"></script>
</body>
</html>
