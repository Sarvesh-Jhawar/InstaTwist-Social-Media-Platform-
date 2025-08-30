package cn.tech.model;

import java.sql.Timestamp;

public class Follow {
    private int followerId;
    private int followingId;
    private Timestamp createdAt;

    public Follow(int followerId, int followingId, Timestamp createdAt) {
        this.followerId = followerId;
        this.followingId = followingId;
        this.createdAt = createdAt;
    }

    public int getFollowerId() {
        return followerId;
    }

    public int getFollowingId() {
        return followingId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }
}
