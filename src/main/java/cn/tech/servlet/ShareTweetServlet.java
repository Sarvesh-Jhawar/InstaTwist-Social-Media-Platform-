package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import cn.tech.Dao.TweetShareDao;

/**
 * Servlet implementation class ShareTweetServlet
 */
@WebServlet("/shareTweet")
public class ShareTweetServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int tweetId = Integer.parseInt(request.getParameter("tweetId"));

       
        try {
            
            TweetShareDao tweetShareDao = new TweetShareDao();

            boolean success = tweetShareDao.addShare(userId, tweetId);

            if (success) {
                response.sendRedirect("home.jsp?msg=share_success");
            } else {
                response.sendRedirect("home.jsp?msg=share_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?msg=error");
        }
    }
}
