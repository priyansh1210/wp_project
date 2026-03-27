package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String role = request.getParameter("role");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (role == null) role = "member";

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            response.sendRedirect("resetPassword.jsp?role=" + role + "&username=" + username + "&error=Passwords do not match");
            return;
        }

        if (newPassword.length() < 4) {
            response.sendRedirect("resetPassword.jsp?role=" + role + "&username=" + username + "&error=Password must be at least 4 characters");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String table = "admin".equals(role) ? "admin" : "members";
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE " + table + " SET password=? WHERE username=? OR email=?"
            );
            ps.setString(1, newPassword);
            ps.setString(2, username.trim());
            ps.setString(3, username.trim());
            int updated = ps.executeUpdate();
            ps.close();

            if (updated > 0) {
                response.sendRedirect("login.jsp?role=" + role + "&success=Password reset successful! Please login.");
            } else {
                response.sendRedirect("resetPassword.jsp?role=" + role + "&username=" + username + "&error=User not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("resetPassword.jsp?role=" + role + "&username=" + username + "&error=Error: " + e.getMessage());
        }
    }
}
