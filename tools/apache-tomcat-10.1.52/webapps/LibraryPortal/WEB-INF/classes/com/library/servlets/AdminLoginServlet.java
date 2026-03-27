package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("login.jsp?role=admin&error=Username and password are required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Try username first, then fall back to email
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, name, email FROM admin WHERE (username=? OR email=?) AND password=?"
            );
            ps.setString(1, username.trim());
            ps.setString(2, username.trim());
            ps.setString(3, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("adminId", rs.getInt("id"));
                session.setAttribute("adminName", rs.getString("name"));
                session.setAttribute("adminEmail", rs.getString("email"));
                session.setMaxInactiveInterval(30 * 60);
                response.sendRedirect("adminDashboard.jsp");
            } else {
                response.sendRedirect("login.jsp?role=admin&error=Invalid admin credentials");
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?role=admin&error=Login failed: " + e.getMessage());
        }
    }
}
