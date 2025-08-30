package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import com.google.gson.Gson;

import cn.tech.Dao.MessageDao;
import cn.tech.Dao.PostDao;
import cn.tech.model.Message;
import cn.tech.model.Post;
import cn.tech.model.User;

/**
 * Servlet implementation class SharePostServlet
 */
@WebServlet("/SharePostServlet")
public class SharePostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false, \"message\":\"User not logged in\"}");
            return;
        }

        try {
            // Get the receiverId and postId from the form parameters
            String receiverIdStr = request.getParameter("receiverId");
            String postIdStr = request.getParameter("postId");

            if (postIdStr == null || postIdStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Post ID is missing");
                return;
            }

            int postId = Integer.parseInt(postIdStr);
            int receiverId = Integer.parseInt(receiverIdStr);

            // Get the logged-in user (sender)
            User sender = (User) session.getAttribute("user");
            if (sender == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sender not found in session");
                return;
            }

            // Create a message object
            Message message = new Message();
            message.setSenderId(sender.getId());
            message.setReceiverId(receiverId);
            message.setContent(""); // No content for a post share
            message.setPostId(postId);
            message.setProfileId(0); // No profile sharing in this case

            // Save the message
            MessageDao dao = new MessageDao();
            boolean success = dao.sendMessage(message);

            if (success) {
                // Redirect to the list of followers page
                response.sendRedirect("/followers?status=sent");  // Redirect to followers page after sharing
            } else {
                out.print("{\"success\":false, \"message\":\"Failed to share post\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false, \"message\":\"An error occurred\"}");
        } finally {
            out.flush();
        }
    }
}
