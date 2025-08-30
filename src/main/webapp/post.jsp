<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%@ page import="java.util.List" %>
<%@ page import="cn.tech.Dao.*" %>
<%@ page import="cn.tech.model.Post" %>
<%@ page import="cn.tech.model.User" %>
<%@ page import="cn.tech.model.Comment" %>

<%
    User loggedInUser = (User) session.getAttribute("user");
    int postId = Integer.parseInt(request.getParameter("postId"));
    PostDao postDAO = new PostDao();
    UserDao userDAO = new UserDao();
    PostDao likeDao = new PostDao();
    CommentDao commentDao = new CommentDao();

    Post post = postDAO.getPostById(postId);
    User postUser = userDAO.getUserById(post.getUserId());
    List<User> likedUsers = likeDao.getUsersWhoLikedPost(postId);
    List<Comment> comments = commentDao.getCommentsByPostId(postId);
    boolean hasLiked = loggedInUser != null && postDAO.hasUserLikedPost(loggedInUser.getId(), postId);
    
    // Check if post has media and determine if it's video or image
    boolean hasMedia = post.getImagePath() != null && !post.getImagePath().isEmpty();
    boolean isVideo = false;
    if (hasMedia) {
        String fileExt = post.getImagePath().substring(post.getImagePath().lastIndexOf(".") + 1).toLowerCase();
        isVideo = fileExt.matches("mp4|webm|ogg");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title><%= postUser.getUsername() %>'s Post - Social Media</title>
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
        }

        body {
            background-color: #f5f7fb;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .post-container {
            background: white;
            padding: 25px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 25px;
        }

        .post-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .post-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 15px;
            border: 3px solid var(--light-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #dee2e6;
            color: #495057;
            font-weight: bold;
            font-size: 24px;
        }

        .post-user-info h5 {
            margin-bottom: 5px;
            font-weight: 600;
        }

        .post-time {
            color: var(--gray-color);
            font-size: 0.9rem;
        }

        .post-content {
            margin-bottom: 20px;
            line-height: 1.6;
            font-size: 1.1rem;
        }

        .media-container {
            border-radius: var(--border-radius);
            max-height: 500px;
            width: 100%;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            background-color: #000;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
        }

        .post-image {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .post-video {
            width: 100%;
            max-height: 500px;
            outline: none;
        }

        .post-actions {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid var(--light-gray);
        }

        .post-action-btn {
            display: flex;
            align-items: center;
            gap: 5px;
            background: none;
            border: none;
            color: var(--gray-color);
            font-weight: 500;
            cursor: pointer;
            transition: color 0.2s;
        }

        .post-action-btn:hover {
            color: var(--primary-color);
        }

        .post-action-btn.active {
            color: var(--primary-color);
        }

        .section-container {
            margin-top: 30px;
        }

        .section-card {
            background: white;
            padding: 20px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            height: 100%;
            transition: transform 0.3s ease;
        }

        .section-card:hover {
            transform: translateY(-5px);
        }

        .section-title {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
            font-weight: 600;
            color: var(--dark-color);
            border-bottom: 1px solid var(--light-gray);
            padding-bottom: 10px;
        }

        .section-title i {
            font-size: 1.2rem;
            color: var(--primary-color);
        }

        .user-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .user-item {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid var(--light-gray);
        }

        .user-item:last-child {
            border-bottom: none;
        }

        .user-item-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 10px;
            border: 2px solid var(--light-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #dee2e6;
            color: #495057;
            font-weight: bold;
            font-size: 16px;
        }

        .comment-item {
            padding: 12px 0;
            border-bottom: 1px solid var(--light-gray);
        }

        .comment-item:last-child {
            border-bottom: none;
        }

        .comment-header {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }

        .comment-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 10px;
            border: 2px solid var(--light-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #dee2e6;
            color: #495057;
            font-weight: bold;
            font-size: 14px;
        }

        .comment-username {
            font-weight: 600;
            font-size: 0.95rem;
        }

        .comment-time {
            color: var(--gray-color);
            font-size: 0.8rem;
            margin-left: 10px;
        }

        .comment-content {
            font-size: 0.95rem;
            line-height: 1.5;
            margin-left: 45px;
        }

        .comment-form {
            margin-top: 20px;
        }

        .comment-textarea {
            border-radius: var(--border-radius);
            border: 1px solid var(--light-gray);
            resize: none;
            padding: 12px;
            width: 100%;
            min-height: 80px;
            margin-bottom: 10px;
        }

        .post-detail-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid var(--light-gray);
        }

        .post-detail-item:last-child {
            border-bottom: none;
        }

        .post-detail-label {
            font-weight: 500;
            color: var(--gray-color);
        }

        .post-detail-value {
            font-weight: 600;
        }

        .empty-state {
            text-align: center;
            padding: 20px;
            color: var(--gray-color);
        }

        .empty-state i {
            font-size: 2rem;
            color: var(--light-gray);
            margin-bottom: 10px;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .post-avatar {
                width: 50px;
                height: 50px;
                font-size: 20px;
            }
            
            .post-content {
                font-size: 1rem;
            }
            
            .media-container {
                max-height: 350px;
            }
            
            .section-card {
                margin-bottom: 20px;
            }
            
            .user-item-avatar {
                width: 35px;
                height: 35px;
                font-size: 14px;
            }
            
            .comment-avatar {
                width: 30px;
                height: 30px;
                font-size: 12px;
            }
        }
    </style>
