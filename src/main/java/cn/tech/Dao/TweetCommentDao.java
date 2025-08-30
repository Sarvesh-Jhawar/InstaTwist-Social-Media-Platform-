package cn.tech.Dao;


import cn.tech.connection.DBCon;
import cn.tech.model.TweetComment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TweetCommentDao {

    // Add a new comment to a tweet
    public boolean addComment(TweetComment comment) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBCon.getConnection();
            String sql = "INSERT INTO tweet_comments (tweet_id, user_id, comment) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, comment.getTweetId());
            ps.setInt(2, comment.getUserId());
            ps.setString(3, comment.getComment());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
        } catch (SQLException e) {
            System.err.println("Error adding comment: " + e.getMessage());
        } finally {
            closeResources(ps, conn);
        }
        return success;
    }

    // Get all comments for a tweet
    public List<TweetComment> getCommentsForTweet(int tweetId) {
        List<TweetComment> comments = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweet_comments WHERE tweet_id = ? ORDER BY commented_at ASC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            while (rs.next()) {
                TweetComment comment = new TweetComment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setTweetId(rs.getInt("tweet_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setComment(rs.getString("comment"));
                comment.setCommentedAt(rs.getString("commented_at"));
                comments.add(comment);
                
            }
            //System.out.println("the size of cimments id  :"+comments.size())    ;   
            } catch (SQLException e) {
            System.err.println("Error fetching comments: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return comments;
    }

    // Helper method to close resources
    private void closeResources(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    System.err.println("Failed to close resource: " + e.getMessage());
                }
            }
        }
    }
 // Get the number of comments for a specific tweet
    /**
     * Get all comments made by a specific user
     * @param userId The ID of the user whose comments to fetch
     * @return List of TweetComment objects that the user has made
     */
    public List<TweetComment> getCommentsByUserId(int userId) {
        List<TweetComment> userComments = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweet_comments WHERE user_id = ? ORDER BY commented_at DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                TweetComment comment = new TweetComment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setTweetId(rs.getInt("tweet_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setComment(rs.getString("comment"));
                comment.setCommentedAt(rs.getString("commented_at"));
                userComments.add(comment);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user comments: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        return userComments;
    }
    /**
     * Get the number of comments for a specific tweet
     * @param tweetId The ID of the tweet to count comments for
     * @return The number of comments for the tweet
     */
    public int getCommentCount(int tweetId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT COUNT(*) AS comment_count FROM tweet_comments WHERE tweet_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt("comment_count");
            }
        } catch (SQLException e) {
            System.err.println("Error fetching comment count: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        return count;
    }
    /**
     * Delete a specific comment by its ID
     * @param commentId The ID of the comment to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean deleteComment(int commentId) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBCon.getConnection();
            String sql = "DELETE FROM tweet_comments WHERE comment_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, commentId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
        } catch (SQLException e) {
            System.err.println("Error deleting comment: " + e.getMessage());
        } finally {
            closeResources(ps, conn);
        }
        return success;
    }
    public int getCommentsCount(int tweetId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT COUNT(*) AS total FROM tweet_comments WHERE tweet_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("Error fetching comment count: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }

        return count;
    }

}

