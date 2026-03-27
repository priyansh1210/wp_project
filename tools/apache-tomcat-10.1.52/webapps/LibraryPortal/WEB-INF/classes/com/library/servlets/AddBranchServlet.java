package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddBranchServlet")
public class AddBranchServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String name = request.getParameter("name");
        String contactNo = request.getParameter("contact_no");
        String location = request.getParameter("location");

        if (name == null || name.trim().isEmpty()) {
            response.sendRedirect("adminBranches.jsp?msg=Branch name is required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int adminId = (int) request.getSession().getAttribute("adminId");
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO branches (name, contact_no, location, added_by) VALUES (?,?,?,?)"
            );
            ps.setString(1, name.trim());
            ps.setString(2, contactNo != null ? contactNo.trim() : "");
            ps.setString(3, location != null ? location.trim() : "");
            ps.setInt(4, adminId);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminBranches.jsp?msg=Branch added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBranches.jsp?msg=Add failed: " + e.getMessage());
        }
    }
}
