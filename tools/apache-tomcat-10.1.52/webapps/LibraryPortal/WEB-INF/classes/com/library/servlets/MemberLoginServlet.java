package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/MemberLoginServlet")
public class MemberLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("login.jsp?role=member&error=Username and password are required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, name, email, created_at FROM members WHERE (username=? OR email=?) AND password=?"
            );
            ps.setString(1, username.trim());
            ps.setString(2, username.trim());
            ps.setString(3, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("memberId", rs.getInt("id"));
                session.setAttribute("memberName", rs.getString("name"));
                session.setAttribute("memberEmail", rs.getString("email"));
                session.setAttribute("memberJoined", rs.getString("created_at"));
                session.setMaxInactiveInterval(30 * 60);
                response.sendRedirect("memberDashboard.jsp");
            } else {
                response.sendRedirect("login.jsp?role=member&error=Invalid credentials");
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?role=member&error=Login failed: " + e.getMessage());
        }
    }
}
