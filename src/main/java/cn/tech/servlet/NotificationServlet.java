package cn.tech.servlet;

import cn.tech.Dao.NotificationDao;
import cn.tech.model.Notification;
import cn.tech.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;



@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("count".equals(action)) {
                List<Notification> unreadNotifications = NotificationDao.getUnreadNotifications(user.getId());
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write(String.valueOf(unreadNotifications.size()));
                return;
            }

            if ("preview".equals(action)) {
                List<Notification> unreadNotifications = NotificationDao.getUnreadNotifications(user.getId());
                response.setContentType("text/html;charset=UTF-8");

                if (unreadNotifications.isEmpty()) {
                    response.getWriter().write("");
                } else {
                    for (Notification n : unreadNotifications) {
                        String itemClass = n.isRead() ? "" : "unread";
                        String senderName = (n.getSenderName() != null) ? n.getSenderName() : "Someone";
                        String firstLetter = senderName.substring(0, 1).toUpperCase();
                        String actionText = getActionText(n.getType());
                        String timeAgo = getTimeAgo(n.getCreatedAt());

                        response.getWriter().write(
                                "<a class='dropdown-item notification-item " + itemClass + "' " +
                                "href='" + getNotificationLink(n) + "' " +
                                "data-id='" + n.getId() + "'>" +
                                "<div class='d-flex align-items-center'>" +
                                // Avatar container with fallback
                                "<div class='position-relative'>" +
                                // Fallback avatar (always shown)
                                "<div class='avatar-fallback-sm rounded-circle me-2'>" + firstLetter + "</div>" +
                                // Profile image (hidden by default, shown if it loads)
                                (n.getSenderProfilePic() != null && !n.getSenderProfilePic().isEmpty() ?
                                    "<img src='" + n.getSenderProfilePic() + "' " +
                                    "class='rounded-circle me-2' width='30' height='30' " +
                                    "style='position:absolute;top:0;left:0;display:none;' " +
                                    "onload=\"this.style.display='block'; " +
                                    "this.previousElementSibling.style.display='none'\"/>" : "") +
                                "</div>" +
                                "<div>" +
                                "<strong>" + senderName + "</strong> " + actionText +
                                "<div class='notification-time'>" + timeAgo + "</div>" +
                                "</div>" +
                                "</div>" +
                                "</a>"
                        );
                    }
                }
                return;
            }

            if ("viewAll".equals(action) || action == null) {
                List<Notification> allNotifications = NotificationDao.getAllNotifications(user.getId());
                List<Notification> readNotifications = new ArrayList<>();
                List<Notification> unreadNotifications = new ArrayList<>();

                for (Notification n : allNotifications) {
                    if (n.isRead()) {
                        readNotifications.add(n);
                    } else {
                        unreadNotifications.add(n);
                    }
                }

                request.setAttribute("unreadNotifications", unreadNotifications);
                request.setAttribute("readNotifications", readNotifications);
                request.setAttribute("notifications", allNotifications);

                request.getRequestDispatcher("notifications.jsp").forward(request, response);
                return;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            if ("count".equals(action) || "preview".equals(action)) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("0");
            } else {
                response.sendRedirect("error.jsp");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("markAllAsRead".equals(action)) {
                NotificationDao.markAllAsRead(user.getId());
                response.setStatus(HttpServletResponse.SC_OK);
            } else if ("markAsRead".equals(action)) {
                String idParam = request.getParameter("id");
                if (idParam != null) {
                    int notificationId = Integer.parseInt(idParam);
                    NotificationDao.markAsRead(notificationId);
                }
                response.setStatus(HttpServletResponse.SC_OK);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private String getActionText(String type) {
        switch(type) {
            case "like": return "liked your post";
            case "comment": return "commented on your post";
            case "follow": return "started following you";
            case "mention": return "mentioned you";
            default: return "interacted with you";
        }
    }

    private String getNotificationLink(Notification notification) {
        if (notification == null) return "#";

        switch(notification.getType()) {
            case "like":
                return notification.getPostId() > 0 ? "post.jsp?postId=" + notification.getPostId() : "#";
            case "comment":
                return notification.getPostId() > 0 ? "post.jsp?postId=" + notification.getPostId() : "#";
            case "mention":
                return "post.jsp?postId=" + (notification.getPostId() > 0 ? notification.getPostId() : "") + 
                       (notification.getCommentId() != null ? "#comment-" + notification.getCommentId() : "");
            case "follow":
                return "profile.jsp?userId=" + notification.getSenderId();
            case "message":
                return "GetContactsServlet";
            default:
                return "notifications.jsp";
        }
    }

    private String getTimeAgo(java.sql.Timestamp timestamp) {
        if (timestamp == null) return "just now";
        
        long diffInMillis = System.currentTimeMillis() - timestamp.getTime();
        
        long seconds = TimeUnit.MILLISECONDS.toSeconds(diffInMillis);
        if (seconds < 60) return seconds + "s ago";
        
        long minutes = TimeUnit.MILLISECONDS.toMinutes(diffInMillis);
        if (minutes < 60) return minutes + "m ago";
        
        long hours = TimeUnit.MILLISECONDS.toHours(diffInMillis);
        if (hours < 24) return hours + "h ago";
        
        long days = TimeUnit.MILLISECONDS.toDays(diffInMillis);
        if (days < 30) return days + "d ago";
        
        long months = days / 30;
        if (months < 12) return months + "mo ago";
        
        return (months / 12) + "y ago";
    }
}