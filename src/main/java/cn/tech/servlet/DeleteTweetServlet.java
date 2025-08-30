package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import cn.tech.Dao.TweetDao;
import cn.tech.model.Tweet;
import cn.tech.model.User;

/**
 * Servlet implementation class DeleteTweetServlet
 */
@WebServlet("/DeleteTweetServlet")
public class DeleteTweetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // 1. Check if user is logged in
        if (currentUser == null) {
            out.write("error:You must be logged in to delete tweets");
            return;
        }

        // 2. Get tweetId from request
        String tweetIdStr = request.getParameter("tweetId");
        if (tweetIdStr == null || tweetIdStr.isEmpty()) {
            out.write("error:Tweet ID is required");
            return;
        }

        try {
            int tweetId = Integer.parseInt(tweetIdStr);
            TweetDao tweetDao = new TweetDao();

            // 3. Get the tweet and check if it exists
            Tweet tweet = tweetDao.getTweetById(tweetId);
            if (tweet == null) {
                out.write("error:Tweet not found");
                return;
            }

            // 4. Ensure the logged-in user owns the tweet
            if (tweet.getUserId() != currentUser.getId()) {
                out.write("error:You can only delete your own tweets");
                return;
            }

            // 5. Attempt to delete the tweet
            boolean deleted = tweetDao.deleteTweet(tweetId);
            if (deleted) {
                out.write("success:Tweet deleted successfully");
            } else {
                out.write("error:Failed to delete tweet");
            }

        } catch (NumberFormatException e) {
            out.write("error:Invalid tweet ID format");
        } catch (SQLException e) {
            e.printStackTrace();
            out.write("error:Database error occurred: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            out.write("error:An unexpected error occurred");
        }
    }
}
