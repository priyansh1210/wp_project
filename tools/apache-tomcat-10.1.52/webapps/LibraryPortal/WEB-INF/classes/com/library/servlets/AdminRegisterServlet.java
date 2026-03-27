package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AdminRegisterServlet")
public class AdminRegisterServlet extends HttpServlet {

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
            response.sendRedirect("register.jsp?role=admin&error=All fields required, password min 4 chars");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Check username/email uniqueness
            PreparedStatement check = conn.prepareStatement(
                "SELECT id FROM admin WHERE email=? OR username=?");
            check.setString(1, email.trim());
            check.setString(2, username.trim());
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                response.sendRedirect("register.jsp?role=admin&error=Email or username already registered");
                return;
            }

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO admin (name, username, email, password, first_name, last_name, contact_no) VALUES (?,?,?,?,?,?,?)"
            );
            ps.setString(1, name);
            ps.setString(2, username.trim());
            ps.setString(3, email.trim());
            ps.setString(4, password);
            ps.setString(5, firstName != null ? firstName.trim() : "");
            ps.setString(6, lastName != null ? lastName.trim() : "");
            ps.setString(7, contactNo != null ? contactNo.trim() : "");
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("login.jsp?role=admin&success=Admin registration successful! Please login.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?role=admin&error=Registration failed: " + e.getMessage());
        }
    }
}
