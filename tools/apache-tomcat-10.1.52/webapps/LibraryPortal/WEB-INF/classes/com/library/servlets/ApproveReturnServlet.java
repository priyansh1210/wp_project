package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ApproveReturnServlet")
public class ApproveReturnServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Please login first");
            return;
        }

        String borrowIdStr = request.getParameter("borrowId");
        if (borrowIdStr == null) {
            response.sendRedirect("adminCatalog.jsp?msg=Borrow ID is required");
            return;
        }

        int borrowId = Integer.parseInt(borrowIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // Get the book_id from borrow record
            PreparedStatement getPs = conn.prepareStatement(
                "SELECT book_id FROM borrow_history WHERE id=? AND status='RETURN_PENDING'"
            );
            getPs.setInt(1, borrowId);
            ResultSet rs = getPs.executeQuery();

            if (rs.next()) {
                int bookId = rs.getInt("book_id");

                // Update borrow record to RETURNED
                PreparedStatement updateBorrow = conn.prepareStatement(
                    "UPDATE borrow_history SET status='RETURNED', return_date=NOW(), reject_message=NULL WHERE id=?"
                );
                updateBorrow.setInt(1, borrowId);
                updateBorrow.executeUpdate();
                updateBorrow.close();

                // Increase available count
                PreparedStatement updateBook = conn.prepareStatement(
                    "UPDATE books SET available = available + 1 WHERE id=?"
                );
                updateBook.setInt(1, bookId);
                updateBook.executeUpdate();
                updateBook.close();

                response.sendRedirect("adminCatalog.jsp?msg=Return approved successfully!");
            } else {
                response.sendRedirect("adminCatalog.jsp?msg=Invalid or already processed return request");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminCatalog.jsp?msg=Approval failed: " + e.getMessage());
        }
    }
}
