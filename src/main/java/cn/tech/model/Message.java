package cn.tech.model;

import java.sql.Timestamp;

public class Message {
    private int id;
    private int senderId;
    private int receiverId;
    private String content;
    private int postId;    // nullable
    private int profileId; // nullable
    private int tweetId;   // nullable
    private Timestamp createdAt;
    private boolean isRead;

    // Constructor
    public Message(int senderId, int receiverId, String content, int postId, int profileId, int tweetId) {
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.content = content;
        this.postId = postId;
        this.profileId = profileId;
        this.tweetId = tweetId;
        this.isRead = false;
        this.createdAt = new Timestamp(System.currentTimeMillis());
    }

    public Message() {
        // default constructor
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getPostId() {
        return postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public int getTweetId() {
        return tweetId;
    }

    public void setTweetId(int tweetId) {
        this.tweetId = tweetId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }
}
