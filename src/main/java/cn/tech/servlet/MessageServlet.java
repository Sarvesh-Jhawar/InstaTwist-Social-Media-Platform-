package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import cn.tech.Dao.FollowDao;
import cn.tech.Dao.MessageDao;
import cn.tech.Dao.NotificationDao;
import cn.tech.model.Message;
import cn.tech.model.User;

/**
 * Servlet implementation class MessageServlet
 */
@WebServlet("/message")
public class MessageServlet extends HttpServlet {
    private MessageDao messageDao;
    private FollowDao followDao;

    @Override
    public void init() {
        messageDao = new MessageDao();
        followDao = new FollowDao();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get conversation with specific user if userId parameter exists
        String userIdParam = request.getParameter("userId");
        if (userIdParam != null && !userIdParam.isEmpty()) {
            int otherUserId = Integer.parseInt(userIdParam);
            
            // Verify current user follows the other user
            if (followDao.isFollowing(currentUser.getId(), otherUserId)) {
                List<Message> messages = messageDao.getMessagesBetweenUsers(currentUser.getId(), otherUserId);
                messageDao.markMessagesAsRead(otherUserId, currentUser.getId()); // Mark as read
                request.setAttribute("messages", messages);
                request.setAttribute("otherUserId", otherUserId);
            }
        }
        
        // Get recent conversations
        List<User> recentConversations = messageDao.getRecentConversations(currentUser.getId());
        if (recentConversations == null) {
            recentConversations = new ArrayList<>();
        }
        request.setAttribute("recentConversations", recentConversations);
        
        // Get people you follow
        List<User> following = followDao.getFollowing(currentUser.getId());
        if (following == null) {
            following = new ArrayList<>();
        }
        // Create set of recent conversation user IDs
        Set<Integer> recentUserIds = new HashSet<>();
        for (User user : recentConversations) {
            recentUserIds.add(user.getId());
        }
        
        // Get people you follow but haven't messaged recently
        List<User> followingNotInRecent = new ArrayList<>();
        for (User user : following) {
            if (!recentUserIds.contains(user.getId())) {
                followingNotInRecent.add(user);
            }
        }
        
        request.setAttribute("followingNotInRecent", followingNotInRecent);
        
        // Get unread count
        int unreadCount = messageDao.getUnreadMessageCount(currentUser.getId());
        request.setAttribute("unreadCount", unreadCount);
        
        request.getRequestDispatcher("message.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int receiverId = Integer.parseInt(request.getParameter("receiverId"));
        String content = request.getParameter("content");

        int tweetId = 0;
        String tweetIdParam = request.getParameter("tweetId");
        if (tweetIdParam != null && !tweetIdParam.isEmpty()) {
            tweetId = Integer.parseInt(tweetIdParam);
        }

        int postId = 0;
        String postIdParam = request.getParameter("postId");
        if (postIdParam != null && !postIdParam.isEmpty()) {
            postId = Integer.parseInt(postIdParam);
        }

        if (followDao.isFollowing(currentUser.getId(), receiverId)) {
            Message message = new Message(currentUser.getId(), receiverId, content, postId, 0, tweetId);
            messageDao.sendMessage(message);

            String time = java.time.LocalTime.now().toString().substring(0,5);
            String result = "success|" + currentUser.getUsername() + "|" + time + "|" + content;
            response.getWriter().write(result);
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("error|Not following this user.");
        }
    }

}