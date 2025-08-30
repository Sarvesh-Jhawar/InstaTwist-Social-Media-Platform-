<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="cn.tech.Dao.*" %>
<%@ page import="cn.tech.model.Post" %>
<%@ page import="cn.tech.model.User" %>
<%@ page import="cn.tech.model.Comment" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home - Connect Hub</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-light: #eef2ff;
            --secondary-color: #3f37c9;
            --accent-color: #4895ef;
            --success-color: #4cc9f0;
            --danger-color: #f72585;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --gray-color: #6c757d;
            --light-gray: #e9ecef;
            --border-radius: 12px;
            --border-radius-sm: 8px;
            --box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            --box-shadow-lg: 0 8px 30px rgba(0, 0, 0, 0.12);
            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        body {
            background-color: #f5f7fb;
            color: var(--dark-color);
            font-family: 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
        }

        /* Avatar Styles */
        .avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            font-weight: 600;
            color: white;
            font-size: 1.2rem;
            text-transform: uppercase;
            flex-shrink: 0;
            background: linear-gradient(135deg, #4361ee, #3f37c9);
        }

        .avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .avatar-sm {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }

        /* Post Card Styles */
        .post-card {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 24px;
            overflow: hidden;
            transition: var(--transition);
            background-color: white;
        }

        .post-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--box-shadow-lg);
        }

        .post-card .card-body {
            padding: 20px;
        }

        .post-card .card-footer {
            background-color: white;
            border-top: 1px solid var(--light-gray);
            padding: 12px 20px;
        }

        /* Media Container */
        .post-image-container {
            position: relative;
            width: 100%;
            margin-top: 16px;
            border-radius: var(--border-radius-sm);
            overflow: hidden;
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            max-height: 600px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .post-image {
            max-width: 100%;
            max-height: 100%;
            width: auto;
            height: auto;
            object-fit: contain;
            display: block;
            border-radius: var(--border-radius-sm);
        }

        .post-image-container video {
            width: 100%;
            max-height: 600px;
            object-fit: contain;
            background-color: #000;
        }

        /* User info section */
        .user-info {
            display: flex;
            align-items: center;
            margin-bottom: 16px;
        }

        .user-info-content {
            flex-grow: 1;
        }

        .user-info h5 {
            margin-bottom: 2px;
            font-weight: 600;
            font-size: 1rem;
        }

        .user-info small {
            color: var(--gray-color);
            font-size: 0.85rem;
            display: block;
        }

        /* Post content */
        .post-content {
            margin-bottom: 12px;
            line-height: 1.6;
            font-size: 0.95rem;
            color: #333;
        }

        .post-content a {
            color: inherit;
            text-decoration: none;
        }

        .post-content a:hover {
            text-decoration: underline;
        }

        /* Action buttons */
        .post-actions {
            display: flex;
            gap: 12px;
        }

        .post-actions .btn {
            border-radius: var(--border-radius-sm);
            padding: 6px 16px;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: var(--transition);
        }

        .btn-like {
            background-color: rgba(67, 97, 238, 0.08);
            color: var(--primary-color);
            border: none;
        }

        .btn-like:hover, .btn-like.active {
            background-color: var(--primary-color);
            color: white;
            transform: scale(1.05);
        }

        .btn-comment, .btn-share {
            background-color: rgba(108, 117, 125, 0.08);
            color: var(--gray-color);
            border: none;
        }

        .btn-comment:hover, .btn-share:hover {
            background-color: rgba(108, 117, 125, 0.15);
            transform: scale(1.05);
        }

        /* Comment section */
        .comment-section {
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px solid var(--light-gray);
            display: none;
        }

        .comment {
            margin-bottom: 12px;
            padding: 12px;
            background-color: rgba(233, 236, 239, 0.3);
            border-radius: var(--border-radius-sm);
            transition: var(--transition);
        }

        .comment:hover {
            background-color: rgba(233, 236, 239, 0.5);
        }

        .comment strong {
            color: var(--dark-color);
            font-weight: 600;
            font-size: 0.9rem;
        }

        .comment small {
            color: var(--gray-color);
            font-size: 0.75rem;
            margin-left: 8px;
        }

        .comment p {
            margin: 8px 0 0;
            font-size: 0.9rem;
            color: #444;
        }

        .comment-textarea {
            margin-top: 12px;
            border-radius: var(--border-radius-sm);
            border: 1px solid var(--light-gray);
            resize: none;
            font-size: 0.9rem;
            padding: 12px;
            transition: var(--transition);
        }

        .comment-textarea:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2);
            outline: none;
        }

        .post-comment-btn {
            margin-top: 8px;
            border-radius: var(--border-radius-sm);
            padding: 8px 16px;
            font-weight: 500;
            transition: var(--transition);
        }

        .post-comment-btn:hover {
            transform: translateY(-2px);
        }

        /* Sidebar styles */
        .sidebar {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            position: sticky;
            top: 20px;
            background-color: white;
            transition: var(--transition);
        }

        .sidebar:hover {
            box-shadow: var(--box-shadow-lg);
        }

        .sidebar .card-body {
            padding: 20px;
        }

        .sidebar h5 {
            font-weight: 600;
            margin-bottom: 16px;
            color: var(--dark-color);
            font-size: 1.1rem;
            position: relative;
            padding-bottom: 8px;
        }

        .sidebar h5::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 40px;
            height: 3px;
            background: linear-gradient(to right, var(--primary-color), var(--accent-color));
            border-radius: 3px;
        }

        .suggestions-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .suggestions-list li {
            padding: 12px 0;
            border-bottom: 1px solid var(--light-gray);
            transition: var(--transition);
        }

        .suggestions-list li:hover {
            background-color: rgba(67, 97, 238, 0.03);
        }

        .suggestions-list li:last-child {
            border-bottom: none;
        }

        .suggestion-user {
            display: flex;
            align-items: center;
        }

        .suggestion-user h6 {
            margin-bottom: 0;
            font-weight: 600;
            flex-grow: 1;
            font-size: 0.95rem;
        }

        .suggestion-user a {
            color: inherit;
            text-decoration: none;
        }

        .suggestion-user a:hover {
            color: var(--primary-color);
        }

        .follow-btn {
            border-radius: var(--border-radius-sm);
            padding: 6px 12px;
            font-size: 0.8rem;
            font-weight: 500;
            min-width: 80px;
            transition: var(--transition);
            border: none;
        }

        .follow-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        /* Create post section */
        .create-post {
            margin-bottom: 24px;
            transition: var(--transition);
        }

        .create-post:hover {
            transform: translateY(-2px);
            box-shadow: var(--box-shadow-lg);
        }

        .create-post textarea {
            border-radius: var(--border-radius-sm);
            border: 1px solid var(--light-gray);
            resize: none;
            margin-bottom: 12px;
            padding: 12px;
            font-size: 0.95rem;
            transition: var(--transition);
        }

        .create-post textarea:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2);
            outline: none;
        }

        .create-post .btn-primary {
            border-radius: var(--border-radius-sm);
            padding: 10px 16px;
            font-weight: 500;
            background-color: var(--primary-color);
            border: none;
            transition: var(--transition);
            font-size: 0.95rem;
        }

        .create-post .btn-primary:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2);
        }

        /* File input styling */
        .custom-file-upload {
            display: inline-block;
            padding: 10px 16px;
            cursor: pointer;
            background-color: rgba(67, 97, 238, 0.08);
            color: var(--primary-color);
            border-radius: var(--border-radius-sm);
            margin-bottom: 12px;
            font-weight: 500;
            transition: var(--transition);
            font-size: 0.9rem;
            border: none;
        }

        .custom-file-upload:hover {
            background-color: rgba(67, 97, 238, 0.15);
            transform: translateY(-2px);
        }

        .custom-file-upload i {
            margin-right: 6px;
        }

        #imageInput {
            display: none;
        }

        /* Preview image */
        .image-preview {
            margin-top: 12px;
            display: none;
            position: relative;
            width: 100%;
            border-radius: var(--border-radius-sm);
            overflow: hidden;
            background-color: #f8f9fa;
            max-height: 300px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .image-preview img, .image-preview video {
            max-width: 100%;
            max-height: 100%;
            width: auto;
            height: auto;
            object-fit: contain;
            display: block;
            margin: 0 auto;
        }

        /* Badge for new notifications */
        .badge-new {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: var(--danger-color);
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            font-size: 0.6rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .post-actions .btn {
                padding: 6px 12px;
                font-size: 0.8rem;
            }
            
            .sidebar {
                margin-top: 24px;
            }
            
            .post-image-container {
                max-height: 400px;
            }
            
            .avatar {
                width: 40px;
                height: 40px;
                font-size: 1rem;
            }
        }

        /* Share Modal Styles */
        .share-modal {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 90%;
            max-width: 500px;
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow-lg);
            padding: 24px;
            z-index: 1000;
            animation: modalFadeIn 0.3s ease-out;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: translate(-50%, -60%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }

        .share-modal h3 {
            margin-bottom: 20px;
            color: var(--dark-color);
            font-weight: 600;
            position: relative;
            padding-bottom: 8px;
        }

        .share-modal h3::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 40px;
            height: 3px;
            background: linear-gradient(to right, var(--primary-color), var(--accent-color));
            border-radius: 3px;
        }

        .share-user {
            display: flex;
            align-items: center;
            padding: 12px;
            margin-bottom: 10px;
            border-radius: var(--border-radius-sm);
            transition: var(--transition);
        }

        .share-user:hover {
            background-color: rgba(67, 97, 238, 0.05);
        }

        .share-user button {
            margin-left: auto;
            padding: 8px 16px;
            border-radius: var(--border-radius-sm);
            background-color: var(--primary-color);
            color: white;
            border: none;
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 500;
            transition: var(--transition);
        }

        .share-user button:hover:not(:disabled) {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
        }

        .share-user button:disabled {
            background-color: var(--gray-color);
            cursor: not-allowed;
        }

        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 999;
            backdrop-filter: blur(4px);
        }

        .loading-spinner {
            display: none;
            text-align: center;
            padding: 30px;
        }

        .loading-spinner i {
            color: var(--primary-color);
            margin-bottom: 15px;
        }

        .loading-spinner p {
            color: var(--gray-color);
            font-size: 0.9rem;
        }

        /* Toast notification */
        .toast {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background-color: var(--primary-color);
            color: white;
            padding: 12px 24px;
            border-radius: var(--border-radius-sm);
            box-shadow: var(--box-shadow-lg);
            z-index: 1100;
            opacity: 0;
            transition: opacity 0.3s ease;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .toast.show {
            opacity: 1;
        }

        .toast i {
            font-size: 1.1rem;
        }

        /* Floating action button */
        .fab {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--box-shadow-lg);
            cursor: pointer;
            z-index: 100;
            transition: var(--transition);
            border: none;
        }

        .fab:hover {
            background-color: var(--secondary-color);
            transform: translateY(-4px) scale(1.1);
        }

        .fab i {
            font-size: 1.5rem;
        }
        .is-invalid {
    border-color: var(--danger-color) !important;
    box-shadow: 0 0 0 3px rgba(247, 37, 133, 0.2) !important;
}

