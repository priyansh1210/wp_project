package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateMemberServlet")
public class UpdateMemberServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (id == null || name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            response.sendRedirect("adminUsers.jsp?msg=All fields are required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (password != null && !password.trim().isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE members SET name=?, email=?, username=?, password=? WHERE id=?"
                );
                ps.setString(1, name.trim());
                ps.setString(2, email.trim());
                ps.setString(3, username != null ? username.trim() : email.trim());
                ps.setString(4, password);
                ps.setInt(5, Integer.parseInt(id));
                ps.executeUpdate();
                ps.close();
            } else {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE members SET name=?, email=?, username=? WHERE id=?"
                );
                ps.setString(1, name.trim());
                ps.setString(2, email.trim());
                ps.setString(3, username != null ? username.trim() : email.trim());
                ps.setInt(4, Integer.parseInt(id));
                ps.executeUpdate();
                ps.close();
            }
            response.sendRedirect("adminUsers.jsp?msg=User updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminUsers.jsp?msg=Update failed: " + e.getMessage());
        }
    }
}
