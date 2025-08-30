package cn.tech.model;

import java.sql.Timestamp;

public class Comment {
    private int id;
    private int postId;
    private int userId;
    private String content;
    private Timestamp createdAt;
    private String username; // Only used for fetching comments with user details

    // Constructor for fetching from DB (with username)
    public Comment() {}
    public Comment(int id, int postId, int userId, String content, Timestamp createdAt, String username) {
        this(id, postId, userId, content, createdAt); // Call existing constructor
        this.username = username;
    }

    // Constructor for fetching from DB (without username)
    public Comment(int id, int postId, int userId, String content, Timestamp createdAt) {
        this.id = id;
        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.createdAt = createdAt;
    }

    // Constructor for adding a new comment (without createdAt and username)
    public Comment(int postId, int userId, String content) {
        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.createdAt = new Timestamp(System.currentTimeMillis()); // Set timestamp when created
    }

    // Getters
    public int getId() { return id; }
    public int getPostId() { return postId; }
    public int getUserId() { return userId; }
    public String getContent() { return content; }
    public String getProfileImage() { return null; }
    public Timestamp getCreatedAt() { return createdAt; }
    public String getUsername() { return username; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setPostId(int postId) { this.postId = postId; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setContent(String content) { this.content = content; }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = (createdAt != null) ? createdAt : new Timestamp(System.currentTimeMillis()); 
    }
    public void setUsername(String username) { this.username = username; }
}
