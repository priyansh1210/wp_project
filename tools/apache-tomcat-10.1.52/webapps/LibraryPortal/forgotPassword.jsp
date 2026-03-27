<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Archive Co. | Forgot Password</title>
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
        <p class="tagline">"Your premier digital library<br>for borrowing and reading<br>books"</p>
    </div>

    <!-- Right: Form Panel -->
    <div class="auth-light-panel">
        <a href="login.jsp?role=<%= role %>" class="back-btn">BACK</a>

        <img src="img/logo.svg" class="form-logo" alt="The Archive Co.">
        <h1>Forgot Password</h1>
        <p class="form-subtitle">Please enter your username</p>

        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } %>

        <form class="auth-form" action="ForgotPasswordServlet" method="post">
            <input type="hidden" name="role" value="<%= role %>">
            <div class="form-group">
                <input type="text" name="username" placeholder="Username" required>
            </div>
            <button type="submit" class="btn-primary">RESET PASSWORD</button>
        </form>
    </div>
</div>

<script src="js/main.js"></script>
</body>
</html>
