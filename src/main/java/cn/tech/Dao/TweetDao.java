package cn.tech.Dao;


import cn.tech.connection.DBCon;
import cn.tech.model.Tweet;
import cn.tech.model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TweetDao {
	// Add these methods to your TweetDao class


	/**
	 * Get list of users who retweeted a specific tweet
	 * @param tweetId The ID of the original tweet
	 * @return List of User objects who retweeted the tweet
	 */
	public List<User> getUsersWhoRetweetedTweet(int tweetId) {
	    List<User> users = new ArrayList<>();
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT u.* FROM users u JOIN tweets t ON u.id = t.user_id WHERE t.parent_tweet_id = ?";
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, tweetId);
	        rs = ps.executeQuery();

	        while (rs.next()) {
	            User user = new User();
	            user.setId(rs.getInt("id"));
	            user.setUsername(rs.getString("username"));
	            user.setEmail(rs.getString("email"));
	           // user.setProfilePic(rs.getString("profile_pic"));
	            users.add(user);
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching users who retweeted tweet: " + e.getMessage());
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return users;
	}
	/**
	 * Delete a tweet from the database
	 * @param tweetId The ID of the tweet to delete
	 * @return true if deletion was successful, false otherwise
	 * @throws SQLException if a database error occurs
	 */
	public boolean deleteTweet(int tweetId) throws SQLException {
	    Connection conn = null;
	    PreparedStatement ps = null;

	    try {
	        conn = DBCon.getConnection();

	        // ✅ Step 1: Recursively collect ALL retweets (deepest first)
	        List<Integer> allRetweetIds = getAllRetweetIds(tweetId, conn);

	        // ✅ Step 2: Delete likes and comments for each retweet
	        for (Integer id : allRetweetIds) {
	            ps = conn.prepareStatement("DELETE FROM tweet_comments WHERE tweet_id = ?");
	            ps.setInt(1, id);
	            ps.executeUpdate();
	            ps.close();

	            ps = conn.prepareStatement("DELETE FROM tweet_likes WHERE tweet_id = ?");
	            ps.setInt(1, id);
	            ps.executeUpdate();
	            ps.close();

	            ps = conn.prepareStatement("DELETE FROM tweets WHERE tweet_id = ?");
	            ps.setInt(1, id);
	            ps.executeUpdate();
	            ps.close();
	        }

	        // ✅ Step 3: Delete main tweet's comments, likes
	        ps = conn.prepareStatement("DELETE FROM tweet_comments WHERE tweet_id = ?");
	        ps.setInt(1, tweetId);
	        ps.executeUpdate();
	        ps.close();

	        ps = conn.prepareStatement("DELETE FROM tweet_likes WHERE tweet_id = ?");
	        ps.setInt(1, tweetId);
	        ps.executeUpdate();
	        ps.close();

	        // ✅ Step 4: Delete main tweet
	        ps = conn.prepareStatement("DELETE FROM tweets WHERE tweet_id = ?");
	        ps.setInt(1, tweetId);
	        int rows = ps.executeUpdate();
	        ps.close();

	        return rows > 0;

	    } finally {
	        closeResources(ps, conn);
	    }
	}

	
	private List<Integer> getAllRetweetIds(int tweetId, Connection conn) throws SQLException {
	    List<Integer> ids = new ArrayList<>();
	    PreparedStatement ps = conn.prepareStatement("SELECT tweet_id FROM tweets WHERE parent_tweet_id = ?");
	    ps.setInt(1, tweetId);
	    ResultSet rs = ps.executeQuery();
	    while (rs.next()) {
	        int id = rs.getInt("tweet_id");
	        ids.addAll(getAllRetweetIds(id, conn)); // Recursively get retweets of retweet
	        ids.add(id);
	    }
	    rs.close();
	    ps.close();
	    return ids;
	}


	public String[] getUserDetailsForTweet(int tweetId) {
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    String[] userDetails = new String[4]; // [userId, name, username, profilePic]

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT u.id,u.username, u.profile_pic " +
	                     "FROM users u JOIN tweets t ON u.id = t.user_id " +
	                     "WHERE t.tweet_id = ?";
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, tweetId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            userDetails[0] = String.valueOf(rs.getInt("id")); // Corrected from user_id to id
	            userDetails[2] = rs.getString("username");
	            userDetails[3] = rs.getString("profile_pic");
	            return userDetails;
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching user details: " + e.getMessage());
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return null;
	}

	/**
	 * Get the latest tweet posted by a specific user
	 * @param userId the ID of the user
	 * @return Tweet object with the latest tweet
	 */
	public Tweet getLatestTweetByUser(int userId) {
	    Tweet tweet = null;
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = DBCon.getConnection();
	        String sql = "SELECT * FROM tweets WHERE user_id = ? ORDER BY created_at DESC LIMIT 1";
	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, userId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            tweet = new Tweet();
	            tweet.setTweetId(rs.getInt("tweet_id"));
	            tweet.setUserId(rs.getInt("user_id"));
	            tweet.setContent(rs.getString("content"));
	            tweet.setParentTweetId(rs.getObject("parent_tweet_id") != null ? rs.getInt("parent_tweet_id") : null);
	            tweet.setCreatedAt(rs.getString("created_at"));
	        }
	    } catch (SQLException e) {
	        System.err.println("Error fetching latest tweet: " + e.getMessage());
	    } finally {
	        closeResources(rs, ps, conn);
	    }
	    return tweet;
	}

	/**
	 * Get user details along with tweet
	 * @param tweetId The ID of the tweet
	 * @return String array with [userId, userName, userHandle, userProfilePic]
	 */
	

    // Save a new tweet
    public boolean saveTweet(Tweet tweet) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBCon.getConnection();
            String sql = "INSERT INTO tweets (user_id, content, parent_tweet_id) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweet.getUserId());
            ps.setString(2, tweet.getContent());

            if (tweet.getParentTweetId() != null) {
                ps.setInt(3, tweet.getParentTweetId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
        } catch (SQLException e) {
            System.err.println("Error saving tweet: " + e.getMessage());
        } finally {
            closeResources(ps, conn);
        }
        return success;
    }

    // Fetch all tweets (newest first)
    public List<Tweet> getAllTweets() {
        List<Tweet> tweets = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweets WHERE parent_tweet_id IS NULL ORDER BY created_at DESC";

            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Tweet tweet = new Tweet();
                tweet.setTweetId(rs.getInt("tweet_id"));
                tweet.setUserId(rs.getInt("user_id"));
                tweet.setContent(rs.getString("content"));
                tweet.setParentTweetId(rs.getObject("parent_tweet_id") != null ? rs.getInt("parent_tweet_id") : null);
                tweet.setCreatedAt(rs.getString("created_at"));
                tweets.add(tweet);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching tweets: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return tweets;
    }
    public boolean retweet(int userId, int parentTweetId) {
        String sql = "INSERT INTO tweets (user_id, content, parent_tweet_id) VALUES (?, '', ?)";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, parentTweetId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public int getRetweetCount(int tweetId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM tweets WHERE parent_tweet_id = ?";
        try (Connection conn = DBCon.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, tweetId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    public boolean isRetweeted(int tweetId, int userId) {
        boolean retweeted = false;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweets WHERE parent_tweet_id = ? AND user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);  // original tweet id
            ps.setInt(2, userId);   // who is checking
            rs = ps.executeQuery();
            if (rs.next()) {
                retweeted = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        return retweeted;
    }
    public boolean removeRetweet(int userId, int parentTweetId) throws SQLException {
        Connection conn = DBCon.getConnection();
        String sql = "DELETE FROM tweets WHERE user_id = ? AND parent_tweet_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.setInt(2, parentTweetId);
        int rows = ps.executeUpdate();
        ps.close();
        return rows > 0;
    }
    /**
     * Get all original tweets (non-retweets) by a specific user
     * @param userId The ID of the user whose tweets to fetch
     * @return List of Tweet objects
     */
    public List<Tweet> getTweetsByUserId(int userId) {
        List<Tweet> tweets = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweets WHERE user_id = ? AND parent_tweet_id IS NULL ORDER BY created_at DESC";
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
                tweets.add(tweet);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user tweets: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return tweets;
    }
    

    /**
     * Get all retweets by a specific user
     * @param userId The ID of the user whose retweets to fetch
     * @return List of Tweet objects representing retweets
     */
    public List<Tweet> getRetweetsByUserId(int userId) {
        List<Tweet> retweets = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweets WHERE user_id = ? AND parent_tweet_id IS NOT NULL ORDER BY created_at DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Tweet retweet = new Tweet();
                retweet.setTweetId(rs.getInt("tweet_id"));
                retweet.setUserId(rs.getInt("user_id"));
                retweet.setContent(rs.getString("content"));
                retweet.setParentTweetId(rs.getInt("parent_tweet_id"));
                retweet.setCreatedAt(rs.getString("created_at"));
                retweets.add(retweet);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user retweets: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return retweets;
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
    /**
     * Get a tweet by its ID
     * @param tweetId The ID of the tweet to fetch
     * @return Tweet object if found, null otherwise
     */
    public Tweet getTweetById(int tweetId) {
        Tweet tweet = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT * FROM tweets WHERE tweet_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            if (rs.next()) {
                tweet = new Tweet();
                tweet.setTweetId(rs.getInt("tweet_id"));
                tweet.setUserId(rs.getInt("user_id"));
                tweet.setContent(rs.getString("content"));
                tweet.setParentTweetId(rs.getObject("parent_tweet_id") != null ? rs.getInt("parent_tweet_id") : null);
                tweet.setCreatedAt(rs.getString("created_at"));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching tweet by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, ps, conn);
        }
        return tweet;
    }
    
}
