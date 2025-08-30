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

import cn.tech.Dao.NotificationDao;
import cn.tech.connection.DBCon;
import cn.tech.model.User;
@WebServlet("/FollowServlet")
public class FollowServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        System.out.println("FollowServlet triggered");
        User loggedInUser = (User) session.getAttribute("user");

        if (loggedInUser == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"NotLoggedIn\"}");
            return;
        }

        int userId = Integer.parseInt(request.getParameter("userId"));
        String action = request.getParameter("action");

        try (Connection conn = DBCon.getConnection()) {

            if ("follow".equals(action)) {
                String sql = "INSERT INTO followers (follower_id, following_id) VALUES (?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, loggedInUser.getId());
                    stmt.setInt(2, userId);
                    int rowsAffected = stmt.executeUpdate();

                    response.setContentType("application/json");
                    if (rowsAffected > 0) {
                        // Create notification
                        NotificationDao.createFollowNotification(
                            userId,
                            loggedInUser.getId(),
                            loggedInUser.getUsername()
                        );
                        response.getWriter().write("{\"success\": true}");
                    } else {
                        response.getWriter().write("{\"success\": false, \"message\": \"Error\"}");
                    }
                }
            }else if ("unfollow".equals(action)) {
                String sql = "DELETE FROM followers WHERE follower_id = ? AND following_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, loggedInUser.getId());
                    stmt.setInt(2, userId);
                    int rowsAffected = stmt.executeUpdate();

                    response.setContentType("application/json");
                    if (rowsAffected > 0) {
                        response.getWriter().write("{\"success\": true}");
                    } else {
                        response.getWriter().write("{\"success\": false, \"message\": \"Error\"}");
                    }
                }
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"InvalidAction\"}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Exception\"}");
        }
    }
}