<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Sign Up</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
    String error = request.getParameter("error");
    String role = request.getParameter("role");
    if (role == null) role = "member";
%>

<div class="auth-container">
    <!-- Left: Dark Branding Panel -->
    <div class="auth-dark-panel">
        <div class="logo-section">
            <img src="img/logo-white.svg" class="logo-icon" alt="The Archive Co.">
            <div class="brand-name">The Archive Co.</div>
            <div class="brand-sub">Library</div>
        </div>
        <p class="switch-text">Already have an Account? Sign in now.</p>
        <a href="login.jsp?role=<%= role %>" class="btn-switch">SIGN IN</a>
    </div>

    <!-- Right: Form Panel -->
    <div class="auth-light-panel">
        <img src="img/logo.svg" class="form-logo" alt="The Archive Co.">
        <h1>Sign Up</h1>
        <p class="form-subtitle">Please provide your information to sign up.</p>

        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } %>

        <!-- Role Toggle -->
        <div class="auth-role-toggle">
            <button type="button" id="toggleMember" class="<%= "member".equals(role) ? "active" : "" %>" onclick="switchRole('member')">Member</button>
            <button type="button" id="toggleAdmin" class="<%= "admin".equals(role) ? "active" : "" %>" onclick="switchRole('admin')">Admin</button>
        </div>

        <!-- Member Register Form -->
        <form id="memberForm" class="auth-form" action="MemberRegisterServlet" method="post" style="<%= "admin".equals(role) ? "display:none" : "" %>">
            <div class="form-row">
                <div class="form-group"><input type="text" name="firstName" placeholder="First Name" required></div>
                <div class="form-group"><input type="text" name="lastName" placeholder="Last Name" required></div>
            </div>
            <div class="form-row">
                <div class="form-group"><input type="text" name="contactNo" placeholder="Contact No"></div>
                <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
            </div>
            <div class="form-row">
                <div class="form-group"><input type="text" name="username" placeholder="Username" required></div>
                <div class="form-group"><input type="password" name="password" placeholder="Password" required></div>
            </div>
            <button type="submit" class="btn-primary">SIGN UP</button>
        </form>

        <!-- Admin Register Form -->
        <form id="adminForm" class="auth-form" action="AdminRegisterServlet" method="post" style="<%= "admin".equals(role) ? "" : "display:none" %>">
            <div class="form-row">
                <div class="form-group"><input type="text" name="firstName" placeholder="First Name" required></div>
                <div class="form-group"><input type="text" name="lastName" placeholder="Last Name" required></div>
            </div>
            <div class="form-row">
                <div class="form-group"><input type="text" name="contactNo" placeholder="Contact No"></div>
                <div class="form-group"><input type="email" name="email" placeholder="Email" required></div>
            </div>
            <div class="form-row">
                <div class="form-group"><input type="text" name="username" placeholder="Username" required></div>
                <div class="form-group"><input type="password" name="password" placeholder="Password" required></div>
            </div>
            <button type="submit" class="btn-primary">SIGN UP</button>
        </form>
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
