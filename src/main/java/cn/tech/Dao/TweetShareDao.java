package cn.tech.Dao;



import cn.tech.connection.DBCon;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TweetShareDao {

    // Add a share
    public boolean addShare(int userId, int tweetId) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBCon.getConnection();
            String sql = "INSERT INTO tweet_shares (tweet_id, user_id) VALUES (?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
        } catch (SQLException e) {
            System.err.println("Error adding share: " + e.getMessage());
        } finally {
            closeResources(ps, conn);
        }
        return success;
    }

    // Get total shares for a tweet
    public int getShareCount(int tweetId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBCon.getConnection();
            String sql = "SELECT COUNT(*) FROM tweet_shares WHERE tweet_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tweetId);
            rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching share count: " + e.getMessage());
        } finally {
            closeResources(rs, ps, conn);
        }
        return count;
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
}
