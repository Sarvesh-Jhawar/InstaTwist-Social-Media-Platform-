package cn.tech.Dao;

import cn.tech.connection.DBCon;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LikeDao {
    // Check if a user has already liked a post
    public boolean checkIfLiked(int postId, int userId) throws SQLException {
        String query = "SELECT id FROM likes WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next(); // Returns true if the user has already liked the post
            }
        }
    }

    // Add a like to a post
    public void likePost(int postId, int userId) throws SQLException {
        String query = "INSERT INTO likes (post_id, user_id) VALUES (?, ?)";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
        }
    }

    // Remove a like from a post
    public void unlikePost(int postId, int userId) throws SQLException {
        String query = "DELETE FROM likes WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
        }
    }

    // Get the like count for a post
    public int getLikeCount(int postId) throws SQLException {
        String query = "SELECT COUNT(*) AS like_count FROM likes WHERE post_id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("like_count");
                }
            }
        }
        return 0;
    }

    public int getPostOwner(int postId) throws SQLException {
        String query = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id"); // Return the post owner's ID
                }
            }
        }
        return -1; // Return -1 if not found
    }

}