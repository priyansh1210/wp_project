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
            // Verify the borrow record belongs to this member and is currently BORROWED or REJECTED
            PreparedStatement getPs = conn.prepareStatement(
                "SELECT book_id FROM borrow_history WHERE id=? AND member_id=? AND status IN ('BORROWED','REJECTED')"
            );
            getPs.setInt(1, borrowId);
            getPs.setInt(2, (int) session.getAttribute("memberId"));
            ResultSet rs = getPs.executeQuery();

            if (rs.next()) {
                // Set status to RETURN_PENDING, clear any previous reject message
                PreparedStatement updateBorrow = conn.prepareStatement(
                    "UPDATE borrow_history SET status='RETURN_PENDING', reject_message=NULL WHERE id=?"
                );
                updateBorrow.setInt(1, borrowId);
                updateBorrow.executeUpdate();
                updateBorrow.close();

                response.sendRedirect("memberBorrows.jsp?msg=Return request submitted! Waiting for admin approval.");
            } else {
                response.sendRedirect("memberBorrows.jsp?msg=Invalid borrow record");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("memberBorrows.jsp?msg=Return request failed: " + e.getMessage());
        }
    }
}
