package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/MemberRegisterServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class MemberRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String contactNo = request.getParameter("contactNo");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String name = (firstName != null ? firstName.trim() : "") + " " + (lastName != null ? lastName.trim() : "");
        name = name.trim();

        if (name.isEmpty() || email == null || email.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.length() < 4) {
            response.sendRedirect("register.jsp?role=member&error=All fields required, password min 4 chars");
            return;
        }

        // Handle file upload
        Part photoPart = request.getPart("profilePhoto");
        if (photoPart == null || photoPart.getSize() == 0) {
            response.sendRedirect("register.jsp?role=member&error=Profile picture is required for virtual ID");
            return;
        }

        String mimeType = photoPart.getContentType();
        if (mimeType == null || !mimeType.startsWith("image/")) {
            response.sendRedirect("register.jsp?role=member&error=Please upload a valid image file (JPG, PNG, or WEBP)");
            return;
        }

        byte[] photoBytes;
        try (InputStream is = photoPart.getInputStream()) {
            photoBytes = is.readAllBytes();
        }

        if (photoBytes.length < 500) {
            response.sendRedirect("register.jsp?role=member&error=Uploaded image is too small or invalid");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement check = conn.prepareStatement(
                "SELECT id FROM members WHERE email=? OR username=?");
            check.setString(1, email.trim());
            check.setString(2, username.trim());
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                response.sendRedirect("register.jsp?role=member&error=Email or username already registered");
                return;
            }

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO members (name, username, email, contact_no, password, profile_image, image_type) VALUES (?,?,?,?,?,?,?)"
            );
            ps.setString(1, name);
            ps.setString(2, username.trim());
            ps.setString(3, email.trim());
            ps.setString(4, contactNo != null && !contactNo.trim().isEmpty() ? contactNo.trim() : null);
            ps.setString(5, password);
            ps.setBytes(6, photoBytes);
            ps.setString(7, mimeType);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("login.jsp?role=member&success=Registration successful! Your virtual ID is ready. Please login.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?role=member&error=Registration failed: " + e.getMessage());
        }
    }
}
