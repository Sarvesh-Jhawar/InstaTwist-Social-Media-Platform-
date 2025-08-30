package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import cn.tech.connection.DBCon;
import cn.tech.model.User;

/**
 * Servlet implementation class UnfollowServlet
 */
@WebServlet("/UnfollowServlet")
public class UnfollowServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");

        if (loggedInUser == null) {
            response.getWriter().write("NotLoggedIn");
            return;
        }

        int unfollowUserId = Integer.parseInt(request.getParameter("followedId"));

        try (Connection conn = DBCon.getConnection()) {
            String sql = "DELETE FROM followers WHERE follower_id = ? AND following_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, loggedInUser.getId());
                stmt.setInt(2, unfollowUserId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                	response.getWriter().write("success");  // Instead of "Unfollowed"
                } else {
                    response.getWriter().write("Error");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("Error");
        }
    }
}