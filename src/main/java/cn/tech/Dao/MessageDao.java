package cn.tech.Dao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import cn.tech.connection.DBCon;
import cn.tech.model.Message;
import cn.tech.model.User;

public class MessageDao {

    // Method to send a message
    public boolean sendMessage(Message message) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, post_id, profile_id, tweet_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBCon.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, message.getSenderId());
            stmt.setInt(2, message.getReceiverId());
            stmt.setString(3, message.getContent());
            stmt.setInt(4, message.getPostId());
            stmt.setInt(5, message.getProfileId());
            stmt.setInt(6, message.getTweetId());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public String getLastMessagePreview(int currentUserId, int otherUserId) {
        String sql = "SELECT content FROM messages " +
                     "WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) " +
                     "ORDER BY created_at DESC LIMIT 1";
        
        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, otherUserId);
            stmt.setInt(3, otherUserId);
            stmt.setInt(4, currentUserId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String content = rs.getString("content");
                    // Truncate if too long
                    return content.length() > 30 ? content.substring(0, 27) + "..." : content;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "No messages yet";
    }
    public List<User> getAllUsers() {
        List<User> allUsers = new ArrayList<>();
        String sql = "SELECT id, username FROM users";
        
        try (Connection conn = DBCon.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    allUsers.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return allUsers;
    }

    // Method to fetch messages between two users
    public List<Message> getMessagesBetweenUsers(int user1, int user2) {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY created_at ASC";
        
        try (Connection conn = DBCon.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, user1);
            stmt.setInt(2, user2);
            stmt.setInt(3, user2);
            stmt.setInt(4, user1);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Message message = new Message(
                        rs.getInt("sender_id"),
                        rs.getInt("receiver_id"),
                        rs.getString("content"),
                        rs.getInt("post_id"),
                        rs.getInt("profile_id"),
                        rs.getInt("tweet_id")
                    );
                    message.setId(rs.getInt("id"));
                    message.setCreatedAt(rs.getTimestamp("created_at"));
                    message.setRead(rs.getBoolean("is_read"));
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    public void markMessagesAsRead(int senderId, int receiverId) {
        try {
            Connection conn = DBCon.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE messages SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0"
            );
            stmt.setInt(1, senderId);
            stmt.setInt(2, receiverId);
            stmt.executeUpdate();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getUnreadMessageCount(int userId) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = false";

        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public List<User> getRecentConversations(int userId) {
        List<User> conversations = new ArrayList<>();
        String sql = "SELECT DISTINCT u.id, u.username " +
                     "FROM users u " +
                     "JOIN messages m ON (u.id = m.sender_id OR u.id = m.receiver_id) " +
                     "WHERE (m.sender_id = ? OR m.receiver_id = ?) AND u.id != ?";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId); // exclude self

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    conversations.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conversations;
    }

    public int getUnreadMessageCount(int senderId, int receiverId) {
        String sql = "SELECT COUNT(*) FROM messages WHERE sender_id = ? AND receiver_id = ? AND is_read = FALSE";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, senderId);
            stmt.setInt(2, receiverId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}