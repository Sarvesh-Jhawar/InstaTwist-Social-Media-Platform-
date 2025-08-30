package cn.tech.Dao;

import cn.tech.model.Notification;
import cn.tech.connection.DBCon;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDao {
    public static List<Notification> getAllNotifications(int userId) throws SQLException {
        List<Notification> list = new ArrayList<>();
        Connection conn = DBCon.getConnection();
        String sql = "SELECT n.*, u.username as sender_name, u.profile_pic as sender_profile_pic " +
                     "FROM notifications n JOIN users u ON n.sender_id = u.id " +
                     "WHERE n.recipient_id = ? ORDER BY n.created_at DESC";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setSenderId(rs.getInt("sender_id"));
                    n.setRecipientId(rs.getInt("recipient_id"));
                    n.setType(rs.getString("type"));
                    n.setPostId(rs.getInt("post_id"));
                    // Fix: Make sure is_read is processed correctly
                    n.setRead(rs.getBoolean("is_read"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setSenderName(rs.getString("sender_name"));
                    n.setSenderProfilePic(rs.getString("sender_profile_pic"));
                    // Handle potential null for comment_id
                    if (rs.getObject("comment_id") != null) {
                        n.setCommentId(rs.getInt("comment_id"));
                    }
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllNotifications: " + e.getMessage());
            throw e;
        }
        
        System.out.println("getAllNotifications returned " + list.size() + " notifications");
        return list;
    }
    public static void createCommentNotification(int recipientId, int senderId, String senderName, int postId, int commentId) throws SQLException {
        String sql = "INSERT INTO notifications (recipient_id, sender_id, sender_name, type, post_id, comment_id) VALUES (?, ?, ?, 'comment', ?, ?)";
        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recipientId);
            ps.setInt(2, senderId);
            ps.setString(3, senderName);
            ps.setInt(4, postId);
            ps.setInt(5, commentId);
            ps.executeUpdate();
        }
    }
    public static void createMessageNotification(int recipientId, int senderId, String senderName) throws SQLException {
        String sql = "INSERT INTO notifications (recipient_id, sender_id, sender_name, type) VALUES (?, ?, ?, 'message')";
        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recipientId);
            ps.setInt(2, senderId);
            ps.setString(3, senderName);
            ps.executeUpdate();
        }
    }

    public static void createFollowNotification(int recipientId, int senderId, String senderName) throws SQLException {
        String sql = "INSERT INTO notifications (recipient_id, sender_id, sender_name, type) VALUES (?, ?, ?, 'follow')";
        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recipientId);
            ps.setInt(2, senderId);
            ps.setString(3, senderName);
            ps.executeUpdate();
        }
    }

    // Rest of your methods remain the same...
    public static void createLikeNotification(int recipientId, int senderId, String sender_name, int postId) throws SQLException {
        String sql = "INSERT INTO notifications (recipient_id, sender_id, sender_name, type, post_id) VALUES (?, ?, ?, 'like', ?)";
        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, recipientId);
            ps.setInt(2, senderId);
            ps.setString(3, sender_name); // You'll need to fetch the sender's name before calling this method
            ps.setInt(4, postId);
            ps.executeUpdate();
        }
    }
    
    public static List<Notification> getUnreadNotifications(int userId) throws SQLException {
        System.out.println("Fetching unread notifications for user: " + userId);
        List<Notification> notifications = new ArrayList<>();
        
        String sql = "SELECT * FROM notifications " +
                "WHERE recipient_id = ? AND is_read = false " +
                "ORDER BY created_at DESC";

        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification notification = new Notification();
                    notification.setId(rs.getInt("id"));
                    notification.setRecipientId(rs.getInt("recipient_id"));
                    notification.setSenderId(rs.getInt("sender_id"));
                    notification.setSenderName(rs.getString("sender_name"));
                    notification.setSenderProfilePic(rs.getString("sender_profile_pic")); // could be null — fine for now

                    notification.setType(rs.getString("type"));
                    notification.setPostId(rs.getInt("post_id"));
                    notification.setCommentId(rs.getObject("comment_id") != null ? rs.getInt("comment_id") : null);
                    notification.setRead(rs.getBoolean("is_read"));
                    notification.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    notifications.add(notification);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("SQL Error: " + e.getMessage());
            throw e;
        }
        
      //  System.out.println("Found " + notifications.size() + " unread notifications");
        return notifications;
    }
    
    public static void markAsRead(int notificationId) throws SQLException {
        Connection conn = DBCon.getConnection();
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, notificationId);
        stmt.executeUpdate();
        stmt.close();
        conn.close();
    }

    public static void markAllAsRead(int userId) throws SQLException {
        Connection conn = DBCon.getConnection();
        String sql = "UPDATE notifications SET is_read = TRUE WHERE receiver_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        stmt.executeUpdate();
        stmt.close();
        conn.close();
    }

}