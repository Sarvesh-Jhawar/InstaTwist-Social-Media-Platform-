package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

import cn.tech.Dao.TweetLikeDao;
import cn.tech.connection.DBCon;

/**
 * Servlet implementation class LikeTweetServlet
 */
@WebServlet("/likeTweet")
public class LikeTweetServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int tweetId = Integer.parseInt(request.getParameter("tweetId"));
        System.out.println("like servlet "+userId);
        System.out.println("like servlet 2 "+tweetId);

        String action = request.getParameter("action"); // "like" or "unlike"

        Connection conn = null;
        try {
            conn = DBCon.getConnection();
            TweetLikeDao tweetLikeDao = new TweetLikeDao();

            boolean success = false;
            if ("like".equals(action)) {
            	
                success = tweetLikeDao.addLike(userId, tweetId);
            } else if ("unlike".equals(action)) {
                success = tweetLikeDao.removeLike(userId, tweetId);
            }

            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(success ? "success" : "failed");

        } catch (Exception e) {
        	e.printStackTrace();
        	response.setContentType("text/plain");
        	response.setCharacterEncoding("UTF-8");
        	response.getWriter().write("error");

        }
    }
}