package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ReturnBookServlet")
public class ReturnBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("memberId") == null) {
            response.sendRedirect("login.jsp?role=member&error=Please login first");
            return;
        }

        String borrowIdStr = request.getParameter("borrowId");
        if (borrowIdStr == null) {
            response.sendRedirect("memberBorrows.jsp?msg=Borrow ID is required");
            return;
        }

        int borrowId = Integer.parseInt(borrowIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // Get the book_id from borrow record
            PreparedStatement getPs = conn.prepareStatement(
                "SELECT book_id FROM borrow_history WHERE id=? AND status='BORROWED'"
            );
            getPs.setInt(1, borrowId);
            ResultSet rs = getPs.executeQuery();

            if (rs.next()) {
                int bookId = rs.getInt("book_id");

                // Update borrow record
                PreparedStatement updateBorrow = conn.prepareStatement(
                    "UPDATE borrow_history SET status='RETURNED', return_date=NOW() WHERE id=?"
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

                response.sendRedirect("memberBorrows.jsp?msg=Book returned successfully!");
            } else {
                response.sendRedirect("memberBorrows.jsp?msg=Invalid borrow record");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("memberBorrows.jsp?msg=Return failed: " + e.getMessage());
        }
    }
}