</head>
<body>

<div class="container mt-4">
    <!-- Main Post Card -->
    <div class="post-container">
        <!-- Post Header -->
        <div class="post-header">
            <% if (postUser.getProfileImage() != null && !postUser.getProfileImage().isEmpty()) { %>
                <img src="post-images/<%= postUser.getProfileImage() %>" 
                     class="post-avatar" alt="<%= postUser.getUsername() %>">
            <% } else { %>
                <div class="post-avatar"><%= postUser.getUsername().substring(0, 1).toUpperCase() %></div>
            <% } %>
            <div class="post-user-info">
                <h5><a href="user.jsp?userId=<%= postUser.getId() %>" class="text-decoration-none"><%= postUser.getUsername() %></a></h5>
                <div class="post-time"><%= post.getCreatedAt() %></div>
            </div>
        </div>

        <!-- Post Content -->
        <div class="post-content">
            <%= post.getContent() %>
        </div>

        <!-- Post Media (Image or Video) -->
        <% if (hasMedia) { %>
            <div class="media-container">
                <% if (isVideo) { %>
                    <video class="post-video" controls>
                        <source src="post-images/<%= post.getImagePath() %>" type="video/<%= post.getImagePath().substring(post.getImagePath().lastIndexOf(".") + 1) %>">
                        Your browser does not support the video tag.
                    </video>
                <% } else { %>
                    <img src="post-images/<%= post.getImagePath() %>" class="post-image" alt="Post image">
                <% } %>
            </div>
        <% } %>

        <!-- Post Actions -->
        <div class="post-actions">
            <% if (loggedInUser != null) { %>
                <button class="post-action-btn <%= hasLiked ? "active" : "" %>" id="likeBtn" data-post-id="<%= postId %>">
                    <i class="fas fa-thumbs-up"></i>
                    <span id="likeCount"><%= post.getLikeCount() %></span>
                </button>
            <% } %>
            <button class="post-action-btn">
                <i class="fas fa-comment"></i>
                <span><%= comments.size() %></span>
            </button>
            <button class="post-action-btn">
                <i class="fas fa-share"></i>
                <span>Share</span>
            </button>
        </div>
    </div>

    <!-- Three Sections Below Post -->
    <div class="row section-container">
        <!-- Liked By Section -->
        <div class="col-md-4">
            <div class="section-card">
                <div class="section-title">
                    <i class="fas fa-thumbs-up"></i>
                    <span>Liked By</span>
                </div>
                
                <% if (!likedUsers.isEmpty()) { %>
                    <ul class="user-list">
                        <% for (User userb : likedUsers) { %>
                            <li class="user-item">
                                <% if (userb.getProfileImage() != null && !userb.getProfileImage().isEmpty()) { %>
                                    <img src="post-images/<%= userb.getProfileImage() %>" 
                                         class="user-item-avatar" alt="<%= userb.getUsername() %>">
                                <% } else { %>
                                    <div class="user-item-avatar"><%= userb.getUsername().substring(0, 1).toUpperCase() %></div>
                                <% } %>
                                <a href="user.jsp?userId=<%= userb.getId() %>" class="text-decoration-none"><%= userb.getUsername() %></a>
                            </li>
                        <% } %>
                    </ul>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-heart"></i>
                        <p>No likes yet</p>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Comments Section -->
        <div class="col-md-4">
            <div class="section-card">
                <div class="section-title">
                    <i class="fas fa-comments"></i>
                    <span>Comments</span>
                </div>
                
                <% if (!comments.isEmpty()) { %>
                    <div class="comment-list">
                        <% for (Comment comment : comments) { %>
                            <div class="comment-item">
                                <div class="comment-header">
                                    <% if (comment.getProfileImage() != null && !comment.getProfileImage().isEmpty()) { %>
                                        <img src="post-images/<%= comment.getProfileImage() %>" 
                                             class="comment-avatar" alt="<%= comment.getUsername() %>">
                                    <% } else { %>
                                        <div class="comment-avatar"><%= comment.getUsername().substring(0, 1).toUpperCase() %></div>
                                    <% } %>
<span class="comment-username"><a href="user.jsp?userId=<%= comment.getUserId() %>" class="text-decoration-none"><%= comment.getUsername() %></a></span>                                    <span class="comment-time"><%= comment.getCreatedAt() %></span>
                                </div>
                                <div class="comment-content">
                                    <%= comment.getContent() %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-comment-slash"></i>
                        <p>No comments yet</p>
                    </div>
                <% } %>
                
                <% if (loggedInUser != null) { %>
                    <div class="comment-form">
                        <textarea class="comment-textarea" id="commentText" placeholder="Write a comment..."></textarea>
                        <button class="btn btn-primary" id="postCommentBtn" data-post-id="<%= postId %>">Post Comment</button>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Post Details Section -->
        <div class="col-md-4">
            <div class="section-card">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i>
                    <span>Post Details</span>
                </div>
                
                <div class="post-details">
                    <div class="post-detail-item">
                        <span class="post-detail-label">Author:</span>
                        <span class="post-detail-value">
                            <a href="user.jsp?userId=<%= postUser.getId() %>"><%= postUser.getUsername() %></a>
                        </span>
                    </div>
                    <div class="post-detail-item">
                        <span class="post-detail-label">Posted on:</span>
                        <span class="post-detail-value"><%= post.getCreatedAt() %></span>
                    </div>
                    <div class="post-detail-item">
                        <span class="post-detail-label">Likes:</span>
                        <span class="post-detail-value"><%= post.getLikeCount() %></span>
                    </div>
                    <div class="post-detail-item">
                        <span class="post-detail-label">Comments:</span>
                        <span class="post-detail-value"><%= comments.size() %></span>
                    </div>
                    <% if (hasMedia) { %>
                    <div class="post-detail-item">
                        <span class="post-detail-label">Media type:</span>
                        <span class="post-detail-value"><%= isVideo ? "Video" : "Image" %></span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>

<script>
$(document).ready(function() {
    // Like/Unlike functionality
    $('#likeBtn').click(function() {
        const button = $(this);
        const postId = button.data('post-id');
        const isLiked = button.hasClass('active');
        
        // Show loading state
        const originalHTML = button.html();
        button.html('<i class="fas fa-spinner fa-spin"></i>');
        button.prop('disabled', true);
        
        $.post('LikeServlet', {
            postId: postId,
            action: isLiked ? 'unlike' : 'like'
        }, function(response) {
            if (response.success) {
                // Update button state
                button.toggleClass('active');
                
                // Update like count
                const likeCount = $('#likeCount');
                const currentCount = parseInt(likeCount.text());
                likeCount.text(isLiked ? currentCount - 1 : currentCount + 1);
                
                // Show feedback
                showToast(isLiked ? "Post unliked" : "Post liked");
            } else {
                showToast('Error: ' + (response.message || 'Failed to update like'));
            }
            
            // Restore button state
            button.html(originalHTML);
            button.prop('disabled', false);
        }, 'json').fail(function() {
            showToast('Network error - please try again');
            button.html(originalHTML);
            button.prop('disabled', false);
        });
    });

    // Post Comment
    $('#postCommentBtn').click(function() {
        const postId = $(this).data('post-id');
        const commentText = $('#commentText').val().trim();

        if (commentText === '') {
            showToast('Please enter a comment');
            return;
        }

        // Show loading state
        const originalHTML = $(this).html();
        $(this).html('<i class="fas fa-spinner fa-spin"></i> Posting...');
        $(this).prop('disabled', true);
        
        $.post('CommentServlet', {
            postId: postId,
            comment: commentText
        }, function(response) {
            if (response.trim() === 'Success') {
                showToast('Comment posted successfully');
                // Small delay before refresh to show toast
                setTimeout(() => location.reload(), 1000);
            } else {
                showToast('Error posting comment: ' + response);
                $('#postCommentBtn').html(originalHTML);
                $('#postCommentBtn').prop('disabled', false);
            }
        }).fail(function() {
            showToast('Network error - please try again');
            $('#postCommentBtn').html(originalHTML);
            $('#postCommentBtn').prop('disabled', false);
        });
    });

    // Submit comment on Enter key (but allow Shift+Enter for new lines)
    $('#commentText').keydown(function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            $('#postCommentBtn').click();
        }
    });
    
    // Toast notification function
    function showToast(message) {
        const toast = $('<div class="toast-notification">' + message + '</div>');
        toast.css({
            'position': 'fixed',
            'bottom': '20px',
            'left': '50%',
            'transform': 'translateX(-50%)',
            'background-color': '#333',
            'color': 'white',
            'padding': '12px 24px',
            'border-radius': '4px',
            'z-index': '1000',
            'opacity': '0',
            'transition': 'opacity 0.3s'
        });
        
        $('body').append(toast);
        toast.css('opacity', '1');
        
        setTimeout(function() {
            toast.css('opacity', '0');
            setTimeout(function() {
                toast.remove();
            }, 300);
        }, 3000);
    }
});
</script>

</body>
</html>