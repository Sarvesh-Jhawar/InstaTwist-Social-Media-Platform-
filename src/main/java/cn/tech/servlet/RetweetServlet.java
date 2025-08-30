package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import cn.tech.Dao.TweetDao;

/**
 * Servlet implementation class RetweetServlet
 */
@WebServlet("/retweet")
public class RetweetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int tweetId = Integer.parseInt(request.getParameter("tweetId"));
        String action = request.getParameter("action"); // "retweet" or "unretweet"

        try {
            TweetDao tweetDao = new TweetDao();
            boolean success = false;

            if ("retweet".equals(action)) {
                success = tweetDao.retweet(userId, tweetId);
            } else if ("unretweet".equals(action)) {
                success = tweetDao.removeRetweet(userId, tweetId);
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

