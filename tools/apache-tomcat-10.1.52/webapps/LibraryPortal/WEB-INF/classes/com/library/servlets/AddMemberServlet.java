package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddMemberServlet")
public class AddMemberServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()
                || username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("adminUsers.jsp?msg=All fields are required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement check = conn.prepareStatement(
                "SELECT id FROM members WHERE email=? OR username=?");
            check.setString(1, email.trim());
            check.setString(2, username.trim());
            if (check.executeQuery().next()) {
                response.sendRedirect("adminUsers.jsp?msg=Email or username already exists");
                return;
            }

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO members (name, email, username, password) VALUES (?,?,?,?)"
            );
            ps.setString(1, name.trim());
            ps.setString(2, email.trim());
            ps.setString(3, username.trim());
            ps.setString(4, password);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminUsers.jsp?msg=User added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminUsers.jsp?msg=Add failed: " + e.getMessage());
        }
    }
}
