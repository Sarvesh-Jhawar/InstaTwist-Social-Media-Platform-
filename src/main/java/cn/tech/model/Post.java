package cn.tech.model;

import java.sql.Timestamp;

public class Post {
    private int id;
    private int userId;
    private String content;
    private String imagePath; // Attribute for the image path
    private Timestamp createdAt;
    private int likeCount; // Field for like count

    // Constructor for creating a new post
    public Post() {
    	
    }
    public Post(int userId, String content, String imagePath) {
        this.userId = userId;
        this.content = content;
        this.imagePath = imagePath;
        this.createdAt = new Timestamp(System.currentTimeMillis());
        this.likeCount = 0; // Default to 0 likes
    }

    // Constructor for fetching post from DB
    public Post(int id, int userId, String content, String imagePath, Timestamp createdAt, int likeCount) {
        this.id = id;
        this.userId = userId;
        this.content = content;
        this.imagePath = imagePath;
        this.createdAt = createdAt;
        this.likeCount = likeCount;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
}
