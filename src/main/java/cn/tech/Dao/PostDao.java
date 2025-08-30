package cn.tech.Dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import cn.tech.connection.DBCon;
import cn.tech.model.Comment;
import cn.tech.model.Post;
import cn.tech.model.User;

public class PostDao {

    // Method to create a new post
     

    // Method to retrieve all posts
     public List<Post> getAllPosts() {
    	    List<Post> posts = new ArrayList<>();
    	    String query = "SELECT p.*, COUNT(l.id) AS like_count " +
    	                   "FROM posts p " +
    	                   "LEFT JOIN likes l ON p.id = l.post_id " +
    	                   "GROUP BY p.id " +
    	                   "ORDER BY p.created_at DESC";

    	    try (Connection conn = DBCon.getConnection();
    	         PreparedStatement pstmt = conn.prepareStatement(query);
    	         ResultSet rs = pstmt.executeQuery()) {

    	        while (rs.next()) {
    	            Post post = new Post();
    	            post.setId(rs.getInt("id"));
    	            post.setUserId(rs.getInt("user_id"));
    	            post.setContent(rs.getString("content"));
    	            post.setImagePath(rs.getString("image_path"));
    	            post.setCreatedAt(rs.getTimestamp("created_at"));
    	            post.setLikeCount(rs.getInt("like_count")); // Set the like count
    	            posts.add(post);
    	        }
    	    } catch (SQLException e) {
    	        e.printStackTrace();
    	    }

    	    return posts;
    	}

    // Method to retrieve posts by a specific user
    public List<Post> getPostsByUserId(int userId) {
        List<Post> posts = new ArrayList<>();
        String query = "SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Post post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setUserId(rs.getInt("user_id"));
                    post.setContent(rs.getString("content"));
                    post.setImagePath(rs.getString("image_path")); // Retrieve the image path
                    post.setCreatedAt(rs.getTimestamp("created_at"));

                    posts.add(post);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    public boolean deletePost(int postId, int userId, Connection conn) throws SQLException {
        String query = "DELETE FROM posts WHERE id = ? AND user_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public boolean hasUserLikedPost(int userId, int postId) {
        String query = "SELECT COUNT(*) FROM likes WHERE user_id = ? AND post_id = ?";
        
        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
             
            pstmt.setInt(1, userId);
            pstmt.setInt(2, postId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<Post> getLikedPostsByUserId(int userId) {
        List<Post> likedPosts = new ArrayList<>();
        String sql = "SELECT p.* FROM posts p INNER JOIN likes l ON p.id = l.post_id WHERE l.user_id = ?";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Post post = new Post();
                post.setId(rs.getInt("id"));
                post.setUserId(rs.getInt("user_id"));
                post.setContent(rs.getString("content"));
                post.setImagePath(rs.getString("image_path"));
                post.setCreatedAt(rs.getTimestamp("created_at"));
                likedPosts.add(post);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return likedPosts;
    }

    public Post getPostById(int postId) {
        String sql = "SELECT p.*, COUNT(l.id) AS like_count " +
                     "FROM posts p " +
                     "LEFT JOIN likes l ON p.id = l.post_id " +
                     "WHERE p.id = ? " +
                     "GROUP BY p.id";
        
        Post post = null;

        try (Connection connection = DBCon.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, postId);
            ResultSet rs = statement.executeQuery();

            if (rs.next()) {
                post = new Post();
                post.setId(rs.getInt("id"));
                post.setUserId(rs.getInt("user_id"));
                post.setContent(rs.getString("content"));
                post.setImagePath(rs.getString("image_path"));
                post.setCreatedAt(rs.getTimestamp("created_at"));
                post.setLikeCount(rs.getInt("like_count")); // Set the like count
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return post;
    }

    public List<User> getUsersWhoLikedPost(int postId) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.id, u.username FROM users u " +
                     "INNER JOIN likes l ON u.id = l.user_id " +
                     "WHERE l.post_id = ?";

        try (Connection connection = DBCon.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, postId);
            ResultSet rs = statement.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public List<Comment> getCommentsByPostId(int postId) {
        List<Comment> comments = new ArrayList<>();
        String query = "SELECT c.*, u.username FROM comments c JOIN users u ON c.user_id = u.id WHERE c.post_id = ? ORDER BY c.created_at ASC";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setId(rs.getInt("id"));
                comment.setPostId(rs.getInt("post_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setContent(rs.getString("content"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comment.setUsername(rs.getString("username")); // Fetching username from the users table
                comments.add(comment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    public boolean createPost(Post post) {
        String sql = "INSERT INTO posts (user_id, content, created_at, image_path) VALUES (?, ?, ?, ?)";
        
        try (Connection connection = DBCon.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            // Set parameters
            statement.setInt(1, post.getUserId());
            statement.setString(2, post.getContent());
            
            // If createdAt is null, use current timestamp
            Timestamp createdAt = post.getCreatedAt();
            if (createdAt == null) {
                createdAt = new Timestamp(System.currentTimeMillis());
            }
            statement.setTimestamp(3, createdAt);
            
            // Handle null image path
            if (post.getImagePath() != null && !post.getImagePath().trim().isEmpty()) {
                statement.setString(4, post.getImagePath());
            } else {
                statement.setNull(4, Types.VARCHAR);
            }

            int affectedRows = statement.executeUpdate();
            
            if (affectedRows > 0) {
                // Get the generated post ID
                try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        post.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            return false;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

}
