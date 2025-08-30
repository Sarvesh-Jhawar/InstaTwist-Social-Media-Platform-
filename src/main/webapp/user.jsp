<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%@ page import="cn.tech.Dao.UserDao" %>
<%@ page import="cn.tech.Dao.PostDao" %>
<%@ page import="cn.tech.Dao.FollowDao" %>
<%@ page import="cn.tech.model.User" %>
<%@ page import="cn.tech.model.Post" %>
<%@ page import="java.util.List" %>
<%@ page import="cn.tech.connection.DBCon" %>
<%@ page import="cn.tech.Dao.TweetDao" %>
<%@ page import="cn.tech.Dao.TweetLikeDao" %>
<%@ page import="cn.tech.model.Tweet" %>
<%
    HttpSession sess = request.getSession(false);
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User loggedUser = (User) session.getAttribute("user");
%>
<%
    // Get user ID from request
    String userIdParam = request.getParameter("userId");
    User profileUser = null;
    List<Post> userPosts = null;
    List<User> followersList = null, followingList = null;
    List<Tweet> userTweets = null;
    int tweetsCount = 0;
    TweetLikeDao tweetLikeDao = null;
    int followersCount = 0, followingCount = 0;
    boolean isFollowing = false;

    if (userIdParam != null) {
        int userId = Integer.parseInt(userIdParam);
        UserDao userDao = new UserDao();
        PostDao postDao = new PostDao();
        FollowDao followDao = new FollowDao(DBCon.getConnection());

        profileUser = userDao.getUserById(userId);
        userPosts = postDao.getPostsByUserId(userId);

        // Fetch followers and following list
        followersList = followDao.getFollowers(userId);
        followingList = followDao.getFollowing(userId);
        followersCount = followersList.size();
        followingCount = followingList.size();
        TweetDao tweetDao = new TweetDao();
        tweetLikeDao = new TweetLikeDao();
        
        userTweets = tweetDao.getTweetsByUserId(userId);
        tweetsCount = userTweets.size();
        
        // Check if current user is following this profile
        if (loggedUser != null) {
            isFollowing = followDao.isFollowing(loggedUser.getId(), userId);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= profileUser != null ? profileUser.getUsername() + "'s Profile" : "User Profile" %></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/plyr/3.7.8/plyr.css" />
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
            --success-color: #4bb543;
        }

        body {
            background-color: #f5f7fb;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .profile-header {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 30px;
            overflow: hidden;
            position: relative;
        }

        .profile-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 120px;
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            z-index: 0;
        }

        .profile-content {
            position: relative;
            z-index: 1;
            padding: 30px;
        }

        .profile-avatar-container {
            position: relative;
            width: 150px;
            height: 150px;
            margin: 0 auto 20px;
        }

        .profile-avatar {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid white;
            box-shadow: var(--box-shadow);
        }

        .avatar-fallback {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary-color);
            color: white;
            font-size: 3.5rem;
            font-weight: bold;
            border: 5px solid white;
            box-shadow: var(--box-shadow);
        }

        .profile-name {
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 5px;
        }

        .profile-email {
            color: var(--gray-color);
            margin-bottom: 20px;
        }

        .profile-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-item {
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .stat-item:hover {
            transform: translateY(-3px);
        }

        .stat-count {
            font-weight: 700;
            font-size: 1.2rem;
            color: var(--dark-color);
        }

        .stat-label {
            font-size: 0.9rem;
            color: var(--gray-color);
        }

        .profile-tabs {
            border-bottom: none;
            margin-bottom: 20px;
        }

        .profile-tabs .nav-link {
            padding: 12px 20px;
            font-weight: 500;
            color: var(--gray-color);
            border: none;
            border-radius: var(--border-radius);
            margin-right: 10px;
            transition: all 0.3s ease;
        }

        .profile-tabs .nav-link.active {
            background-color: var(--primary-color);
            color: white;
        }

        .profile-tabs .nav-link:hover:not(.active) {
            background-color: var(--light-gray);
        }

        .tab-content {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            padding: 20px;
        }

        .post-card {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 20px;
            transition: transform 0.3s ease;
            background-color: white;
        }

        .post-card:hover {
            transform: translateY(-5px);
        }

        .post-content {
            margin-bottom: 15px;
            line-height: 1.5;
            white-space: pre-line;
        }

        .post-media-container {
            position: relative;
            border-radius: var(--border-radius);
            overflow: hidden;
            margin-bottom: 15px;
            background-color: #000;
        }

        .post-image {
            width: 100%;
            max-height: 500px;
            object-fit: contain;
            display: block;
        }

        .post-video {
            width: 100%;
        }

        .post-meta {
            color: var(--gray-color);
            font-size: 0.9rem;
            display: flex;
            align-items: center;
        }

        .post-actions {
            display: flex;
            gap: 15px;
            margin-top: 10px;
        }

        .post-action {
            color: var(--gray-color);
            cursor: pointer;
            transition: color 0.2s;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .post-action:hover {
            color: var(--primary-color);
        }

        .post-action.liked {
            color: #ff3040;
        }

        .user-card {
            display: flex;
            align-items: center;
            padding: 15px;
            border-radius: var(--border-radius);
            margin-bottom: 10px;
            transition: background-color 0.2s;
        }

        .user-card:hover {
            background-color: var(--light-gray);
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 15px;
            border: 2px solid var(--light-gray);
        }

        .user-avatar-fallback {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary-color);
            color: white;
            font-weight: bold;
            margin-right: 15px;
            border: 2px solid var(--light-gray);
        }

        .user-info {
            flex-grow: 1;
        }

        .username {
            font-weight: 600;
            margin-bottom: 0;
            color: var(--dark-color);
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--gray-color);
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            color: var(--light-gray);
        }

        .btn-follow {
            border-radius: 20px;
            padding: 8px 20px;
            font-weight: 500;
            min-width: 100px;
            transition: all 0.3s ease;
        }

        .btn-follow:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .btn-follow.following {
            background-color: var(--success-color);
            border-color: var(--success-color);
        }

        .media-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
        }

        /* Loading spinner */
        .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
            margin-left: 8px;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .profile-avatar-container {
                width: 100px;
                height: 100px;
            }
            
            .avatar-fallback {
                font-size: 2.5rem;
            }
            
            .profile-tabs .nav-link {
                padding: 8px 12px;
                font-size: 0.9rem;
                margin-right: 5px;
            }
            
            .post-media-container {
                max-height: 300px;
            }
        }
        .tweet-card {
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            transition: transform 0.3s ease;
            border: none;
        }

        .tweet-card:hover {
            transform: translateY(-3px);
        }

        .avatar-fallback-sm {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary-color);
            color: white;
            font-weight: bold;
        }

        .tweet-actions {
            color: var(--gray-color);
        }

        .tweet-action {
            cursor: pointer;
            transition: color 0.2s;
            display: flex;
            align-items: center;
        }

        .tweet-action:hover {
            color: var(--primary-color);
        }

        .tweet-action.liked, .tweet-action.liked:hover {
            color: #ff3040;
        }

        .tweet-action.retweet-action:hover {
            color: var(--success-color);
        }
        
        .btn-message {
            border-radius: 20px;
            padding: 8px 15px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-message-sm {
            border-radius: 50%;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <% if (profileUser != null) { %>
            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-content text-center text-md-start">
                    <div class="d-flex flex-column flex-md-row align-items-center">
                        <div class="profile-avatar-container me-md-4">
                            <% if (profileUser.getProfileImage() != null && !profileUser.getProfileImage().isEmpty()) { %>
                                <img src="post-images/<%= profileUser.getProfileImage() %>" 
                                     class="profile-avatar" 
                                     alt="<%= profileUser.getUsername() %>'s profile picture"
                                     onerror="this.onerror=null;this.parentNode.innerHTML='<div class=\"avatar-fallback\"><%= profileUser.getUsername().substring(0, 1).toUpperCase() %></div>'">
                            <% } else { %>
                                <div class="avatar-fallback">
                                    <%= profileUser.getUsername().substring(0, 1).toUpperCase() %>
                                </div>
                            <% } %>
                        </div>
                        <div class="profile-info">
                            <h1 class="profile-name"><%= profileUser.getUsername() %></h1>
                            <p class="profile-email"><i class="fas fa-envelope me-2"></i><%= profileUser.getEmail() %></p>
                            
                            <div class="profile-stats">
                                <div class="stat-item" onclick="document.querySelector('.nav-link[href=\"#posts\"]').click()">
                                    <div class="stat-count"><%= userPosts != null ? userPosts.size() : 0 %></div>
                                    <div class="stat-label">Posts</div>
                                </div>
                                <div class="stat-item" onclick="document.querySelector('.nav-link[href=\"#followers\"]').click()">
                                    <div class="stat-count"><%= followersCount %></div>
                                    <div class="stat-label">Followers</div>
                                </div>
                                <div class="stat-item" onclick="document.querySelector('.nav-link[href=\"#following\"]').click()">
                                    <div class="stat-count"><%= followingCount %></div>
                                    <div class="stat-label">Following</div>
                                </div>
                            </div>
                            
                            <div class="d-flex">
                                <% if (loggedUser != null && loggedUser.getId() != profileUser.getId()) { %>
                                    <button class="btn <%= isFollowing ? "btn-success following" : "btn-primary" %> btn-follow"
                                        id="followButton" data-user-id="<%= profileUser.getId() %>">
                                        <%= isFollowing ? "Following" : "Follow" %>
                                        <span class="spinner"></span>
                                    </button>
                                    
                                    <% if (isFollowing) { %>
                                        <a href="message.jsp?userId=<%= profileUser.getId() %>" class="btn btn-outline-primary btn-message ms-2">
                                            <i class="fas fa-envelope me-1"></i> Message
                                        </a>
                                    <% } %>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Navigation Tabs -->
            <ul class="nav nav-pills profile-tabs">
                <li class="nav-item">
                    <a class="nav-link active" data-bs-toggle="tab" href="#posts">Posts</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tweets">Tweets (<%= tweetsCount %>)</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#followers">Followers (<%= followersCount %>)</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#following">Following (<%= followingCount %>)</a>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content">
                <!-- Posts Tab -->
                <div id="posts" class="tab-pane fade show active">
                    <h3 class="mb-4"><i class="fas fa-images me-2"></i>Posts</h3>
                    
                    <% if (userPosts != null && !userPosts.isEmpty()) { %>
                        <% for (Post post : userPosts) { 
                            boolean isImage = post.getImagePath() != null && 
                                           (post.getImagePath().toLowerCase().endsWith(".jpg") || 
                                            post.getImagePath().toLowerCase().endsWith(".jpeg") || 
                                            post.getImagePath().toLowerCase().endsWith(".png") || 
                                            post.getImagePath().toLowerCase().endsWith(".gif"));
                            boolean isVideo = post.getImagePath() != null && 
                                            (post.getImagePath().toLowerCase().endsWith(".mp4") || 
                                            post.getImagePath().toLowerCase().endsWith(".webm") || 
                                            post.getImagePath().toLowerCase().endsWith(".ogg"));
                        %>
                            <div class="post-card">
                                <div class="card-body">
                                    <p class="post-content"><%= post.getContent() %></p>
                                    
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <div class="post-media-container">
                                            <% if (isImage) { %>
                                                <img src="post-images/<%= post.getImagePath() %>" class="post-image" alt="Post image">
                                                <span class="media-badge">PHOTO</span>
                                            <% } else if (isVideo) { %>
                                                <video class="post-video" controls>
                                                    <source src="post-images/<%= post.getImagePath() %>" type="video/mp4">
                                                    Your browser does not support the video tag.
                                                </video>
                                                <span class="media-badge">VIDEO</span>
                                            <% } else { %>
                                                <a href="post-images/<%= post.getImagePath() %>" class="btn btn-primary" download>Download File</a>
                                            <% } %>
                                        </div>
                                    <% } %>
                                    
                                    <div class="d-flex justify-content-between align-items-center">
                                        <p class="post-meta mb-0"><i class="far fa-clock me-1"></i><%= post.getCreatedAt() %></p>
                                        <div class="post-actions">
                                            <div class="post-action" data-post-id="<%= post.getId() %>">
                                                <i class="far fa-heart"></i>
                                                <span><%= post.getLikeCount() %></span>
                                            </div>
                                            <div class="post-action">
                                                <i class="far fa-comment"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="empty-state">
                            <i class="fas fa-file-alt"></i>
                            <h4>No Posts Yet</h4>
                            <p><%= profileUser.getUsername() %> hasn't shared any posts yet.</p>
                        </div>
                    <% } %>
                </div>
                
                <!-- Tweets Tab -->
                <div id="tweets" class="tab-pane fade">
                    <h3 class="mb-4"><i class="fab fa-twitter me-2"></i>Tweets</h3>
                    
                    <% if (userTweets != null && !userTweets.isEmpty()) { 
                        TweetDao tweetDao = new TweetDao();
                    %>
                        <% for (Tweet tweet : userTweets) { 
                            int likeCount = tweetLikeDao.getLikesCount(tweet.getTweetId());
                            boolean isLiked = loggedUser != null && tweetLikeDao.isLikedByUser(loggedUser.getId(), tweet.getTweetId());
                        %>
                            <div class="tweet-card card mb-3">
                                <div class="card-body">
                                    <div class="d-flex">
                                        <div class="flex-shrink-0 me-3">
                                            <% if (profileUser.getProfileImage() != null && !profileUser.getProfileImage().isEmpty()) { %>
                                                <img src="post-images/<%= profileUser.getProfileImage() %>" 
                                                     class="rounded-circle" 
                                                     width="50" 
                                                     height="50"
                                                     alt="<%= profileUser.getUsername() %>"
                                                     onerror="this.onerror=null;this.src='https://via.placeholder.com/50'">
                                            <% } else { %>
                                                <div class="avatar-fallback-sm">
                                                    <%= profileUser.getUsername().substring(0, 1).toUpperCase() %>
                                                </div>
                                            <% } %>
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <h5 class="mb-0">
                                                    <a href="profile.jsp?userId=<%= profileUser.getId() %>" class="text-decoration-none">
                                                        <%= profileUser.getUsername() %>
                                                    </a>
                                                </h5>
                                                <small class="text-muted"><%= tweet.getCreatedAt() %></small>
                                            </div>
                                            <p class="mb-3"><%= tweet.getContent() %></p>
                                            
                                            <div class="tweet-actions d-flex">
                                                <div class="tweet-action like-action me-3 <%= isLiked ? "liked" : "" %>" 
                                                     data-tweet-id="<%= tweet.getTweetId() %>">
                                                    <i class="<%= isLiked ? "fas" : "far" %> fa-heart me-1"></i>
                                                    <span class="like-count"><%= likeCount %></span>
                                                </div>
                                                <div class="tweet-action comment-action me-3">
                                                    <i class="far fa-comment me-1"></i>
                                                    <span>0</span> <!-- Replace with actual comment count -->
                                                </div>
                                                <div class="tweet-action retweet-action" data-tweet-id="<%= tweet.getTweetId() %>">
                                                    <i class="fas fa-retweet me-1"></i>
                                                    <span><%= tweetDao.getRetweetCount(tweet.getTweetId()) %></span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="empty-state">
                            <i class="fab fa-twitter"></i>
                            <h4>No Tweets Yet</h4>
                            <p><%= profileUser.getUsername() %> hasn't tweeted anything yet.</p>
                        </div>
                    <% } %>
                </div>
                
                <!-- Followers Tab -->
                <div id="followers" class="tab-pane fade">
                    <h3 class="mb-4"><i class="fas fa-users me-2"></i>Followers</h3>
                    
                    <% if (followersList != null && !followersList.isEmpty()) { 
                        FollowDao followDaoForFollowers = new FollowDao(DBCon.getConnection());
                    %>
                        <% for (User follower : followersList) { 
                            boolean isFollowingFollower = false;
                            if (loggedUser != null) {
                                isFollowingFollower = followDaoForFollowers.isFollowing(loggedUser.getId(), follower.getId());
                            }
                        %>
                            <div class="user-card">
                                <% if (follower.getProfileImage() != null && !follower.getProfileImage().isEmpty()) { %>
                                    <img src="post-images/<%= follower.getProfileImage() %>" 
                                         class="user-avatar" 
                                         alt="<%= follower.getUsername() %>'s profile picture"
                                         onerror="this.onerror=null;this.parentNode.innerHTML='<div class=\"user-avatar-fallback\"><%= follower.getUsername().substring(0, 1).toUpperCase() %></div><div class=\"user-info\"><h5 class=\"username\"><a href=\"profile.jsp?userId=<%= follower.getId() %>\" class=\"text-decoration-none\"><%= follower.getUsername() %></a></h5></div>'">
                                <% } else { %>
                                    <div class="user-avatar-fallback">
                                        <%= follower.getUsername().substring(0, 1).toUpperCase() %>
                                    </div>
                                <% } %>
                                <div class="user-info">
                                    <h5 class="username">
                                        <a href="profile.jsp?userId=<%= follower.getId() %>" class="text-decoration-none">
                                            <%= follower.getUsername() %>
                                        </a>
                                    </h5>
                                </div>
                                
                                <div class="d-flex">
                                    <% if (loggedUser != null && loggedUser.getId() != follower.getId()) { %>
                                        <button class="btn <%= isFollowingFollower ? "btn-secondary" : "btn-primary" %> btn-sm follow-tab-btn" 
                                                data-user-id="<%= follower.getId() %>">
                                            <%= isFollowingFollower ? "Following" : "Follow Back" %>
                                        </button>
                                        
                                        <% if (isFollowingFollower) { %>
                                            <a href="message.jsp?userId=<%= follower.getId() %>" class="btn btn-outline-primary btn-message-sm ms-2">
                                                <i class="fas fa-envelope"></i>
                                            </a>
                                        <% } %>
                                    <% } else if (loggedUser != null && loggedUser.getId() == follower.getId()) { %>
                                        <span class="badge bg-light text-dark">You</span>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="empty-state">
                            <i class="fas fa-user-slash"></i>
                            <h4>No Followers Yet</h4>
                            <p><%= profileUser.getUsername() %> doesn't have any followers yet.</p>
                        </div>
                    <% } %>
                </div>
                
                <!-- Following Tab -->
                <div id="following" class="tab-pane fade">
                    <h3 class="mb-4"><i class="fas fa-user-friends me-2"></i>Following</h3>
                    
                    <% if (followingList != null && !followingList.isEmpty()) { 
                        FollowDao followDaoForFollowing = new FollowDao(DBCon.getConnection());
                    %>
                        <% for (User followingUser : followingList) { 
                            boolean isFollowingUser = false;
                            if (loggedUser != null) {
                                isFollowingUser = followDaoForFollowing.isFollowing(loggedUser.getId(), followingUser.getId());
                            }
                        %>
                            <div class="user-card">
                                <% if (followingUser.getProfileImage() != null && !followingUser.getProfileImage().isEmpty()) { %>
                                    <img src="post-images/<%= followingUser.getProfileImage() %>" 
                                         class="user-avatar" 
                                         alt="<%= followingUser.getUsername() %>'s profile picture"
                                         onerror="this.onerror=null;this.parentNode.innerHTML='<div class=\"user-avatar-fallback\"><%= followingUser.getUsername().substring(0, 1).toUpperCase() %></div><div class=\"user-info\"><h5 class=\"username\"><a href=\"profile.jsp?userId=<%= followingUser.getId() %>\" class=\"text-decoration-none\"><%= followingUser.getUsername() %></a></h5></div>'">
                                <% } else { %>
                                    <div class="user-avatar-fallback">
                                        <%= followingUser.getUsername().substring(0, 1).toUpperCase() %>
                                    </div>
                                <% } %>
                                <div class="user-info">
                                    <h5 class="username">
                                        <a href="profile.jsp?userId=<%= followingUser.getId() %>" class="text-decoration-none">
                                            <%= followingUser.getUsername() %>
                                        </a>
                                    </h5>
                                </div>
                                
                                <div class="d-flex">
                                    <% if (loggedUser != null && loggedUser.getId() != followingUser.getId()) { %>
                                        <button class="btn <%= isFollowingUser ? "btn-secondary" : "btn-primary" %> btn-sm follow-tab-btn" 
                                                data-user-id="<%= followingUser.getId() %>">
                                            <%= isFollowingUser ? "Following" : "Follow" %>
                                        </button>
                                        
                                        <% if (isFollowingUser) { %>
                                            <a href="message.jsp?userId=<%= followingUser.getId() %>" class="btn btn-outline-primary btn-message-sm ms-2">
                                                <i class="fas fa-envelope"></i>
                                            </a>
                                        <% } %>
                                    <% } else if (loggedUser != null && loggedUser.getId() == followingUser.getId()) { %>
                                        <span class="badge bg-light text-dark">You</span>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="empty-state">
                            <i class="fas fa-user-plus"></i>
                            <h4>Not Following Anyone</h4>
                            <p><%= profileUser.getUsername() %> isn't following anyone yet.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } else { %>
            <div class="alert alert-danger mt-4">
                <div class="d-flex align-items-center">
                    <i class="fas fa-exclamation-circle me-3 fs-4"></i>
                    <div>
                        <h4 class="alert-heading mb-1">User Not Found</h4>
                        <p class="mb-0">The user you're looking for doesn't exist or may have been deleted.</p>
                    </div>
                </div>
                <hr>
                <div class="d-flex justify-content-end">
                    <a href="home.jsp" class="btn btn-outline-danger">Back to Home</a>
                </div>
            </div>
        <% } %>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/plyr/3.7.8/plyr.min.js"></script>
    <script>
    $(document).ready(function() {
        // Initialize video players
        const players = Plyr.setup('.post-video', {
            controls: ['play-large', 'play', 'progress', 'current-time', 'mute', 'volume', 'fullscreen'],
            ratio: '16:9'
        });
        
        // Follow button functionality
        $('#followButton').click(function() {
            const button = $(this);
            const spinner = button.find('.spinner');
            const userId = button.data('user-id');
            const isFollowing = button.text().trim() === 'Following';
            
            // Show loading spinner
            button.prop('disabled', true);
            spinner.show();
            
            $.ajax({
                url: '<%= request.getContextPath() %>/FollowServlet',
                type: 'POST',
                data: {
                    userId: userId,
                    action: isFollowing ? 'unfollow' : 'follow'
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (isFollowing) {
                            button.removeClass('btn-success following').addClass('btn-primary').text('Follow');
                            $('.btn-message').remove();
                        } else {
                            button.removeClass('btn-primary').addClass('btn-success following').text('Following');
                            // Add message button after follow button
                            button.after('<a href="message.jsp?userId=<%= profileUser.getId() %>" class="btn btn-outline-primary btn-message ms-2"><i class="fas fa-envelope me-1"></i> Message</a>');
                        }
                        
                        // Update followers count
                        if (response.followersCount !== undefined) {
                            $('.stat-count:eq(1)').text(response.followersCount);
                            $('.nav-link[href="#followers"]').text('Followers (' + response.followersCount + ')');
                        }
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('An error occurred: ' + error);
                },
                complete: function() {
                    button.prop('disabled', false);
                    spinner.hide();
                }
            });
        });
        
        // Follow button functionality in followers/following tabs
        $(document).on('click', '.follow-tab-btn', function() {
            const button = $(this);
            const userId = button.data('user-id');
            const isFollowing = button.text().trim() === 'Following';
            
            $.ajax({
                url: '<%= request.getContextPath() %>/FollowServlet',
                type: 'POST',
                data: {
                    userId: userId,
                    action: isFollowing ? 'unfollow' : 'follow'
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (isFollowing) {
                            button.removeClass('btn-secondary').addClass('btn-primary').text('Follow');
                            button.next('.btn-message-sm').remove();
                        } else {
                            button.removeClass('btn-primary').addClass('btn-secondary').text('Following');
                            // Add message button after follow button
                            button.after('<a href="message.jsp?userId=' + userId + '" class="btn btn-outline-primary btn-message-sm ms-2"><i class="fas fa-envelope"></i></a>');
                        }
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('An error occurred: ' + error);
                }
            });
        });
        
        // Like button functionality
        $(document).on('click', '.post-action:has(.fa-heart)', function() {
            const action = $(this);
            const postId = action.data('post-id');
            const isLiked = action.hasClass('liked');
            const likeCount = action.find('span');
            
            $.ajax({
                url: '<%= request.getContextPath() %>/LikeServlet',
                type: 'POST',
                data: {
                    postId: postId,
                    action: isLiked ? 'unlike' : 'like'
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (isLiked) {
                            action.removeClass('liked');
                            action.find('i').removeClass('fas').addClass('far');
                        } else {
                            action.addClass('liked');
                            action.find('i').removeClass('far').addClass('fas');
                        }
                        likeCount.text(response.likesCount);
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('An error occurred: ' + error);
                }
            });
        });
        
        // Tweet like functionality
        $(document).on('click', '.like-action', function() {
            const action = $(this);
            const tweetId = action.data('tweet-id');
            const isLiked = action.hasClass('liked');
            const likeCount = action.find('.like-count');
            
            $.ajax({
                url: '<%= request.getContextPath() %>/TweetLikeServlet',
                type: 'POST',
                data: {
                    tweetId: tweetId,
                    action: isLiked ? 'unlike' : 'like'
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        if (isLiked) {
                            action.removeClass('liked');
                            action.find('i').removeClass('fas').addClass('far');
                        } else {
                            action.addClass('liked');
                            action.find('i').removeClass('far').addClass('fas');
                        }
                        likeCount.text(response.likeCount);
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('An error occurred: ' + error);
                }
            });
        });

        // Tweet retweet functionality
        $(document).on('click', '.retweet-action', function() {
            const action = $(this);
            const tweetId = action.data('tweet-id');
            
            $.ajax({
                url: '<%= request.getContextPath() %>/RetweetServlet',
                type: 'POST',
                data: {
                    tweetId: tweetId
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        action.find('span').text(response.retweetCount);
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('An error occurred: ' + error);
                }
            });
        });
        
        // Clickable stats to switch tabs
        $('.stat-item').click(function() {
            $(this).addClass('active').siblings().removeClass('active');
        });
        
        // Handle avatar image errors
        $(document).on('error', 'img[onerror]', function() {
            const username = $(this).attr('alt').split("'")[0];
            const fallback = username.substring(0, 1).toUpperCase();
            $(this).replaceWith('<div class="avatar-fallback">' + fallback + '</div>');
        });
    });
    </script>
</body>
</html>