package cn.tech.Dao;

import cn.tech.model.Comment;
import cn.tech.connection.DBCon;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDao {
	
	public Comment getCommentById(int commentId) {
	    String sql = "SELECT c.*, u.username FROM comments c JOIN users u ON c.user_id = u.id WHERE c.id = ?";
	    try (Connection conn = DBCon.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {
	        stmt.setInt(1, commentId);
	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                Comment comment = new Comment();
	                comment.setId(rs.getInt("id"));
	                comment.setPostId(rs.getInt("post_id"));
	                comment.setUserId(rs.getInt("user_id"));
	                comment.setUsername(rs.getString("username"));
	                comment.setContent(rs.getString("content"));
	                comment.setCreatedAt(rs.getTimestamp("created_at"));
	                return comment;
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return null;
	}

    // Method to add a new comment and return success status
	public boolean saveComment(Comment comment) {
	    String sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)";
	    try (Connection conn = DBCon.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

	        stmt.setInt(1, comment.getPostId());
	        stmt.setInt(2, comment.getUserId());
	        stmt.setString(3, comment.getContent());

	        int rowsAffected = stmt.executeUpdate();

	        if (rowsAffected > 0) {
	            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
	                if (generatedKeys.next()) {
	                    comment.setId(generatedKeys.getInt(1)); // Save the generated comment ID
	                }
	            }
	            return true;
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();  // Print full error for debugging
	    }
	    return false;
	}


    // Fetch comments for a given post
    public List<Comment> getCommentsByPostId(int postId) {
        List<Comment> comments = new ArrayList<>();
        String query = "SELECT c.*, u.username FROM comments c JOIN users u ON c.user_id = u.id WHERE c.post_id = ? ORDER BY c.created_at ASC";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
             
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Comment comment = new Comment();
                    comment.setId(rs.getInt("id"));
                    comment.setPostId(rs.getInt("post_id"));
                    comment.setUserId(rs.getInt("user_id"));
                    comment.setUsername(rs.getString("username")); // Fetching username
                    comment.setContent(rs.getString("content"));
                    comment.setCreatedAt(rs.getTimestamp("created_at"));

                    comments.add(comment);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    public List<Comment> getCommentsByUserId(int userId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, p.id AS post_id FROM comments c INNER JOIN posts p ON c.post_id = p.id WHERE c.user_id = ?";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setId(rs.getInt("id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setPostId(rs.getInt("post_id"));
                comment.setContent(rs.getString("content"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comments.add(comment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    public boolean deleteComment(int commentId, int userId) {
        String query = "DELETE FROM comments WHERE id = ? AND user_id = ?";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getPostOwnerId(int postId) {
        String sql = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, postId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }
    

}
