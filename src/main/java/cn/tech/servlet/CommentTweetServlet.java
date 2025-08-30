package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import cn.tech.Dao.TweetCommentDao;
import cn.tech.Dao.UserDao;
import cn.tech.connection.DBCon;
import cn.tech.model.TweetComment;
import cn.tech.model.User;

/**
 * Servlet implementation class CommentTweetServlet
 */
@WebServlet("/commentTweet")
public class CommentTweetServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        Connection conn = null;
        try {
            conn = DBCon.getConnection();
            int userId = Integer.parseInt(request.getParameter("userId"));
            int tweetId = Integer.parseInt(request.getParameter("tweetId"));
            String commentText = request.getParameter("commentText");

            if (commentText == null || commentText.trim().isEmpty()) {
                out.print("error|Comment text cannot be empty");
                return;
            }
            
            TweetCommentDao tweetCommentDao = new TweetCommentDao();
            UserDao userDao = new UserDao();
            
            TweetComment comment = new TweetComment();
            comment.setTweetId(tweetId);
            comment.setUserId(userId);
            comment.setComment(commentText);
            
            boolean success = tweetCommentDao.addComment(comment);
            
            if (success) {
                User user = userDao.getUserById(userId);
                if (user != null) {
                	out.print("success|" + user.getUsername() + "|just now|" + commentText);
                } else {
                    out.print("error|User not found");
                }
            } else {
                out.print("error|Failed to add comment");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error|Server error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
            out.close();
        }
    }
}