.is-invalid:focus {
    box-shadow: 0 0 0 3px rgba(247, 37, 133, 0.2) !important;
}

.error-text {
    color: var(--danger-color);
    font-size: 0.8rem;
    margin-top: -10px;
    margin-bottom: 10px;
    display: none;
}
/* EmojioneArea adjustments */
.emojionearea {
    border-radius: var(--border-radius-sm) !important;
    border: 1px solid var(--light-gray) !important;
}

.emojionearea.focused {
    border-color: var(--primary-color) !important;
    box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2) !important;
}

.emojionearea .emojionearea-editor {
    min-height: 40px !important;
    padding: 8px 12px !important;
    font-size: 0.95rem !important;
}

.emojionearea .emojionearea-button {
    background: transparent !important;
    opacity: 0.7;
    transition: var(--transition);
}

.emojionearea .emojionearea-button:hover {
    opacity: 1;
    transform: scale(1.1);
}

.emojionearea .emojionearea-picker {
    border-radius: var(--border-radius-sm) !important;
    box-shadow: var(--box-shadow) !important;
}

/* For comment textareas */
.comment-textarea.emojionearea {
    border: none !important;
    background-color: transparent !important;
}

.comment-textarea.emojionearea .emojionearea-editor {
    background-color: white !important;
    border-radius: var(--border-radius-sm) !important;
    border: 1px solid var(--light-gray) !important;
}

