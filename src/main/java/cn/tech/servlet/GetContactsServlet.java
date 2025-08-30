package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import cn.tech.Dao.FollowDao;
import cn.tech.Dao.MessageDao;
import cn.tech.connection.DBCon;
import cn.tech.model.User;

/**
 * Servlet implementation class GetContactsServlet
 */
@WebServlet("/GetContactsServlet")
public class GetContactsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");

        if (loggedInUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try (Connection conn = DBCon.getConnection()) {
            MessageDao messageDao = new MessageDao();
            FollowDao followDao = new FollowDao();

            // Fetch users you've messaged
            List<User> messagedUsers = messageDao.getRecentConversations(loggedInUser.getId());

            if (!messagedUsers.isEmpty()) {
                // If user already has conversations
                Set<Integer> messagedUserIds = new HashSet<>();
                for (User user : messagedUsers) {
                    messagedUserIds.add(user.getId());
                    int unread = messageDao.getUnreadMessageCount(user.getId(), loggedInUser.getId());
                    user.setUnreadCount(unread);
                }

                request.setAttribute("messagedUsers", messagedUsers);
                request.setAttribute("notMessagedUsers", new ArrayList<>()); // Empty list
            } else {
                // If no conversations yet
                List<User> followingUsers = followDao.getFollowing(loggedInUser.getId());
                request.setAttribute("messagedUsers", new ArrayList<>()); // Empty list
                request.setAttribute("notMessagedUsers", followingUsers); // Show following as options
            }

            request.getRequestDispatcher("/chat.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
