package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/BorrowBookServlet")
public class BorrowBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("memberId") == null) {
            response.sendRedirect("login.jsp?role=member&error=Please login first");
            return;
        }

        int memberId = (int) session.getAttribute("memberId");
        String bookIdStr = request.getParameter("bookId");

        if (bookIdStr == null) {
            response.sendRedirect("memberBooks.jsp?msg=Book ID is required");
            return;
        }

        int bookId = Integer.parseInt(bookIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // Check availability
            PreparedStatement checkPs = conn.prepareStatement("SELECT available FROM books WHERE id=?");
            checkPs.setInt(1, bookId);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next() && rs.getInt("available") > 0) {
                // Insert borrow record
                PreparedStatement borrowPs = conn.prepareStatement(
                    "INSERT INTO borrow_history (member_id, book_id, borrow_date, status) VALUES (?,?,NOW(),'BORROWED')"
                );
                borrowPs.setInt(1, memberId);
                borrowPs.setInt(2, bookId);
                borrowPs.executeUpdate();
                borrowPs.close();

                // Decrease available count
                PreparedStatement updatePs = conn.prepareStatement(
                    "UPDATE books SET available = available - 1 WHERE id=?"
                );
                updatePs.setInt(1, bookId);
                updatePs.executeUpdate();
                updatePs.close();

                response.sendRedirect("memberBooks.jsp?msg=Book borrowed successfully!");
            } else {
                response.sendRedirect("memberBooks.jsp?msg=Book not available");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("memberBooks.jsp?msg=Borrow failed: " + e.getMessage());
        }
    }
}
