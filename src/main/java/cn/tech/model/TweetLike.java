package cn.tech.model;

public class TweetLike {
    private int likeId;
    private int tweetId;
    private int userId;
    private String likedAt;

    // Getters and Setters
    public int getLikeId() {
        return likeId;
    }

    public void setLikeId(int likeId) {
        this.likeId = likeId;
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

    public String getLikedAt() {
        return likedAt;
    }

    public void setLikedAt(String likedAt) {
        this.likedAt = likedAt;
    }
}
