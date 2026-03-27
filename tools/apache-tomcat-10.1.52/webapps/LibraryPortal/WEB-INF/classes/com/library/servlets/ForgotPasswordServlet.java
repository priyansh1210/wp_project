package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String role = request.getParameter("role");
        if (role == null) role = "member";

        if (username == null || username.trim().isEmpty()) {
            response.sendRedirect("forgotPassword.jsp?role=" + role + "&error=Username is required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String table = "admin".equals(role) ? "admin" : "members";
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id FROM " + table + " WHERE username=? OR email=?"
            );
            ps.setString(1, username.trim());
            ps.setString(2, username.trim());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // User exists - redirect to reset password page
                response.sendRedirect("resetPassword.jsp?role=" + role + "&username=" + username.trim());
            } else {
                response.sendRedirect("forgotPassword.jsp?role=" + role + "&error=Username not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgotPassword.jsp?role=" + role + "&error=Error: " + e.getMessage());
        }
    }
}
