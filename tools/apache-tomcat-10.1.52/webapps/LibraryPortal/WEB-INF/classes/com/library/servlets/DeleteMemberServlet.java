package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/DeleteMemberServlet")
public class DeleteMemberServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?error=Unauthorized access");
            return;
        }

        String id = request.getParameter("id");
        if (id == null) {
            response.sendRedirect("adminHome.jsp?error=Member ID is required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM members WHERE id=?");
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminUsers.jsp?msg=User deleted successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminUsers.jsp?msg=Delete failed: " + e.getMessage());
        }
    }
}
