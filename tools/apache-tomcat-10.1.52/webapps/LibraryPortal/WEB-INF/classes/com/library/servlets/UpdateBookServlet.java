package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateBookServlet")
public class UpdateBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String genre = request.getParameter("genre");
        String language = request.getParameter("language");
        String quantityStr = request.getParameter("quantity");

        if (id == null || title == null || title.trim().isEmpty()) {
            response.sendRedirect("adminBooks.jsp?msg=Required fields are missing");
            return;
        }

        int quantity = 1;
        try { quantity = Integer.parseInt(quantityStr); } catch (NumberFormatException ignored) {}

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE books SET title=?, genre=?, language=?, quantity=?, available=? WHERE id=?"
            );
            ps.setString(1, title.trim());
            ps.setString(2, genre != null ? genre.trim() : "");
            ps.setString(3, language != null ? language.trim() : "English");
            ps.setInt(4, quantity);
            ps.setInt(5, quantity);
            ps.setInt(6, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminBooks.jsp?msg=Book updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBooks.jsp?msg=Update failed: " + e.getMessage());
        }
    }
}
