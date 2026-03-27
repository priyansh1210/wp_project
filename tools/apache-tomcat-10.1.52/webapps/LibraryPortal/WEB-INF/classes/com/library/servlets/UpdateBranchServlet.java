package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateBranchServlet")
public class UpdateBranchServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String contactNo = request.getParameter("contact_no");
        String location = request.getParameter("location");

        if (id == null || name == null || name.trim().isEmpty()) {
            response.sendRedirect("adminBranches.jsp?msg=Branch name is required");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE branches SET name=?, contact_no=?, location=? WHERE id=?"
            );
            ps.setString(1, name.trim());
            ps.setString(2, contactNo != null ? contactNo.trim() : "");
            ps.setString(3, location != null ? location.trim() : "");
            ps.setInt(4, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminBranches.jsp?msg=Branch updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBranches.jsp?msg=Update failed: " + e.getMessage());
        }
    }
}
