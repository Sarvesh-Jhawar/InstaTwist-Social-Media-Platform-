package cn.tech.Dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import cn.tech.connection.DBCon;
import cn.tech.model.User;

public class UserDao {
    
    // Method to retrieve a user by ID
    public User getUserById(int userId) {
        String query = "SELECT * FROM users WHERE id = ?";
        User user = null;

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }
    public List<User> getSuggestedUsers(int userId) {
        List<User> suggestedUsers = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE id NOT IN " +
                     "(SELECT following_id FROM followers WHERE follower_id = ?) AND id != ? LIMIT 5";

        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                suggestedUsers.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return suggestedUsers;
    }

    public boolean followUser(int userId, int followUserId) {
        String query = "INSERT INTO follows (user_id, follow_user_id) VALUES (?, ?)";
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, userId);
            ps.setInt(2, followUserId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public boolean isFollowing(int userId, int followUserId) {
        String query = "SELECT COUNT(*) FROM follows WHERE user_id = ? AND follow_user_id = ?";
        
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, userId);
            ps.setInt(2, followUserId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0; // Returns true if there's at least one record
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<User> searchUsersByNameOrUsername(String query) {
        List<User> users = new ArrayList<>();
        try (Connection conn = DBCon.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id, username, profile_pic FROM users WHERE username LIKE ? LIMIT 10")) {

            // Prepare search query with wildcards
            String searchPattern = "%" + query + "%";
            
            // Set the parameters for the prepared statement
            ps.setString(1, searchPattern);
//            ps.setString(2, searchPattern);

            // Execute the query
            ResultSet rs = ps.executeQuery();
            
            // Iterate through the result set and add the users to the list
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setProfileImage(rs.getString("profile_pic")); // Assuming 'profile_pic' is the column for profile picture
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }



}
