package cn.tech.Dao;

import cn.tech.connection.DBCon;
import cn.tech.model.Follow;
import cn.tech.model.User;

import java.sql.*;
import java.util.List;
import java.util.ArrayList;


public class FollowDao {
    private Connection con;

    public FollowDao(Connection con) {
        this.con = con;
    }
    public FollowDao() {
        
    }
    // Follow a user
    public void followUser(int followerId, int followingId) {
        String sql = "INSERT INTO followers (follower_id, following_id) VALUES (?, ?)";
        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followingId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // Unfollow a user
    public boolean unfollowUser(int followerId, int followingId) {
        String sql = "DELETE FROM followers WHERE follower_id = ? AND following_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Check if user follows another user
    public boolean isFollowing(int followerId, int followingId) {
        String sql = "SELECT COUNT(*) FROM followers WHERE follower_id = ? AND following_id = ?";
        try (Connection con = DBCon.getConnection();  // Create connection here
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


    // Get list of followers for a user
 // Get list of followers for a user
    public List<User> getFollowers(int userId) {
        List<User> followers = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.created_at FROM users u " +
                     "JOIN followers f ON u.id = f.follower_id " +
                     "WHERE f.following_id = ?";

        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    followers.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return followers;
    }

    // Get list of users the user is following
    public List<User> getFollowing(int userId) {
        List<User> following = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.created_at FROM users u " +
                     "JOIN followers f ON u.id = f.following_id " +
                     "WHERE f.follower_id = ?";

        try (Connection con = DBCon.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    following.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return following;
    }



}

