package cn.tech.model;

public class Tweet {
    private int tweetId;
    private int userId;
    private String content;
    private Integer parentTweetId; // can be null
    private String createdAt;

    // Getters and Setters
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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getParentTweetId() {
        return parentTweetId;
    }

    public void setParentTweetId(Integer parentTweetId) {
        this.parentTweetId = parentTweetId;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}