.comment-textarea.emojionearea.focused .emojionearea-editor {
    border-color: var(--primary-color) !important;
    box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2) !important;
}
    </style>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/emojionearea@3.4.2/dist/emojionearea.min.css">
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <!-- Main Content -->
            <div class="col-md-8">
                <% User loggedInUser = (User) session.getAttribute("user");
                   if (loggedInUser != null) { %>
                <div class="card post-card create-post">
                    <div class="card-body">
                        <form action="CreatePostServlet" method="POST" enctype="multipart/form-data" id="postForm">
    <div class="user-info">
        <% if (loggedInUser.getProfileImage() != null && !loggedInUser.getProfileImage().isEmpty()) { %>
            <div class="avatar">
                <img src="post-images/<%= loggedInUser.getProfileImage() %>" alt="<%= loggedInUser.getUsername() %>">
            </div>
        <% } else { %>
            <div class="avatar" style="background: linear-gradient(135deg, <%= getRandomColor() %>, <%= getRandomColor() %>);">
                <%= loggedInUser.getUsername().substring(0, 1).toUpperCase() %>
            </div>
        <% } %>
        <div class="user-info-content">
            <h5><%= loggedInUser.getUsername() %></h5>
            <small>What's on your mind?</small>
        </div>
    </div>

    <!-- Text input for post content -->
    <textarea class="form-control mb-2" name="content" rows="3" placeholder="Write something about your media..."></textarea>

    <!-- Media upload section -->
    <label for="imageInput" class="custom-file-upload mb-1">
        <i class="fas fa-photo-video"></i> Add Media (Required)
    </label>
    <div class="error-text" id="mediaError" style="display: none;">
        <i class="fas fa-exclamation-circle mr-1"></i> You must attach media (image or video) to post
    </div>
    <input type="file" id="imageInput" name="media" accept="image/*,video/mp4,video/webm,video/ogg" required>
    
    <div class="image-preview" id="imagePreview">
        <img id="previewImage" src="#" alt="Preview" style="display: none;">
        <video id="previewVideo" controls style="display: none;">
            Your browser does not support the video tag.
        </video>
    </div>
    
    <button type="submit" class="btn btn-primary btn-block mt-3">
        <i class="fas fa-paper-plane mr-2"></i> Post
    </button>
</form>
                    </div>
                </div>
                <% } %>

                <% PostDao postDAO = new PostDao(); 
                   UserDao userDAO = new UserDao(); 
                   FollowDao followDao = new FollowDao();

                   List<User> followingList = followDao.getFollowing(loggedInUser.getId());
                   List<Post> posts = postDAO.getAllPosts();
                   Collections.shuffle(posts);
                   for (Post post : posts) {
                       User postUser = userDAO.getUserById(post.getUserId());
                       boolean hasLiked = loggedInUser != null && postDAO.hasUserLikedPost(loggedInUser.getId(), post.getId()); %>
                <div class="card post-card">
                    <div class="card-body">
                        <div class="user-info">
                            <% if (postUser.getProfileImage() != null && !postUser.getProfileImage().isEmpty()) { %>
                                <div class="avatar">
                                    <img src="post-images/<%= postUser.getProfileImage() %>" alt="<%= postUser.getUsername() %>">
                                </div>
                            <% } else { %>
                                <div class="avatar" style="background: linear-gradient(135deg, <%= getRandomColor() %>, <%= getRandomColor() %>);">
                                    <%= postUser.getUsername().substring(0, 1).toUpperCase() %>
                                </div>
                            <% } %>
                            <div class="user-info-content">
                                <h5><a href="user.jsp?userId=<%= postUser.getId() %>" class="text-decoration-none"><%= postUser.getUsername() %></a></h5>
                                <small><%= post.getCreatedAt() %></small>
                            </div>
                        </div>
                        
                        <div class="post-content">
                            <a href="post.jsp?postId=<%= post.getId() %>" class="text-decoration-none text-dark">
                                <p><%= post.getContent() %></p>
                                <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { 
                                    String fileExtension = post.getImagePath().substring(post.getImagePath().lastIndexOf(".") + 1).toLowerCase();
                                    boolean isVideo = fileExtension.matches("mp4|webm|ogg"); %>
                                    <div class="post-image-container">
                                        <% if (isVideo) { %>
                                            <video controls class="post-image">
                                                <source src="post-images/<%= post.getImagePath() %>" type="video/<%= fileExtension %>">
                                                Your browser does not support the video tag.
                                            </video>
                                        <% } else { %>
                                            <img src="post-images/<%= post.getImagePath() %>" class="post-image" alt="Post image">
                                        <% } %>
                                    </div>
                                <% } %>
                            </a>
                        </div>
                    </div>
                    <!-- In your post card footer section, replace the comment section with this: -->
 <!-- Updated card footer with working comment section -->
                    <div class="card-footer">
                        <div class="post-actions">
                            <% if (loggedInUser != null) { %>
                                <button class="btn btn-like <%= hasLiked ? "active" : "" %>" data-post-id="<%= post.getId() %>">
                                    <i class="fas fa-thumbs-up"></i> 
                                    <span class="like-count"><%= post.getLikeCount() %></span>
                                </button>
                            <% } %>
                            <button class="btn btn-comment" onclick="toggleCommentSection(this)">
                                <i class="fas fa-comment"></i> <span class="d-none d-md-inline">Comment</span>
                            </button>
                            <button class="btn btn-share" onclick="openShareModal(<%= post.getId() %>)">
    <i class="fas fa-share"></i> Share
</button>

                        </div>
                        
                        <!-- Comment section -->
                        <div class="comment-section" style="display: none;">
                            <% CommentDao commentDao = new CommentDao();
                               List<Comment> comments = commentDao.getCommentsByPostId(post.getId());
                               for (Comment comment : comments) { %>
                                <div class="comment">
                                    <strong><%= comment.getUsername() %></strong>
                                    <small><%= comment.getCreatedAt() %></small>
                                    <p><%= comment.getContent() %></p>
                                </div>
                            <% } %>

                            <% if (loggedInUser != null) { %>
                                <div class="comment-input-group mt-3">
                                    <textarea class="form-control comment-textarea" placeholder="Write a comment..."></textarea>
                                    <button class="btn btn-primary post-comment-btn mt-2" data-post-id="<%= post.getId() %>">
                                        <i class="fas fa-paper-plane mr-2"></i> Post Comment
                                    </button>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
                
            <!-- Sidebar -->
            <div class="col-md-4">
                <div class="card sidebar">
                    <div class="card-body">
                        <h5>Suggestions For You</h5>
                        <ul class="suggestions-list">
                            <% 
                            List<User> suggestedUsers = userDAO.getSuggestedUsers(loggedInUser != null ? loggedInUser.getId() : 0);
                            Collections.shuffle(suggestedUsers);
                            for (User u : suggestedUsers) { 
                                boolean isFollowing = loggedInUser != null && userDAO.isFollowing(loggedInUser.getId(), u.getId());
                            %>
                            <li>
                                <div class="suggestion-user">
                                    <% if (u.getProfileImage() != null && !u.getProfileImage().isEmpty()) { %>
                                        <div class="avatar avatar-sm">
                                            <img src="post-images/<%= u.getProfileImage() %>" alt="<%= u.getUsername() %>">
                                        </div>
                                    <% } else { %>
                                        <div class="avatar avatar-sm" style="background: linear-gradient(135deg, <%= getRandomColor() %>, <%= getRandomColor() %>);">
                                            <%= u.getUsername().substring(0, 1).toUpperCase() %>
                                        </div>
                                    <% } %>
                                    <h6><a href="user.jsp?userId=<%= u.getId() %>"><%= u.getUsername() %></a></h6>
                                    <% if (loggedInUser != null) { %>
                                    <button class="btn <%= isFollowing ? "btn-secondary" : "btn-primary" %> follow-btn" 
                                            data-user-id="<%= u.getId() %>">
                                        <%= isFollowing ? "Following" : "Follow" %>
                                    </button>
                                    <% } %>
                                </div>
                            </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>


<div class="modal fade" id="shareModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-scrollable">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">Share Post</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <div class="mb-3">
          <textarea id="shareMessage" class="form-control" placeholder="Add a message before sharing..."></textarea>
        </div>
        <% for(User kuser : followingList) { %>
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span><%= kuser.getUsername() %></span>
            <button
              class="btn btn-primary btn-sm"
              onclick="sendShare(<%= kuser.getId() %>, this)">
              Send
            </button>
          </div>
        <% } %>
      </div>

    </div>
  </div>
</div>




    <!-- Toast Notification -->
    <div id="toast" class="toast">
        <i class="fas fa-check-circle"></i>
        <span id="toastMessage"></span>
    </div>

    <!-- Floating Action Button -->
    <% if (loggedInUser != null) { %>
    <button class="fab" onclick="document.getElementById('postForm').scrollIntoView({ behavior: 'smooth' })">
        <i class="fas fa-plus"></i>
    </button>
    <% } %>

    <%@ include file="includes/footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/emojionearea@3.4.2/dist/emojionearea.min.js"></script>
    <script>
    // Global variables for sharing functionality
    let sharePostId = 0;
    let shareTweetId = 0;

    // Function to open share modal
    function openShareModal(postId = 0, tweetId = 0) {
        sharePostId = postId;
        shareTweetId = tweetId;
        document.getElementById("shareMessage").value = "";
        const modal = new bootstrap.Modal(document.getElementById("shareModal"));
        modal.show();
    }

    // Function to send share
    function sendShare(receiverId, buttonElement) {
        buttonElement.disabled = true;

        const customContent = document.getElementById("shareMessage").value.trim();
        const messageContent = customContent !== "" ? customContent : "Shared a post";

        const formData = new URLSearchParams();
        formData.append("receiverId", receiverId);
        formData.append("content", messageContent);
        formData.append("postId", sharePostId);
        formData.append("tweetId", shareTweetId);

        fetch("message", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: formData.toString()
        })
        .then(response => {
            if (response.ok) {
                buttonElement.textContent = "Sent";
                buttonElement.classList.remove("btn-primary");
                buttonElement.classList.add("btn-success");
            } else {
                buttonElement.textContent = "Error";
                buttonElement.classList.remove("btn-primary");
                buttonElement.classList.add("btn-danger");
            }
        })
        .catch(() => {
            buttonElement.textContent = "Error";
            buttonElement.classList.remove("btn-primary");
            buttonElement.classList.add("btn-danger");
        })
        .finally(() => {
            buttonElement.disabled = false;
        });
    }

    // Function to toggle comment section
    function toggleCommentSection(button) {
        const cardFooter = $(button).closest('.card-footer');
        const commentSection = cardFooter.find('.comment-section');
        
        if (commentSection.is(':visible')) {
            commentSection.slideUp();
        } else {
            commentSection.slideDown();
            // Initialize emoji picker if not already done
            const textarea = commentSection.find('.comment-textarea');
            if (!textarea.data('emojioneArea')) {
                textarea.emojioneArea({
                    pickerPosition: "top",
                    tonesStyle: "bullet",
                    search: false,
                    standalone: false
                });
            }
            // Focus the textarea when shown
            commentSection.find('.emojionearea-editor').focus();
        }
    }

    // Function to show toast notification
    function showToast(message) {
        const toast = document.getElementById('toast');
        const toastMessage = document.getElementById('toastMessage');
        
        toastMessage.textContent = message;
        toast.classList.add('show');
        
        // Hide after 3 seconds
        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    $(document).ready(function() {
        // Initialize emoji picker for post creation
        $("textarea[name='content']").emojioneArea({
            pickerPosition: "top",
            tonesStyle: "bullet",
            search: false,
            standalone: false,
            events: {
                emojibtn_click: function(button, event) {
                    // Handle emoji selection if needed
                }
            }
        });

        // Media (image/video) preview for post creation
        $('#imageInput').change(function() {
            const file = this.files[0];
            const previewContainer = $('#imagePreview');
            const previewImage = $('#previewImage');
            const previewVideo = $('#previewVideo');
            
            if (file) {
                const fileType = file.type;
                const reader = new FileReader();

                if (fileType.startsWith('image/')) {
                    previewVideo.hide();
                    previewVideo.find('source').attr('src', '');
                    previewVideo[0].pause();
                    
                    reader.onload = function(e) {
                        previewImage.attr('src', e.target.result);
                        previewImage.show();
                        previewContainer.show();
                    };
                    reader.readAsDataURL(file);
                } else if (fileType.startsWith('video/')) {
                    previewImage.hide();
                    
                    reader.onload = function(e) {
                        previewVideo.find('source').attr('src', e.target.result);
                        previewVideo.find('source').attr('type', fileType);
                        previewVideo[0].load();
                        previewVideo.show();
                        previewContainer.show();
                    };
                    reader.readAsDataURL(file);
                } else {
                    previewContainer.hide();
                    showToast("Unsupported file format!");
                }
            } else {
                previewContainer.hide();
            }
        });

        // Like a post
        $(document).on("click", ".btn-like", function() {
            const button = $(this);
            const postId = button.data("post-id");
            
            // Add loading state
            const likeIcon = button.find('i');
            const originalIcon = likeIcon.attr('class');
            likeIcon.attr('class', 'fas fa-spinner fa-spin');
            
            $.post("LikeServlet", { postId: postId }, function(response) {
                // Restore original icon
                likeIcon.attr('class', originalIcon);
                
                if ($.isNumeric(response)) {
                    const likeCount = button.find(".like-count");
                    const isActive = button.hasClass("active");

                    if (isActive) {
                        button.removeClass("active");
                        likeCount.text(parseInt(likeCount.text()) - 1);
                        showToast("Post unliked");
                    } else {
                        button.addClass("active");
                        likeCount.text(parseInt(likeCount.text()) + 1);
                        showToast("Post liked");
                    }
                } else {
                    showToast("Error updating like!");
                }
            });
        });

        // Follow/unfollow user
        $(document).on("click", ".follow-btn", function() {
            const button = $(this);
            const userId = button.data("user-id");
            const isFollowing = button.text().trim() === "Following";

            // Add loading state
            const originalText = button.html();
            button.html('<i class="fas fa-spinner fa-spin"></i>');
            button.prop('disabled', true);
            
            $.post("FollowServlet", { 
                userId: userId, 
                action: isFollowing ? "unfollow" : "follow" 
            }, function(response) {
                if (response.success) {
                    if (isFollowing) {
                        button.html('Follow').removeClass("btn-secondary").addClass("btn-primary");
                        showToast("User unfollowed");
                    } else {
                        button.html('Following').removeClass("btn-primary").addClass("btn-secondary");
                        showToast("User followed");
                    }
                } else {
                    showToast(response.message || "Error updating follow status!");
                    button.html(originalText);
                }
                button.prop('disabled', false);
            }, "json");
        });

        // Post a comment
      // Post a comment
$(document).on("click", ".post-comment-btn", function(e) {
    e.preventDefault();
    const button = $(this);
    const postId = button.data("post-id");
    const commentSection = button.closest(".comment-section");
    const commentGroup = button.closest(".comment-input-group");
    const emojioneArea = commentGroup.find(".comment-textarea").data("emojioneArea");
    const commentText = emojioneArea ? emojioneArea.getText() : commentGroup.find(".comment-textarea").val().trim();

    if (commentText === "") {
        showToast("Comment cannot be empty!");
        return;
    }

    // Add loading state
    const originalText = button.html();
    button.html('<i class="fas fa-spinner fa-spin mr-2"></i> Posting...');
    button.prop('disabled', true);

    $.post("CommentServlet", {
        postId: postId,
        comment: commentText
    }, function(response) {
        if (response.trim() !== "Error") {
            const parts = response.split("|");
            if (parts.length >= 3) {
                const username = parts[0];
                const createdAt = parts[1];
                const content = parts[2];

                // Create new comment element
                const newComment = $('<div class="comment">')
                    .append($('<strong>').text(username))
                    .append($('<small class="text-muted ml-2">').text(createdAt))
                    .append($('<p>').text(content));

                // Insert the new comment at the top of the comments list
                const commentsContainer = commentSection.find('.comment').length > 0 ? 
                    commentSection.find('.comment').first().parent() : 
                    commentSection;

                commentsContainer.prepend(newComment);

                // Clear the textarea
                if (emojioneArea) {
                    emojioneArea.setText("");
                } else {
                    commentGroup.find(".comment-textarea").val("");
                }
                
                showToast("Comment posted!");
            } else {
                showToast("Invalid response format!");
            }
        } else {
            showToast("Error posting comment!");
        }
        
        // Restore button state
        button.html(originalText);
        button.prop('disabled', false);
    }).fail(function() {
        showToast("Network error!");
        button.html(originalText);
        button.prop('disabled', false);
    });
});

        // Handle post form submission
        $('#postForm').on('submit', function(event) {
            event.preventDefault();
            
            // Get content from emojionearea instance
            const emojioneArea = $("textarea[name='content']").data("emojioneArea");
            const content = emojioneArea ? emojioneArea.getText() : $("textarea[name='content']").val().trim();
            const fileInput = $('#imageInput')[0];
            const formData = new FormData(this);
            
            // Manually append the content since we're getting it differently
            formData.set('content', content);
            
            if (!fileInput.files[0]) {
                showToast("Media is required for posting!");
                $('.custom-file-upload').css({
                    'border': '1px solid #f72585',
                    'background-color': 'rgba(247, 37, 133, 0.1)'
                });
                $('#mediaError').show();
                return;
            }
            
            // Remove any previous error highlights
            $('.custom-file-upload').css({
                'border': 'none',
                'background-color': 'rgba(67, 97, 238, 0.08)'
            });
            $('#mediaError').hide();
            
            const submitBtn = $('button[type="submit"]');
            submitBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i> Posting...');
            submitBtn.prop('disabled', true);
            
            $.ajax({
                url: $(this).attr('action'),
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(htmlResponse) {
                    // Insert the new post after the create-post form but before other posts
                    $('.create-post').after(htmlResponse);
                    
                    // Reset the form
                    $('#postForm')[0].reset();
                    $('#imagePreview').hide();
                    if (emojioneArea) {
                        emojioneArea.setText("");
                    } else {
                        $('textarea[name="content"]').val('');
                    }
                    
                    showToast("Post created successfully!");
                },
                error: function(xhr) {
                    showToast("Error: " + (xhr.responseText || 'Failed to create post'));
                },
                complete: function() {
                    submitBtn.html('<i class="fas fa-paper-plane mr-2"></i> Post');
                    submitBtn.prop('disabled', false);
                }
            });
        });
    });
</script>
</body>
</html>

<%!
    // Helper method to generate random colors for avatars
    private String getRandomColor() {
        String[] colors = {
            "#4361ee", "#3f37c9", "#4895ef", "#4cc9f0", 
            "#3a0ca3", "#7209b7", "#b5179e", "#f72585",
            "#560bad", "#480ca8", "#3a0ca3", "#3f37c9"
        };
        return colors[(int) (Math.random() * colors.length)];
    }
%>