package cn.tech.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String email;
    private Timestamp createdAt; // Added missing field
    private int unreadCount = 0; // default 0
	private Object profilePic;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Timestamp getCreatedAt() { return createdAt; } // Getter for createdAt
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    // Fixed setter
    public String getProfileImage() {
    	return null;
    }
    public void setProfileImage(String profilePic) { this.profilePic = null; }
    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return id == user.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

}
