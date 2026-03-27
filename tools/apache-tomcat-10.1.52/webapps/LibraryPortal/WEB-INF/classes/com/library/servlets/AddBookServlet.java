package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddBookServlet")
public class AddBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession().getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Unauthorized access");
            return;
        }

        String title = request.getParameter("title");
        String genre = request.getParameter("genre");
        String language = request.getParameter("language");
        String quantityStr = request.getParameter("quantity");

        if (title == null || title.trim().isEmpty() || genre == null || genre.trim().isEmpty()) {
            response.sendRedirect("adminBooks.jsp?msg=Name and Type are required");
            return;
        }

        int quantity = 1;
        try { quantity = Integer.parseInt(quantityStr); if (quantity < 1) quantity = 1; }
        catch (NumberFormatException ignored) {}

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO books (title, author, isbn, genre, language, quantity, available) VALUES (?,?,?,?,?,?,?)"
            );
            ps.setString(1, title.trim());
            ps.setString(2, "");
            ps.setString(3, "");
            ps.setString(4, genre.trim());
            ps.setString(5, language != null ? language.trim() : "English");
            ps.setInt(6, quantity);
            ps.setInt(7, quantity);
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("adminBooks.jsp?msg=Book added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBooks.jsp?msg=Add failed: " + e.getMessage());
        }
    }
}
