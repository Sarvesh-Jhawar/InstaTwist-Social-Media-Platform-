package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;

import cn.tech.Dao.FollowDao;
import cn.tech.Dao.UserDao;
import cn.tech.connection.DBCon;
import cn.tech.model.User;

/**
 * Servlet implementation class GetFollowingServlet
 */
@WebServlet("/GetFollowingServlet")
public class GetFollowingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("GetFollowingServlet: doGet() called");

        // Retrieve the current session
        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("No session found");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Get the current user from the session
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            System.out.println("No user in session");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Fetch the list of following users
        FollowDao followDao = new FollowDao();
        List<User> following = null;
        try {
            following = followDao.getFollowing(currentUser.getId());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        // Get postId from request parameters
        String postIdStr = request.getParameter("postId");
        if (postIdStr == null || postIdStr.isEmpty()) {
            System.out.println("Post ID missing in request");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Post ID missing");
            return;
        }
        System.out.println("Post ID received: " + postIdStr);  // Log the received postId

        int postId;
        try {
            postId = Integer.parseInt(postIdStr);  // Parse the postId as an integer
        } catch (NumberFormatException e) {
            System.out.println("Invalid post ID format");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Post ID format");
            return;
        }

        // Generate HTML content for the list of users with "Send" buttons
     // Generate HTML content for the list of users with "Send" buttons
        StringBuilder htmlContent = new StringBuilder();

        if (following.isEmpty()) {
            htmlContent.append("<p>You are not following anyone yet.</p>");
        } else {
            for (User user : following) {
                htmlContent.append("<form action='#' method='POST' id='sendForm_" + user.getId() + "'>")
                           .append("<input type='hidden' name='postId' value='").append(postId).append("' />")
                           .append("<input type='hidden' name='receiverId' value='").append(user.getId()).append("' />")
                           .append("<div class='share-user'>")
                           .append("<span>").append(user.getUsername()).append("</span>")
                           .append("<button type='button' class='btn btn-primary' id='sendBtn_" + user.getId() + "' onclick='sendPostToUser(" + user.getId() + "," + postId + ")'>Send</button>")
                           .append("</div>")
                           .append("</form>");
            }
        }

        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.write(htmlContent.toString());
        out.flush();

    }
}