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
        <a href="login.jsp?role=member" class="btn-switch">SIGN IN</a>
    </div>

    <!-- Right: Form Panel -->
    <div class="auth-light-panel">
        <img src="img/logo.svg" class="form-logo" alt="The Archive Co.">
        <h1>Sign Up</h1>
        <p class="form-subtitle">Member registration. Admin accounts are created by existing admins only.</p>

        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } %>

        <!-- Member Register Form -->
        <form id="memberForm" class="auth-form" action="MemberRegisterServlet" method="post" enctype="multipart/form-data" onsubmit="return validatePhoto()">
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

            <!-- Profile Picture Upload -->
            <div class="form-group" style="margin-top:8px">
                <label style="display:block;margin-bottom:6px;font-weight:600;font-size:13px">Upload Profile Picture (required for virtual ID)</label>
                <div id="uploadBox" style="border:1px solid #ccc;border-radius:6px;padding:16px;background:#fafafa">
                    <div style="display:flex;gap:16px;align-items:center;flex-wrap:wrap">
                        <img id="photoPreview" alt="Preview" style="width:120px;height:120px;object-fit:cover;border:2px dashed #aaa;border-radius:6px;display:none;background:#eee">
                        <div id="photoPlaceholder" style="width:120px;height:120px;border:2px dashed #aaa;border-radius:6px;display:flex;align-items:center;justify-content:center;background:#eee;color:#999;font-size:12px;text-align:center;padding:8px">No photo<br>selected</div>
                        <div style="flex:1;min-width:180px">
                            <div id="photoStatus" style="font-size:12px;color:#666;margin-bottom:8px">Please upload a profile picture</div>
                            <input type="file" name="profilePhoto" id="profilePhotoInput" accept="image/jpeg,image/png,image/webp" required style="display:none">
                            <button type="button" class="btn-borrow" style="width:100%;padding:8px;font-size:13px" onclick="document.getElementById('profilePhotoInput').click()">Choose Photo</button>
                        </div>
                    </div>
                </div>
            </div>

            <button type="submit" class="btn-primary" id="submitBtn" disabled>SIGN UP</button>
        </form>
    </div>
</div>

<script src="js/main.js"></script>
<script>
var fileInput = document.getElementById('profilePhotoInput');
var preview = document.getElementById('photoPreview');
var placeholder = document.getElementById('photoPlaceholder');
var statusEl = document.getElementById('photoStatus');
var submitBtn = document.getElementById('submitBtn');

fileInput.addEventListener('change', function() {
    var file = this.files[0];
    if (!file) {
        preview.style.display = 'none';
        placeholder.style.display = 'flex';
        submitBtn.disabled = true;
        statusEl.textContent = 'Please upload a profile picture';
        statusEl.style.color = '#666';
        return;
    }

    // Validate file type
    var validTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (validTypes.indexOf(file.type) === -1) {
        alert('Please upload a JPG, PNG, or WEBP image.');
        this.value = '';
        return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
        alert('Image must be less than 5MB.');
        this.value = '';
        return;
    }

    var reader = new FileReader();
    reader.onload = function(e) {
        preview.src = e.target.result;
        preview.style.display = 'block';
        placeholder.style.display = 'none';
        submitBtn.disabled = false;
        statusEl.textContent = file.name + ' selected';
        statusEl.style.color = '#080';
    };
    reader.readAsDataURL(file);
});

function validatePhoto() {
    if (!fileInput.files || !fileInput.files[0]) {
        alert('Please upload a profile picture before signing up.');
        return false;
    }
    return true;
}
</script>
</body>
</html>
