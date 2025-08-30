package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

import cn.tech.Dao.LikeDao;
import cn.tech.model.User;
import cn.tech.Dao.NotificationDao;
@WebServlet("/LikeServlet")
public class LikeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	 HttpSession session = request.getSession();
    	    User user = (User) session.getAttribute("user");

    	    if (user == null) {
    	        // User is not logged in
    	        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "You must be logged in to like a post.");
    	        return;
    	    }

    	    int postId = Integer.parseInt(request.getParameter("postId"));
    	    int userId = user.getId();

    	    LikeDao likeDAO = new LikeDao();

    	    try {
    	        // Check if the user has already liked the post
    	        boolean hasLiked = likeDAO.checkIfLiked(postId, userId);

    	        if (hasLiked) {
    	            // Unlike the post
    	            likeDAO.unlikePost(postId, userId);
    	        } else {
    	            // Like the post
    	            likeDAO.likePost(postId, userId);
    	            // Get post owner's ID
    	            int recipientId = likeDAO.getPostOwner(postId);

    	            // Prevent sending notification to self
    	            if (recipientId != userId) {
    	            	NotificationDao.createLikeNotification(recipientId, userId, user.getUsername(), postId);
    	            }
    	        }

    	        // Return the updated like count
    	        int likeCount = likeDAO.getLikeCount(postId);
    	        response.getWriter().write(String.valueOf(likeCount));
    	    } catch (SQLException e) {
    	        e.printStackTrace();
    	        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
    	    }
    }
}