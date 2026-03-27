package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ChangeCredentialsServlet")
public class ChangeCredentialsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = request.getParameter("role");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            String redirect = "admin".equals(role) ? "adminDashboard.jsp" : "memberDashboard.jsp";
            response.sendRedirect(redirect + "?msg=Passwords do not match");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if ("admin".equals(role)) {
                int adminId = (int) session.getAttribute("adminId");
                PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM admin WHERE id=? AND password=?");
                check.setInt(1, adminId);
                check.setString(2, currentPassword);
                if (!check.executeQuery().next()) {
                    response.sendRedirect("adminDashboard.jsp?msg=Current password is incorrect");
                    return;
                }

                PreparedStatement ps = conn.prepareStatement("UPDATE admin SET password=? WHERE id=?");
                ps.setString(1, newPassword);
                ps.setInt(2, adminId);
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("adminDashboard.jsp?msg=Password changed successfully");
            } else {
                int memberId = (int) session.getAttribute("memberId");
                PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM members WHERE id=? AND password=?");
                check.setInt(1, memberId);
                check.setString(2, currentPassword);
                if (!check.executeQuery().next()) {
                    response.sendRedirect("memberDashboard.jsp?msg=Current password is incorrect");
                    return;
                }

                PreparedStatement ps = conn.prepareStatement("UPDATE members SET password=? WHERE id=?");
                ps.setString(1, newPassword);
                ps.setInt(2, memberId);
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("memberDashboard.jsp?msg=Password changed successfully");
            }
        } catch (Exception e) {
            e.printStackTrace();
            String redirect = "admin".equals(role) ? "adminDashboard.jsp" : "memberDashboard.jsp";
            response.sendRedirect(redirect + "?msg=Failed: " + e.getMessage());
        }
    }
}
