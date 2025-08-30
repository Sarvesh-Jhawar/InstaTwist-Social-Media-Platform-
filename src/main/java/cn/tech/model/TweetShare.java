package cn.tech.model;
public class TweetShare {
    private int shareId;
    private int tweetId;
    private int userId;
    private String sharedAt;

    // Getters and Setters
    public int getShareId() {
        return shareId;
    }

    public void setShareId(int shareId) {
        this.shareId = shareId;
    }

    public int getTweetId() {
        return tweetId;
    }

    public void setTweetId(int tweetId) {
        this.tweetId = tweetId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getSharedAt() {
        return sharedAt;
    }

    public void setSharedAt(String sharedAt) {
        this.sharedAt = sharedAt;
    }
}
