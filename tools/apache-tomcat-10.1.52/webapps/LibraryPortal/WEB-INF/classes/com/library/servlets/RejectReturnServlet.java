package com.library.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/RejectReturnServlet")
public class RejectReturnServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("adminId") == null) {
            response.sendRedirect("login.jsp?role=admin&error=Please login first");
            return;
        }

        String borrowIdStr = request.getParameter("borrowId");
        String reason = request.getParameter("reason");

        if (borrowIdStr == null) {
            response.sendRedirect("adminCatalog.jsp?msg=Borrow ID is required");
            return;
        }
        if (reason == null || reason.trim().length() < 5) {
            response.sendRedirect("adminCatalog.jsp?msg=Please provide a reason for rejection (min 5 characters)");
            return;
        }

        int borrowId = Integer.parseInt(borrowIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement getPs = conn.prepareStatement(
                "SELECT id FROM borrow_history WHERE id=? AND status='RETURN_PENDING'"
            );
            getPs.setInt(1, borrowId);
            ResultSet rs = getPs.executeQuery();

            if (rs.next()) {
                // Set status back to BORROWED with reject message
                PreparedStatement updateBorrow = conn.prepareStatement(
                    "UPDATE borrow_history SET status='REJECTED', reject_message=? WHERE id=?"
                );
                updateBorrow.setString(1, reason.trim());
                updateBorrow.setInt(2, borrowId);
                updateBorrow.executeUpdate();
                updateBorrow.close();

                response.sendRedirect("adminCatalog.jsp?msg=Return request rejected.");
            } else {
                response.sendRedirect("adminCatalog.jsp?msg=Invalid or already processed return request");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminCatalog.jsp?msg=Rejection failed: " + e.getMessage());
        }
    }
}
