<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.tech.Dao.*" %>
<%@ page import="cn.tech.connection.*" %>
<%@ page import="cn.tech.model.*" %>
<%@ page import="java.util.List" %>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>

<%!
    // Utility method to get first letter of username
    public String getFirstLetter(String username) {
        if (username == null || username.isEmpty()) {
            return "?";
        }
        return username.substring(0, 1).toUpperCase();
    }
    
    // Utility method to check if file is video
    public boolean isVideo(String filename) {
        if (filename == null || filename.isEmpty()) return false;
        String ext = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        return ext.matches("mp4|webm|ogg|mov|avi");
    }
%>

<%
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize DAOs
    PostDao postDao = new PostDao();
    CommentDao commentDao = new CommentDao();
    FollowDao followDao = new FollowDao(DBCon.getConnection());
    TweetDao tweetDao = new TweetDao();
    TweetLikeDao tweetLikeDao = new TweetLikeDao();
    TweetCommentDao tweetCommentDao = new TweetCommentDao();
    UserDao userDao = new UserDao();
    
    // Fetch data
    List<Post> userPosts = postDao.getPostsByUserId(loggedInUser.getId());
    List<Post> likedPosts = postDao.getLikedPostsByUserId(loggedInUser.getId());
    List<Comment> userComments = commentDao.getCommentsByUserId(loggedInUser.getId());
    List<User> followingUsers = followDao.getFollowing(loggedInUser.getId());
    List<User> followerUsers = followDao.getFollowers(loggedInUser.getId());
    List<Tweet> userTweets = tweetDao.getTweetsByUserId(loggedInUser.getId());
    List<Tweet> likedTweets = tweetLikeDao.getLikedTweetsForUser(loggedInUser.getId());
    List<TweetComment> tweetComments = tweetCommentDao.getCommentsByUserId(loggedInUser.getId());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Profile - <%= loggedInUser.getUsername() %></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
   <style>
    :root {
        --primary-color: #4361ee;
        --secondary-color: #3f37c9;
        --accent-color: #4895ef;
        --light-color: #f8f9fa;
        --dark-color: #212529;
        --gray-color: #6c757d;
        --light-gray: #e9ecef;
        --border-radius: 12px;
        --box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        --transition: all 0.3s ease;
    }

    body {
        background-color: #f5f7fb;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        color: #333;
        line-height: 1.6;
    }

    .container {
        max-width: 1200px;
        padding: 20px 15px;
        margin: 0 auto;
    }

    /* Profile Header */
    .profile-header {
        background-color: white;
        border-radius: var(--border-radius);
        box-shadow: var(--box-shadow);
        margin-bottom: 30px;
        position: relative;
        overflow: hidden;
    }

    .profile-banner {
        height: 150px;
        background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
        position: relative;
    }

    .profile-avatar-container {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        border: 4px solid white;
        box-shadow: var(--box-shadow);
        position: absolute;
        bottom: -60px;
        right: 30px; /* Changed from left to right */
        overflow: hidden;
        background-color: #f0f0f0;
    }

    .profile-avatar {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .avatar-fallback {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
        color: white;
        font-size: 3rem;
        font-weight: bold;
    }

    .profile-header-content {
        padding: 70px 30px 30px;
        text-align: left; /* Ensure content aligns left */
    }

    .profile-header h1 {
        margin-bottom: 5px;
        font-size: 1.8rem;
        color: var(--dark-color);
    }

    .profile-header .text-muted {
        color: var(--gray-color);
        margin-bottom: 20px;
        display: block;
    }

    .profile-stats {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }

    .profile-stats div {
        text-align: center;
    }

    .profile-stats span:first-child {
        font-weight: bold;
        display: block;
        font-size: 1.2rem;
        color: var(--dark-color);
    }

    .profile-stats span:last-child {
        font-size: 0.9rem;
        color: var(--gray-color);
    }

    /* Navigation */
    .profile-nav {
        background: white;
        border-radius: var(--border-radius);
        box-shadow: var(--box-shadow);
        margin-bottom: 20px;
        overflow: hidden;
    }

    .profile-nav .nav {
        display: flex;
        flex-wrap: wrap;
    }

    .profile-nav .nav-link {
        padding: 15px 20px;
        font-weight: 500;
        color: var(--gray-color);
        border-bottom: 3px solid transparent;
        transition: var(--transition);
        text-decoration: none;
    }

    .profile-nav .nav-link.active {
        color: var(--primary-color);
        border-bottom-color: var(--primary-color);
    }

    .profile-nav .nav-link:hover {
        color: var(--primary-color);
        background-color: rgba(67, 97, 238, 0.05);
    }

    /* Content Cards */
    .content-card {
        background: white;
        border-radius: var(--border-radius);
        box-shadow: var(--box-shadow);
        margin-bottom: 20px;
        transition: var(--transition);
        overflow: hidden;
    }

    .content-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
    }

    .card-header {
        padding: 15px 20px;
        border-bottom: 1px solid var(--light-gray);
        font-weight: 600;
        background-color: #f8f9fa;
    }

    .card-body {
        padding: 20px;
    }

    /* User info */
    .user-info-container {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
    }

    .user-avatar-container {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 15px;
        flex-shrink: 0;
        background-color: #f0f0f0;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #e9ecef;
    }

    .user-avatar-sm {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .user-avatar-fallback {
        font-size: 1.5rem;
        font-weight: bold;
        color: white;
        background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .user-details {
        flex-grow: 1;
    }

    .username {
        font-weight: 600;
        margin-bottom: 2px;
        color: var(--dark-color);
    }

    .user-handle {
        font-size: 0.85rem;
        color: var(--gray-color);
        margin-bottom: 0;
    }

    .user-email {
        font-size: 0.85rem;
        color: var(--gray-color);
        margin-bottom: 0;
    }

    .post-time {
        font-size: 0.8rem;
        color: var(--gray-color);
    }

    /* Content */
    .post-content {
        margin-bottom: 15px;
        line-height: 1.6;
        color: var(--dark-color);
    }

    .media-container {
        position: relative;
        margin-bottom: 15px;
        border-radius: var(--border-radius);
        overflow: hidden;
        background-color: #f8f9fa;
    }

    .post-image {
        width: 100%;
        max-height: 500px;
        object-fit: contain;
        border-radius: var(--border-radius);
        display: block;
    }

    .post-video {
        width: 100%;
        max-height: 500px;
        border-radius: var(--border-radius);
        background: black;
        display: block;
    }

    .video-controls {
        position: absolute;
        bottom: 10px;
        left: 10px;
        right: 10px;
        display: flex;
        justify-content: center;
        opacity: 0.8;
    }

    .video-controls button {
        background: rgba(0,0,0,0.5);
        border: none;
        color: white;
        border-radius: 50%;
        width: 36px;
        height: 36px;
        margin: 0 5px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: var(--transition);
    }

    .video-controls button:hover {
        background: rgba(0,0,0,0.7);
        transform: scale(1.1);
    }

    /* Actions */
    .post-actions {
        display: flex;
        justify-content: space-between;
        border-top: 1px solid var(--light-gray);
        padding-top: 10px;
        margin-top: 15px;
    }

    .action-btn {
        background: none;
        border: none;
        color: var(--gray-color);
        cursor: pointer;
        transition: var(--transition);
        padding: 5px 10px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .action-btn:hover {
        color: var(--primary-color);
        background-color: rgba(67, 97, 238, 0.1);
    }

    .action-btn.active {
        color: var(--primary-color);
    }

    .action-btn i {
        font-size: 1.1rem;
    }

    /* Empty state */
    .empty-state {
        text-align: center;
        padding: 40px 20px;
        color: var(--gray-color);
    }

    .empty-state i {
        font-size: 3rem;
        color: var(--light-gray);
        margin-bottom: 15px;
    }

    .empty-state h5 {
        margin-bottom: 10px;
        color: var(--dark-color);
    }

    .empty-state p {
        max-width: 400px;
        margin: 0 auto;
    }

    /* Buttons */
    .btn {
        padding: 8px 16px;
        border-radius: var(--border-radius);
        font-weight: 500;
        transition: var(--transition);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        cursor: pointer;
        border: none;
    }

    .btn-sm {
        padding: 5px 10px;
        font-size: 0.85rem;
    }

    .btn-primary {
        background-color: var(--primary-color);
        color: white;
    }

    .btn-primary:hover {
        background-color: var(--secondary-color);
        color: white;
    }

    .btn-secondary {
        background-color: var(--light-gray);
        color: var(--dark-color);
    }

    .btn-secondary:hover {
        background-color: #d1d7e0;
        color: var(--dark-color);
    }

    .btn-danger {
        background-color: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background-color: #bb2d3b;
        color: white;
    }

    .btn-outline-primary {
        background-color: transparent;
        border: 1px solid var(--primary-color);
        color: var(--primary-color);
    }

    .btn-outline-primary:hover {
        background-color: var(--primary-color);
        color: white;
    }

    /* Dropdown */
    .dropdown-menu {
        border-radius: var(--border-radius);
        box-shadow: var(--box-shadow);
        border: none;
        padding: 5px 0;
    }

    .dropdown-item {
        padding: 8px 15px;
        color: var(--dark-color);
        display: flex;
        align-items: center;
        gap: 8px;
        transition: var(--transition);
    }

    .dropdown-item:hover {
        background-color: var(--light-color);
        color: var(--primary-color);
    }

    /* Responsive */
    @media (max-width: 768px) {
        .profile-avatar-container {
            width: 80px;
            height: 80px;
            bottom: -40px;
            right: 20px; /* Adjusted for mobile */
        }
        
        .profile-header-content {
            padding: 50px 20px 20px;
        }
        
        .profile-nav .nav-link {
            padding: 10px 15px;
            font-size: 0.9rem;
        }
        
        .user-avatar-container {
            width: 40px;
            height: 40px;
            margin-right: 10px;
        }
        
        .user-avatar-fallback {
            font-size: 1.2rem;
        }
    }

    @media (max-width: 576px) {
        .profile-banner {
            height: 120px;
        }
        
        .profile-avatar-container {
            width: 70px;
            height: 70px;
            bottom: -35px;
            right: 15px; /* Adjusted for small screens */
        }
        
        .profile-header h1 {
            font-size: 1.5rem;
        }
        
        .profile-stats {
            gap: 15px;
        }
        
        .profile-nav .nav {
            flex-direction: column;
        }
        
        .profile-nav .nav-link {
            border-bottom: none;
            border-left: 3px solid transparent;
        }
        
        .profile-nav .nav-link.active {
            border-bottom: none;
            border-left-color: var(--primary-color);
        }
    }

    /* Animations */
    .animate__animated {
        animation-duration: 0.5s;
    }

    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }

    .fade-in {
        animation-name: fadeIn;
    }

    @keyframes fadeOut {
        from { opacity: 1; }
        to { opacity: 0; }
    }

    .fade-out {
        animation-name: fadeOut;
    }

    /* Utility classes */
    .text-center {
        text-align: center;
    }

    .text-muted {
        color: var(--gray-color);
    }

    .mb-0 {
        margin-bottom: 0;
    }

    .mb-3 {
        margin-bottom: 1rem;
    }

    .me-2 {
        margin-right: 0.5rem;
    }

    .me-3 {
        margin-right: 1rem;
    }

    .d-flex {
        display: flex;
    }

    .align-items-center {
        align-items: center;
    }

    .justify-content-between {
        justify-content: space-between;
    }

    .justify-content-center {
        justify-content: center;
    }

    .flex-grow-1 {
        flex-grow: 1;
    }
</style>
</head>
<body>
<div class="container">
    <!-- Profile Header -->
    <div class="profile-header">
        <div class="profile-banner"></div>
        <div class="profile-avatar-container">
            <% if (loggedInUser.getProfileImage() != null && !loggedInUser.getProfileImage().isEmpty()) { %>
                <img src="profile-images/<%= loggedInUser.getProfileImage() %>" 
                     class="profile-avatar" alt="Profile Image">
            <% } else { %>
                <div class="avatar-fallback">
                    <%= getFirstLetter(loggedInUser.getUsername()) %>
                </div>
            <% } %>
        </div>
        <div class="p-4 pt-5">
            <h1 class="mb-1"><%= loggedInUser.getUsername() %></h1>
            <p class="text-muted mb-3"><%= loggedInUser.getEmail() %></p>
            
            <div class="d-flex mb-3">
                <div class="me-4">
                    <span class="fw-bold" id="followers-count"><%= followerUsers.size() %></span>
                    <span class="text-muted">Followers</span>
                </div>
                <div class="me-4">
                    <span class="fw-bold" id="following-count"><%= followingUsers.size() %></span>
                    <span class="text-muted">Following</span>
                </div>
                <div>
                    <span class="fw-bold"><%= userPosts.size() + userTweets.size() %></span>
                    <span class="text-muted">Posts</span>
                </div>
            </div>
            
            <small class="text-muted">
                <i class="fas fa-calendar-alt me-1"></i>
                Joined <%= loggedInUser.getCreatedAt() %>
            </small>
        </div>
    </div>

    <!-- Navigation -->
    <ul class="nav nav-tabs profile-nav" id="profileTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab" aria-controls="posts" aria-selected="true">
                <i class="fas fa-file-alt me-2"></i>Posts
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="tweets-tab" data-bs-toggle="tab" data-bs-target="#tweets" type="button" role="tab" aria-controls="tweets" aria-selected="false">
                <i class="fab fa-twitter me-2"></i>Tweets
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="connections-tab" data-bs-toggle="tab" data-bs-target="#connections" type="button" role="tab" aria-controls="connections" aria-selected="false">
                <i class="fas fa-users me-2"></i>Connections
            </button>
        </li>
    </ul>

    <!-- Tab Content -->
    <div class="tab-content" id="profileTabContent">
        
        <!-- Posts Tab -->
        <div class="tab-pane fade show active" id="posts" role="tabpanel" aria-labelledby="posts-tab">
            <ul class="nav nav-tabs mb-4" id="postsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="your-posts-tab" data-bs-toggle="tab" data-bs-target="#your-posts" type="button" role="tab" aria-controls="your-posts" aria-selected="true">Your Posts</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="liked-posts-tab" data-bs-toggle="tab" data-bs-target="#liked-posts" type="button" role="tab" aria-controls="liked-posts" aria-selected="false">Liked Posts</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="post-comments-tab" data-bs-toggle="tab" data-bs-target="#post-comments" type="button" role="tab" aria-controls="post-comments" aria-selected="false">Your Comments</button>
                </li>
            </ul>
            
            <div class="tab-content" id="postsTabContent">
                <!-- Your Posts -->
                <div class="tab-pane fade show active" id="your-posts" role="tabpanel" aria-labelledby="your-posts-tab">
                    <% if (userPosts.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-file-alt"></i>
                                <h5>No Posts Yet</h5>
                                <p>You haven't created any posts yet. Share your thoughts with the community!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (Post post : userPosts) { 
                            User author = userDao.getUserById(post.getUserId());
                        %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="user-info">
                                        <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                            <% if (author.getProfileImage() != null && !author.getProfileImage().isEmpty()) { %>
                                                <img src="profile-images/<%= author.getProfileImage() %>" 
                                                     class="user-avatar-sm" alt="User Avatar">
                                            <% } else { %>
                                                <div class="avatar-fallback" style="font-size: 1rem;">
                                                    <%= getFirstLetter(author.getUsername()) %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div>
                                            <h6 class="username mb-0"><%= author.getUsername() %></h6>
                                            <small class="post-time"><%= post.getCreatedAt() %></small>
                                        </div>
                                    </div>
                                    <p class="post-content"><%= post.getContent() %></p>
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <div class="media-container">
                                            <% if (isVideo(post.getImagePath())) { %>
                                                <video class="post-video" controls>
                                                    <source src="post-images/<%= post.getImagePath() %>" type="video/<%= post.getImagePath().substring(post.getImagePath().lastIndexOf(".") + 1 ) %>">
                                                    Your browser does not support the video tag.
                                                </video>
                                            <% } else { %>
                                                <img src="post-images/<%= post.getImagePath() %>" class="post-image" alt="Post Media">
                                            <% } %>
                                        </div>
                                    <% } %>
                                    <div class="post-actions">
                                        <button class="btn btn-sm btn-danger delete-post-btn" data-post-id="<%= post.getId() %>">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                
                <!-- Liked Posts -->
                <div class="tab-pane fade" id="liked-posts" role="tabpanel" aria-labelledby="liked-posts-tab">
                    <% if (likedPosts.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-heart"></i>
                                <h5>No Liked Posts</h5>
                                <p>You haven't liked any posts yet. Start exploring and show some love!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (Post post : likedPosts) { 
                            User author = userDao.getUserById(post.getUserId());
                        %>
                            <div class="content-card mb-3 liked-post-container" data-post-id="<%= post.getId() %>">
                                <div class="card-body">
                                    <div class="user-info">
                                        <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                            <% if (author.getProfileImage() != null && !author.getProfileImage().isEmpty()) { %>
                                                <img src="profile-images/<%= author.getProfileImage() %>" 
                                                     class="user-avatar-sm" alt="User Avatar">
                                            <% } else { %>
                                                <div class="avatar-fallback" style="font-size: 1rem;">
                                                    <%= getFirstLetter(author.getUsername()) %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div>
                                            <h6 class="username mb-0"><%= author.getUsername() %></h6>
                                            <small class="post-time"><%= post.getCreatedAt() %></small>
                                        </div>
                                    </div>
                                    <p class="post-content"><%= post.getContent() %></p>
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <div class="media-container">
                                            <% if (isVideo(post.getImagePath())) { %>
                                                <video class="post-video" controls>
                                                    <source src="post-images/<%= post.getImagePath() %>" type="video/<%= post.getImagePath().substring(post.getImagePath().lastIndexOf(".") + 1 ) %>">
                                                    Your browser does not support the video tag.
                                                </video>
                                            <% } else { %>
                                                <img src="post-images/<%= post.getImagePath() %>" class="post-image" alt="Post Media">
                                            <% } %>
                                        </div>
                                    <% } %>
                                    <div class="post-actions">
                                        <button class="btn btn-sm btn-danger unlike-post-btn" 
                                                data-post-id="<%= post.getId() %>"
                                                data-user-id="<%= loggedInUser.getId() %>">
                                            <i class="fas fa-thumbs-down"></i> Unlike
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                
                <!-- Post Comments -->
                <div class="tab-pane fade" id="post-comments" role="tabpanel" aria-labelledby="post-comments-tab">
                    <% if (userComments.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-comments"></i>
                                <h5>No Comments Yet</h5>
                                <p>You haven't commented on any posts yet. Join the conversation!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (Comment comment : userComments) { 
                            Post post = postDao.getPostById(comment.getPostId());
                            User postAuthor = userDao.getUserById(post.getUserId());
                        %>
                            <div class="content-card mb-3 comment-container" data-comment-id="<%= comment.getId() %>">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div class="user-info">
                                            <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                                <% if (postAuthor.getProfileImage() != null && !postAuthor.getProfileImage().isEmpty()) { %>
                                                    <img src="profile-images/<%= postAuthor.getProfileImage() %>" 
                                                         class="user-avatar-sm" alt="User Avatar">
                                                <% } else { %>
                                                    <div class="avatar-fallback" style="font-size: 1rem;">
                                                        <%= getFirstLetter(postAuthor.getUsername()) %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <small>On post by <%= postAuthor.getUsername() %></small>
                                        </div>
                                        <a href="post.jsp?postId=<%= post.getId() %>" class="btn btn-sm btn-outline-primary">
                                            View Post
                                        </a>
                                    </div>
                                    <div class="comment-content bg-light p-3 rounded mb-3">
                                        <strong><%= loggedInUser.getUsername() %></strong>: <%= comment.getContent() %>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted"><%= comment.getCreatedAt() %></small>
                                        <button class="btn btn-sm btn-danger delete-comment-btn" 
                                                data-comment-id="<%= comment.getId() %>">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Tweets Tab -->
        <div class="tab-pane fade" id="tweets" role="tabpanel" aria-labelledby="tweets-tab">
            <ul class="nav nav-tabs mb-4" id="tweetsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="your-tweets-tab" data-bs-toggle="tab" data-bs-target="#your-tweets" type="button" role="tab" aria-controls="your-tweets" aria-selected="true">Your Tweets</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="liked-tweets-tab" data-bs-toggle="tab" data-bs-target="#liked-tweets" type="button" role="tab" aria-controls="liked-tweets" aria-selected="false">Liked Tweets</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tweet-comments-tab" data-bs-toggle="tab" data-bs-target="#tweet-comments" type="button" role="tab" aria-controls="tweet-comments" aria-selected="false">Tweet Comments</button>
                </li>
            </ul>
            
            <div class="tab-content" id="tweetsTabContent">
                <!-- Your Tweets -->
                <div class="tab-pane fade show active" id="your-tweets" role="tabpanel" aria-labelledby="your-tweets-tab">
                    <% if (userTweets.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-feather-alt"></i>
                                <h5>No Tweets Yet</h5>
                                <p>You haven't tweeted anything yet. Share your thoughts with the world!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (Tweet tweet : userTweets) { 
                            User author = userDao.getUserById(tweet.getUserId());
                        %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="user-info">
                                        <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                            <% if (author.getProfileImage() != null && !author.getProfileImage().isEmpty()) { %>
                                                <img src="profile-images/<%= author.getProfileImage() %>" 
                                                     class="user-avatar-sm" alt="User Avatar">
                                            <% } else { %>
                                                <div class="avatar-fallback" style="font-size: 1rem;">
                                                    <%= getFirstLetter(author.getUsername()) %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div>
                                            <h6 class="username mb-0"><%= author.getUsername() %></h6>
                                            <small class="post-time"><%= tweet.getCreatedAt() %></small>
                                        </div>
                                    </div>
                                    <p class="post-content"><%= tweet.getContent() %></p>
                                    <div class="post-actions">
                                        <span class="me-3">
                                            <i class="fas fa-retweet"></i> <%= tweetDao.getRetweetCount(tweet.getTweetId()) %>
                                        </span>
                                        <span class="me-3">
                                            <i class="fas fa-heart"></i> <%= tweetLikeDao.getLikeCount(tweet.getTweetId()) %>
                                        </span>
                                        <span class="me-3">
                                            <i class="fas fa-comment"></i> <%= tweetCommentDao.getCommentCount(tweet.getTweetId()) %>
                                        </span>
                                        <button class="btn btn-sm btn-danger delete-tweet-btn" data-tweet-id="<%= tweet.getTweetId() %>">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                
                <!-- Liked Tweets -->
                <div class="tab-pane fade" id="liked-tweets" role="tabpanel" aria-labelledby="liked-tweets-tab">
                    <% if (likedTweets.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-heart"></i>
                                <h5>No Liked Tweets</h5>
                                <p>You haven't liked any tweets yet. Discover interesting tweets to like!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (Tweet tweet : likedTweets) { 
                            User author = userDao.getUserById(tweet.getUserId());
                        %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="user-info">
                                        <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                            <% if (author.getProfileImage() != null && !author.getProfileImage().isEmpty()) { %>
                                                <img src="profile-images/<%= author.getProfileImage() %>" 
                                                     class="user-avatar-sm" alt="User Avatar">
                                            <% } else { %>
                                                <div class="avatar-fallback" style="font-size: 1rem;">
                                                    <%= getFirstLetter(author.getUsername()) %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div>
                                            <h6 class="username mb-0"><%= author.getUsername() %></h6>
                                            <small class="post-time">@<%= author.getUsername().toLowerCase() %></small>
                                        </div>
                                    </div>
                                    <p class="post-content"><%= tweet.getContent() %></p>
                                    <div class="post-actions">
                                        <small class="text-muted me-3">
                                            <i class="fas fa-clock me-1"></i>Liked on <%= tweetLikeDao.getLikeDate(loggedInUser.getId(), tweet.getTweetId()) %>
                                        </small>
                                        <button class="unlike-tweet-btn" data-user-id="${user.id}" data-tweet-id="${tweet.id}">
    <i class="fas fa-heart-broken"></i> Unlike
</button>

                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                
                <!-- Tweet Comments -->
                <div class="tab-pane fade" id="tweet-comments" role="tabpanel" aria-labelledby="tweet-comments-tab">
                    <% if (tweetComments.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-comments"></i>
                                <h5>No Comments Yet</h5>
                                <p>You haven't commented on any tweets yet. Join the conversation!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (TweetComment comment : tweetComments) { 
                            Tweet tweet = tweetDao.getTweetById(comment.getTweetId());
                            User tweetAuthor = userDao.getUserById(tweet.getUserId());
                        %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div class="user-info">
                                            <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                                <% if (tweetAuthor.getProfileImage() != null && !tweetAuthor.getProfileImage().isEmpty()) { %>
                                                    <img src="profile-images/<%= tweetAuthor.getProfileImage() %>" 
                                                         class="user-avatar-sm" alt="User Avatar">
                                                <% } else { %>
                                                    <div class="avatar-fallback" style="font-size: 1rem;">
                                                        <%= getFirstLetter(tweetAuthor.getUsername()) %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <small>On tweet by <%= tweetAuthor.getUsername() %></small>
                                        </div>
                                        <a href="tweet.jsp?id=<%= tweet.getTweetId() %>" class="btn btn-sm btn-outline-primary">
                                            View Tweet
                                        </a>
                                    </div>
                                    <div class="comment-content bg-light p-3 rounded mb-3">
                                        <%= comment.getComment() %>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted"><%= comment.getCommentedAt() %></small>
                                        <button class="btn btn-sm btn-danger delete-tweet-comment-btn" 
                                                data-comment-id="<%= comment.getCommentId() %>">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Connections Tab -->
        <div class="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">
            <ul class="nav nav-tabs mb-4" id="connectionsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="following-tab" data-bs-toggle="tab" data-bs-target="#following" type="button" role="tab" aria-controls="following" aria-selected="true">Following</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="followers-tab" data-bs-toggle="tab" data-bs-target="#followers" type="button" role="tab" aria-controls="followers" aria-selected="false">Followers</button>
                </li>
            </ul>
            
            <div class="tab-content" id="connectionsTabContent">
                <!-- Following -->
                <div class="tab-pane fade show active" id="following" role="tabpanel" aria-labelledby="following-tab">
                    <% if (followingUsers.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-user-plus"></i>
                                <h5>Not Following Anyone</h5>
                                <p>You're not following anyone yet. Discover new people to follow!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (User kuser : followingUsers) { %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="user-info">
                                            <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                                <% if (kuser.getProfileImage() != null && !kuser.getProfileImage().isEmpty()) { %>
                                                    <img src="profile-images/<%= kuser.getProfileImage() %>" 
                                                         class="user-avatar-sm" alt="User Avatar">
                                                <% } else { %>
                                                    <div class="avatar-fallback" style="font-size: 1rem;">
                                                        <%= getFirstLetter(kuser.getUsername()) %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div>
                                                <h6 class="username mb-0"><%= kuser.getUsername() %></h6>
                                                <small class="text-muted"><%= kuser.getEmail() %></small>
                                            </div>
                                        </div>
                                        <button class="btn btn-sm btn-danger unfollow-btn" data-user-id="<%= kuser.getId() %>">
                                            <i class="fas fa-user-minus"></i> Unfollow
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                
                <!-- Followers -->
                <div class="tab-pane fade" id="followers" role="tabpanel" aria-labelledby="followers-tab">
                    <% if (followerUsers.isEmpty()) { %>
                        <div class="content-card empty-state">
                            <div class="card-body">
                                <i class="fas fa-users"></i>
                                <h5>No Followers Yet</h5>
                                <p>You don't have any followers yet. Share your profile to get more followers!</p>
                            </div>
                        </div>
                    <% } else { %>
                        <% for (User kuser : followerUsers) { 
                            boolean isFollowing = followDao.isFollowing(loggedInUser.getId(), kuser.getId());
                        %>
                            <div class="content-card mb-3">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="user-info">
                                            <div class="user-avatar-container me-2" style="width: 40px; height: 40px;">
                                                <% if (kuser.getProfileImage() != null && !kuser.getProfileImage().isEmpty()) { %>
                                                    <img src="profile-images/<%= user.getProfileImage() %>" 
                                                         class="user-avatar-sm" alt="User Avatar">
                                                <% } else { %>
                                                    <div class="avatar-fallback" style="font-size: 1rem;">
                                                        <%= getFirstLetter(kuser.getUsername()) %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div>
                                                <h6 class="username mb-0"><%= kuser.getUsername() %></h6>
                                                <small class="text-muted"><%= kuser.getEmail() %></small>
                                            </div>
                                        </div>

                                       <% if (isFollowing) { %>
    <div class="dropdown">
        <button class="btn btn-sm btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
            <i class="fas fa-user-check"></i> Following
        </button>
        <ul class="dropdown-menu">
            <li>
                <a class="dropdown-item unfollow-btn" data-user-id="<%= kuser.getId() %>" href="javascript:void(0);">
                    <i class="fas fa-user-times"></i> Remove Follower
                </a>
            </li>
            <li>
                <a class="dropdown-item remove-follower-btn" data-user-id="<%= kuser.getId() %>" href="#">
                    <i class="fas fa-user-minus"></i> Follow Back
                </a>
            </li>
        </ul>
    </div>
<% } else { %>
    <button class="btn btn-sm btn-primary follow-btn" data-user-id="<%= kuser.getId() %>">
        <i class="fas fa-user-plus"></i> Follow Back
    </button>
<% } %>

                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Required JavaScript -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
$(document).ready(function () {
    // Initialize all tabs
    var tabEls = document.querySelectorAll('button[data-bs-toggle="tab"]');
    tabEls.forEach(function(tabEl) {
        tabEl.addEventListener('click', function (event) {
            event.preventDefault();
            new bootstrap.Tab(this).show();
        });
    });
    var profileTab = new bootstrap.Tab(document.getElementById('posts-tab'));
    profileTab.show(); // Show posts tab by default
    
    // Handle tab switching
    $('#profileTabs button').click(function() {
        var tabId = $(this).attr('data-bs-target');
        $(tabId).addClass('show active').siblings().removeClass('show active');
    });
    
    // Initialize nested tabs
    $('[data-bs-toggle="tab"]').click(function(e) {
        e.preventDefault();
        var tabId = $(this).attr('data-bs-target');
        $(tabId).addClass('show active').siblings().removeClass('show active');
        $(this).addClass('active').siblings().removeClass('active');
    });

    // Delete post functionality
    $(document).on('click', '.delete-post-btn', function () {
        const button = $(this);
        const postId = button.data('post-id');
        const postElement = button.closest('.content-card');

        Swal.fire({
            title: 'Delete Post?',
            text: "You won't be able to revert this!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Deleting...');

                $.ajax({
                    url: 'DeletePostServlet',
                    type: 'POST',
                    data: { postId: postId },
                    success: function (response) {
                        const parts = response.split(':');
                        const type = parts[0];
                        const message = parts.slice(1).join(':').trim();

                        if (type === 'success') {
                            postElement.addClass('animate__animated animate__fadeOut');
                            postElement.on('animationend', function () {
                                $(this).remove();
                                showToast('success', 'Deleted', message);
                                updatePostCount();
                                checkEmptyState('#your-posts', 'posts');
                            });
                        } else {
                            showToast('error', 'Error', message);
                            button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                        }
                    },
                    error: function (xhr, status, error) {
                        showToast('error', 'Error', 'Failed to delete post: ' + error);
                        button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                    }
                });
            }
        });
    });

    // Delete tweet functionality
    $(document).on('click', '.delete-tweet-btn', function () {
        const button = $(this);
        const tweetId = button.data('tweet-id');
        const tweetElement = button.closest('.content-card');

        Swal.fire({
            title: 'Delete Tweet?',
            text: "You won't be able to revert this!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Deleting...');

                $.ajax({
                    url: 'DeleteTweetServlet',
                    type: 'POST',
                    data: { tweetId: tweetId },
                    success: function (response) {
                        const parts = response.split(':');
                        const type = parts[0];
                        const message = parts.slice(1).join(':').trim();

                        if (type === 'success') {
                            tweetElement.addClass('animate__animated animate__fadeOut');
                            tweetElement.on('animationend', function () {
                                $(this).remove();
                                showToast('success', 'Deleted', message);
                                checkEmptyState('#your-tweets', 'tweets');
                            });
                        } else {
                            showToast('error', 'Error', message);
                            button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                        }
                    },
                    error: function (xhr, status, error) {
                        showToast('error', 'Error', 'Failed to delete tweet: ' + error);
                        button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                    }
                });
            }
        });
    });

    // Delete tweet comment functionality
    $(document).on('click', '.delete-tweet-comment-btn', function () {
        const button = $(this);
        const commentId = button.data('comment-id');
        const commentElement = button.closest('.content-card');

        Swal.fire({
            title: 'Delete Comment?',
            text: "You won't be able to revert this!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Deleting...');

                $.ajax({
                    url: 'DeleteTweetCommentServlet',
                    type: 'POST',
                    data: { commentId: commentId },
                    success: function (response) {
                        const parts = response.split(':');
                        const type = parts[0];
                        const message = parts.slice(1).join(':').trim();

                        if (type === 'success') {
                            commentElement.addClass('animate__animated animate__fadeOut');
                            commentElement.on('animationend', function () {
                                $(this).remove();
                                showToast('success', 'Deleted', message);
                                checkEmptyState('#tweet-comments', 'tweet comments');
                            });
                        } else {
                            showToast('error', 'Error', message);
                            button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                        }
                    },
                    error: function (xhr, status, error) {
                        showToast('error', 'Error', 'Failed to delete comment: ' + error);
                        button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                    }
                });
            }
        });
    });

    // Handle post unliking
    $(document).on('click', '.unlike-post-btn', function() {
        const button = $(this);
        const postId = button.data('post-id');
        const userId = button.data('user-id');
        const postElement = button.closest('.liked-post-container');

        Swal.fire({
            title: 'Unlike Post?',
            text: "This post will be removed from your liked posts",
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, unlike it'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Unliking...');

                $.ajax({
                    url: 'UnlikePostServlet',
                    type: 'POST',
                    data: { 
                        postId: postId,
                        userId: userId
                    },
                    success: function(response) {
                        if (response.startsWith('success')) {
                            const newLikeCount = response.split(':')[1];
                            
                            postElement.addClass('animate__animated animate__fadeOut');
                            postElement.on('animationend', function() {
                                $(this).remove();
                                showToast('success', 'Success', 'Post unliked successfully');
                                
                                // Update like count display if needed
                                $('.like-count[data-post-id="'+postId+'"]').text(newLikeCount);
                                
                                // Check if we need to show empty state
                                if ($('#liked-posts .liked-post-container').length === 0) {
                                    $('#liked-posts').html(`
                                        <div class="content-card empty-state">
                                            <div class="card-body">
                                                <i class="fas fa-heart"></i>
                                                <h5>No Liked Posts</h5>
                                                <p>You haven't liked any posts yet. Start exploring and show some love!</p>
                                            </div>
                                        </div>
                                    `);
                                }
                            });
                        } else if (response === 'error:User not logged in') {
                            window.location.href = 'login.jsp';
                        } else {
                            showToast('error', 'Error', response.replace('error:', ''));
                            button.prop('disabled', false).html('<i class="fas fa-thumbs-down"></i> Unlike');
                        }
                    },
                    error: function(xhr, status, error) {
                        showToast('error', 'Error', 'Failed to unlike post: ' + error);
                        button.prop('disabled', false).html('<i class="fas fa-thumbs-down"></i> Unlike');
                    }
                });
            }
        });
    });

    $(document).on('click', '.unlike-tweet-btn', function() {
        const button = $(this);
        const tweetId = button.data('tweet-id');
        const userId = button.data('user-id'); // make sure this data attribute is present
        const tweetElement = button.closest('.content-card');

        Swal.fire({
            title: 'Unlike Tweet?',
            text: "This tweet will be removed from your liked tweets",
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, unlike it'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Unliking...');

                $.ajax({
                    url: 'likeTweet', // ✅ match servlet mapping
                    type: 'POST',
                    data: {
                        userId: userId,
                        tweetId: tweetId,
                        action: 'unlike'
                    },
                    success: function(response) {
                        console.log("Server response:", response); // Add this line

                        if (response === 'success') {
                            tweetElement.addClass('animate__animated animate__fadeOut');
                            tweetElement.on('animationend', function() {
                                $(this).remove();
                                showToast('success', 'Success', 'Tweet unliked successfully');
                                checkEmptyState('#liked-tweets', 'liked tweets');
                            });
                        } else {
                            showToast('error', 'Error', 'Failed to unlike tweet');
                            button.prop('disabled', false).html('<i class="fas fa-heart-broken"></i> Unlike');
                        }
                    },
                    error: function() {
                        showToast('error', 'Error', 'Failed to unlike tweet');
                        button.prop('disabled', false).html('<i class="fas fa-heart-broken"></i> Unlike');
                    }
                });
            }
        });
    });

    // Delete comment functionality
    $(document).on('click', '.delete-comment-btn', function() {
        const button = $(this);
        const commentId = button.data('comment-id');
        const commentElement = button.closest('.comment-container');

        Swal.fire({
            title: 'Delete Comment?',
            text: "You won't be able to revert this!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed) {
                button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Deleting...');

                $.ajax({
                    url: 'DeleteCommentServlet',
                    type: 'POST',
                    data: { commentId: commentId },
                    success: function(response) {
                        if (response === 'success') {
                            commentElement.addClass('animate__animated animate__fadeOut');
                            commentElement.on('animationend', function() {
                                $(this).remove();
                                showToast('success', 'Success', 'Comment deleted successfully');
                                
                                // Check if we need to show empty state
                                if ($('#post-comments .comment-container').length === 0) {
                                    $('#post-comments').html(`
                                        <div class="content-card empty-state">
                                            <div class="card-body">
                                                <i class="fas fa-comments"></i>
                                                <h5>No Comments Yet</h5>
                                                <p>You haven't commented on any posts yet. Join the conversation!</p>
                                            </div>
                                        </div>
                                    `);
                                }
                            });
                        } else if (response === 'error:not_logged_in') {
                            window.location.href = 'login.jsp';
                        } else {
                            showToast('error', 'Error', 'Failed to delete comment');
                            button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                        }
                    },
                    error: function(xhr, status, error) {
                        showToast('error', 'Error', 'Failed to delete comment: ' + error);
                        button.prop('disabled', false).html('<i class="fas fa-trash-alt"></i> Delete');
                    }
                });
            }
        });
    });

    $(document).on('click', '.follow-btn, .unfollow-btn', function (e) {
        e.preventDefault();

        const button = $(this);
        const userId = button.data('user-id');
        const isFollow = button.hasClass('follow-btn');
        const userElement = button.closest('.content-card');

        const isFollowersPage = userElement.closest('#followers').length > 0;
        const isFollowingPage = userElement.closest('#following').length > 0;

        button.prop('disabled', true);
        button.html(`<i class="fas fa-spinner fa-spin"></i> ${isFollow ? 'Following...' : 'Unfollowing...'}`);

        if (isFollow) {
            // ➕ FOLLOW
            $.ajax({
                url: 'FollowServlet',
                type: 'POST',
                data: { userId: userId, action: 'follow' },
                dataType: 'json',
                success: function (response) {
                    if (response.success) {
                        button.removeClass('btn-primary follow-btn')
                              .addClass('btn-secondary unfollow-btn')
                              .html('<i class="fas fa-user-check"></i> Following');

                        // Update following count
                        const followingCount = parseInt($('#following-count').text());
                        $('#following-count').text(followingCount + 1);

                        // If this is a follower (on followers page), update followers count
                        if (isFollowersPage) {
                            const followersCount = parseInt($('#followers-count').text());
                            $('#followers-count').text(followersCount + 1);
                        }

                        showToast('success', 'Followed', 'User followed successfully');
                    } else {
                        showToast('error', 'Error', 'Failed to follow user');
                        button.html('<i class="fas fa-user-plus"></i> Follow Back');
                    }
                },
                error: function () {
                    showToast('error', 'Error', 'Server error while following');
                    button.html('<i class="fas fa-user-plus"></i> Follow Back');
                },
                complete: function () {
                    button.prop('disabled', false);
                }
            });

        } else {
            // 🚫 UNFOLLOW or REMOVE FOLLOWER
            $.ajax({
                url: 'UnfollowServlet',
                type: 'POST',
                data: { followedId: userId },
                success: function (response) {
                    if (response.trim() === 'success') {
                        if (isFollowingPage) {
                            // You're unfollowing someone → Show "Follow Back"
                            button.removeClass('btn-secondary unfollow-btn')
                                  .addClass('btn-primary follow-btn')
                                  .html('<i class="fas fa-user-plus"></i> Follow Back');

                            // Update following count
                            const followingCount = parseInt($('#following-count').text());
                            $('#following-count').text(followingCount - 1);

                            showToast('success', 'Unfollowed', 'You have unfollowed the user');
                        } else if (isFollowersPage) {
                            // You're removing someone who follows you → Remove card
                            userElement.addClass('animate__animated animate__fadeOut');
                            userElement.on('animationend', function () {
                                $(this).remove();
                                
                                // Update followers count
                                const followersCount = parseInt($('#followers-count').text());
                                $('#followers-count').text(followersCount - 1);
                                
                                showToast('success', 'Removed', 'Follower removed');
                                checkEmptyState('#followers', 'followers');
                            });
                        }
                    } else {
                        showToast('error', 'Error', 'Failed to unfollow/remove follower');
                        button.html('<i class="fas fa-user-check"></i> Following');
                    }
                },
                error: function () {
                    showToast('error', 'Error', 'Server error during unfollow/remove');
                    button.html('<i class="fas fa-user-check"></i> Following');
                },
                complete: function () {
                    button.prop('disabled', false);
                }
            });
        }
    });

    function showToast(icon, title, text) {
        Swal.fire({
            toast: true,
            icon: icon,
            title: title,
            text: text,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
    }

    function updatePostCount() {
        const postCount = $('.content-card').length;
        $('.post-count').text(postCount);
    }

    function checkEmptyState(containerId, type) {
        const container = $(containerId);
        if (container.find('.content-card').length === 0) {
            container.append(`
                <div class="content-card empty-state">
                    <div class="card-body">
                        <i class="fas fa-info-circle"></i>
                        <h5>No ${type} Yet</h5>
                        <p>You haven't created any ${type} yet.</p>
                    </div>
                </div>
            `);
        }
    }
});
</script>

</body>
</html>