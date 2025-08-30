package cn.tech.Dao;


import cn.tech.connection.DBCon;
import cn.tech.model.Tweet;
import cn.tech.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TweetLikeDao {

    // Add a like
	/**
	 * Get list of users who liked a specific tweet
	 * @param tweetId The ID of the tweet to check
	 * @return List of User objects who liked the tweet
	 */
	public List<User> getUsersWhoLikedTweet(int tweetId) {
	    List<User> users = new ArrayList<>();
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT u.id, u.username, u.profile_pic FROM users u " +
	                     "JOIN tweet_likes tl ON u.id = tl.user_id " +
	                     "WHERE tl.tweet_id = ? " +
	                     "ORDER BY tl.liked_at DESC"; // Most recent likes first
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, tweetId);
	        rs = ps.executeQuery();

	        while (rs.next()) {
	            User user = new User();
	            user.setId(rs.getInt("id"));
	            user.setUsername(rs.getString("username"));
	         //   user.setProfilePic(rs.getString("profile_pic"));
	            users.add(user);
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching users who liked tweet: " + e.getMessage());
	        e.printStackTrace();
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return users;
	}
	public boolean addLike(int userId, int tweetId) {
	    boolean success = false;
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        if (conn == null) {
	            System.err.println("Connection is null. Cannot add like.");
	            return false;
	        }

	        System.out.println("Trying to add like: userId = " + userId + ", tweetId = " + tweetId);

	        // Step 1: Check if the like already exists
	        String checkSql = "SELECT * FROM tweet_likes WHERE tweet_id = ? AND user_id = ?";
	        ps = conn.prepareStatement(checkSql);
	        ps.setInt(1, tweetId);
	        ps.setInt(2, userId);
	        rs = ps.executeQuery();
	        if (rs.next()) {
	            System.out.println("Like already exists. Skipping insert.");
	            return false;
	        }
	        ps.close();
	        rs.close();

	        // Step 2: Insert new like
	        String insertSql = "INSERT INTO tweet_likes (tweet_id, user_id) VALUES (?, ?)";
	        ps = conn.prepareStatement(insertSql);
	        ps.setInt(1, tweetId);
	        ps.setInt(2, userId);

	        int rows = ps.executeUpdate();
	        if (rows > 0) {
	            success = true;
	        }

	        System.out.println("Added like for tweet: " + success);
	    } catch (SQLException e) {
	        e.printStackTrace(); // Show full error
	    } finally {
	        closeResources(rs, ps, conn); // Modified to close ResultSet also
	    }
	    return success;
	}

	/**
	 * Get all tweets liked by a specific user
	 * @param userId The ID of the user whose liked tweets to fetch
	 * @return List of Tweet objects that the user has liked
	 */
	public List<Tweet> getLikedTweetsForUser(int userId) {
	    List<Tweet> likedTweets = new ArrayList<>();
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        // Join with tweets table to get full tweet information
	        String sql = "SELECT t.* FROM tweets t " +
	                     "JOIN tweet_likes tl ON t.tweet_id = tl.tweet_id " +
	                     "WHERE tl.user_id = ? " +
	                     "ORDER BY tl.liked_at DESC"; // Assuming you have a liked_at column
	        
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, userId);
	        rs = ps.executeQuery();

	        while (rs.next()) {
	            Tweet tweet = new Tweet();
	            tweet.setTweetId(rs.getInt("tweet_id"));
	            tweet.setUserId(rs.getInt("user_id"));
	            tweet.setContent(rs.getString("content"));
	            tweet.setParentTweetId(rs.getObject("parent_tweet_id") != null ? rs.getInt("parent_tweet_id") : null);
	            tweet.setCreatedAt(rs.getString("created_at"));
	            likedTweets.add(tweet);
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching liked tweets: " + e.getMessage());
	        e.printStackTrace();
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return likedTweets;
	}
	/**
	 * Get the number of likes for a specific tweet
	 * @param tweetId The ID of the tweet to count likes for
	 * @return The number of likes for the tweet
	 */
	public int getLikeCount(int tweetId) {
	    int count = 0;
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT COUNT(*) AS like_count FROM tweet_likes WHERE tweet_id = ?";
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, tweetId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            count = rs.getInt("like_count");
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching like count: " + e.getMessage());
	        e.printStackTrace();
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return count;
	}
	/**
	 * Get the timestamp when a user liked a specific tweet
	 * @param userId The ID of the user
	 * @param tweetId The ID of the tweet
	 * @return The timestamp string when the like occurred
	 */
	public String getLikeDate(int userId, int tweetId) {
	    String likeDate = "";
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT liked_at FROM tweet_likes WHERE user_id = ? AND tweet_id = ?";
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, userId);
	        ps.setInt(2, tweetId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            likeDate = rs.getString("liked_at");
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching like date: " + e.getMessage());
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return likeDate;
	}
    // Remove a like
    public boolean removeLike(int userId, int tweetId) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBCon.getConnection();
            String sql = "DELETE FROM tweet_likes WHERE tweet_id = ? AND user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
            
        } catch (SQLException e) {
            System.err.println("Error removing like: " + e.getMessage());
        } finally {
            closeResources(ps, conn);
        }
        return success;
    }

    // Get total likes for a tweet
    public int getLikesCount(int tweetId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT COUNT(*) FROM tweet_likes WHERE tweet_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
          //  System.out.println("sarfvsajn "+count);
        } catch (SQLException e) {
            System.err.println("Error fetching likes count: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return count;
    }

    // Check if a user already liked a tweet
    public boolean isLikedByUser(int userId, int tweetId) {
        boolean liked = false;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT like_id FROM tweet_likes WHERE tweet_id = ? AND user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                liked = true;
            }
          // System.out.println("sarfvsajn "+liked);
        } catch (SQLException e) {
            System.err.println("Error checking if liked: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return liked;
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
    public boolean isLiked(int tweetId, int userId) {
        boolean liked = false;
        try (Connection conn = DBCon.getConnection()) {
            String sql = "SELECT * FROM tweet_likes WHERE tweet_id=? AND user_id=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, tweetId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            liked = rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return liked;
    }

}
