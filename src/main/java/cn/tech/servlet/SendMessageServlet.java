package cn.tech.servlet;

import cn.tech.Dao.MessageDao;
import cn.tech.Dao.NotificationDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Message;
import cn.tech.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;


import cn.tech.Dao.MessageDao;
import cn.tech.Dao.NotificationDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Message;
import cn.tech.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User sender = (User) session.getAttribute("user");

        if (sender == null) {
            System.out.println("No user in session.");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            int receiverId = Integer.parseInt(request.getParameter("receiverId"));
            String content = request.getParameter("message");
            String postIdStr = request.getParameter("postId");
            String profileIdStr = request.getParameter("profileId");

            System.out.println("Receiver ID: " + receiverId);
            System.out.println("Content: " + content);
            System.out.println("Post ID: " + postIdStr);
            System.out.println("Profile ID: " + profileIdStr);

            // Convert postId and profileId to integers if not null
            int postId = (postIdStr != null && !postIdStr.isEmpty()) ? Integer.parseInt(postIdStr) : 0;
            int profileId = (profileIdStr != null && !profileIdStr.isEmpty()) ? Integer.parseInt(profileIdStr) : 0;

            // Debugging print statements
            System.out.println("Parsed postId: " + postId);
            System.out.println("Parsed profileId: " + profileId);

            // Create Message object
            Message message = new Message();
            message.setSenderId(sender.getId());
            message.setReceiverId(receiverId);
            message.setContent(content);
            message.setPostId(postId);  // Set postId
            message.setProfileId(profileId);

            try (Connection conn = DBCon.getConnection()) {
                MessageDao dao = new MessageDao();
                boolean success = dao.sendMessage(message);

                response.setContentType("application/json");
                if (success) {
                    // Add message notification
                    NotificationDao.createMessageNotification(receiverId, sender.getId(), sender.getUsername());

                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false}");
                }

            }
        } catch (Exception e) {
            e.printStackTrace();  // Print the stack trace for debugging
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
