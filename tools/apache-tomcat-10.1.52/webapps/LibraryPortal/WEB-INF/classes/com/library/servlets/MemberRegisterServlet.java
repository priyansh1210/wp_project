package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/MemberRegisterServlet")
public class MemberRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
                "INSERT INTO members (name, username, email, password) VALUES (?,?,?,?)"
            );
            ps.setString(1, name);
            ps.setString(2, username.trim());
            ps.setString(3, email.trim());
            ps.setString(4, password);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("login.jsp?role=member&success=Registration successful! Please login.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?role=member&error=Registration failed: " + e.getMessage());
        }
    }
}
