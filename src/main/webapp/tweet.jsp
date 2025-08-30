<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/head.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.tech.Dao.TweetDao" %>
<%@ page import="cn.tech.Dao.FollowDao" %>
<%@ page import="cn.tech.Dao.TweetCommentDao" %>
<%@ page import="cn.tech.Dao.TweetLikeDao" %>
<%@ page import="cn.tech.Dao.UserDao" %>
<%@ page import="cn.tech.model.Tweet" %>
<%@ page import="cn.tech.model.TweetComment" %>
<%@ page import="cn.tech.model.User" %>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String tweetIdParam = request.getParameter("tweetId");
    if (tweetIdParam == null || tweetIdParam.isEmpty()) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    int tweetId = Integer.parseInt(tweetIdParam);
    TweetDao tweetDao = new TweetDao();
    TweetCommentDao tweetCommentDao = new TweetCommentDao();
    TweetLikeDao tweetLikeDao = new TweetLikeDao();
    UserDao userDao = new UserDao();
    FollowDao followDao = new FollowDao();
    
    Tweet tweet = tweetDao.getTweetById(tweetId);
    if (tweet == null) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    User tweetUser = userDao.getUserById(tweet.getUserId());
    if (tweetUser == null) {
        response.sendRedirect("home.jsp");
        return;
    }
    
    List<User> likedByUsers = tweetLikeDao.getUsersWhoLikedTweet(tweet.getTweetId());
    List<User> retweetedByUsers = tweetDao.getUsersWhoRetweetedTweet(tweet.getTweetId());
    int likeCount = tweetLikeDao.getLikesCount(tweet.getTweetId());
    int retweetCount = tweetDao.getRetweetCount(tweet.getTweetId());
    boolean isLiked = tweetLikeDao.isLiked(tweet.getTweetId(), currentUser.getId());
    boolean isRetweeted = tweetDao.isRetweeted(tweet.getTweetId(), currentUser.getId());
    List<TweetComment> comments = tweetCommentDao.getCommentsForTweet(tweet.getTweetId());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Twittar - Tweet</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #1DA1F2;
            --secondary-color: #E1E8ED;
            --dark-color: #14171A;
            --light-color: #F5F8FA;
            --border-color: #E1E8ED;
            --success-color: #17BF63;
            --danger-color: #E0245E;
        }
        
        body {
            background-color: #f8f9fa;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        
        .main-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .tweet-card {
            background-color: white;
            border: 1px solid #e1e8ed;
            border-radius: 12px;
            margin-bottom: 20px;
            padding: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }
        
        .tweet-header {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
        }
        
        .user-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            font-weight: bold;
            font-size: 18px;
        }
        
        .tweet-user {
            font-weight: 700;
            color: var(--dark-color);
            margin-right: 5px;
        }
        
        .tweet-username {
            color: #657786;
            margin-right: 5px;
        }
        
        .tweet-time {
            color: #657786;
            font-size: 0.9em;
        }
        
        .tweet-content {
            white-space: pre-wrap;
            word-wrap: break-word;
            font-size: 15px;
            line-height: 1.5;
            margin-bottom: 16px;
        }
        
        .tweet-actions {
            display: flex;
            justify-content: space-around;
            margin: 16px 0;
            padding: 8px 0;
            border-top: 1px solid #e1e8ed;
            border-bottom: 1px solid #e1e8ed;
        }
        
        .tweet-action {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: #657786;
            font-size: 14px;
            cursor: pointer;
            padding: 8px;
            border-radius: 4px;
            transition: all 0.2s;
            background: none;
            border: none;
            width: 100%;
        }
        
        .tweet-action:hover {
            background-color: rgba(29, 161, 242, 0.1);
        }
        
        .tweet-action i {
            font-size: 20px;
            margin-bottom: 4px;
        }
        
        .liked {
            color: var(--danger-color);
        }
        
        .retweeted {
            color: var(--success-color);
        }
        
        .action-count {
            font-size: 12px;
            font-weight: 500;
        }
        
        .engagement-section {
            display: flex;
            margin: 16px 0;
        }
        
        .engagement-column {
            flex: 1;
            padding: 0 10px;
        }
        
        .engagement-column:first-child {
            border-right: 1px solid #e1e8ed;
        }
        
        .engagement-title {
            font-size: 14px;
            font-weight: 600;
            color: #657786;
            margin-bottom: 8px;
        }
        
        .engagement-list {
            max-height: 150px;
            overflow-y: auto;
        }
        
        .engagement-user {
            display: flex;
            align-items: center;
            padding: 6px 0;
            border-bottom: 1px solid #f0f4f7;
        }
        
        .engagement-user:last-child {
            border-bottom: none;
        }
        
        .engagement-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 8px;
            font-weight: bold;
            font-size: 14px;
        }
        
        .engagement-username {
            font-size: 14px;
            font-weight: 500;
        }
        
        .comment-section {
            margin-top: 16px;
        }
        
        .comment {
            display: flex;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f4f7;
        }
        
        .comment:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .comment-content {
            flex-grow: 1;
        }
        
        .comment-user {
            font-weight: 600;
            margin-right: 5px;
            font-size: 14px;
        }
        
        .comment-text {
            margin-top: 4px;
            font-size: 14px;
        }
        
        .comment-time {
            color: #657786;
            font-size: 12px;
        }
        
        .comment-input-group {
            display: flex;
            margin-top: 16px;
        }
        
        .comment-input {
            border-radius: 20px;
            padding: 8px 16px;
            flex-grow: 1;
            border: 1px solid #e1e8ed;
            font-size: 14px;
        }
        
        .post-comment-btn {
            margin-left: 8px;
            border-radius: 20px;
            padding: 8px 16px;
            font-size: 14px;
            background-color: var(--primary-color);
            color: white;
            border: none;
        }
        
        .back-link {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link i {
            margin-right: 8px;
        }
        
        .empty-message {
            color: #657786;
            font-size: 14px;
            font-style: italic;
        }
    </style>
</head>
<body>

<div class="main-container">
    <!-- Back button -->
    <a href="home.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Home
    </a>
    
    <!-- Main Tweet -->
    <div class="tweet-card" id="tweet-<%= tweet.getTweetId() %>">
        <div class="tweet-header">
            <div class="user-avatar">
                <%= tweetUser.getUsername().substring(0, 1).toUpperCase() %>
            </div>
            <div class="flex-grow-1">
                <div class="d-flex align-items-center">
                    <span class="tweet-user"><%= tweetUser.getUsername() %></span>
                    <span class="tweet-username">@<%= tweetUser.getUsername().toLowerCase() %></span>
                    <span class="tweet-time">· <%= tweet.getCreatedAt() != null ? tweet.getCreatedAt().toString() : "" %></span>
                </div>
            </div>
        </div>
        
        <div class="tweet-content"><%= tweet.getContent() %></div>

        <!-- Tweet Actions -->
        <div class="tweet-actions">
            <button class="tweet-action like-btn <%= isLiked ? "liked" : "" %>" 
                    data-tweet-id="<%= tweet.getTweetId() %>" 
                    data-user-id="<%= currentUser.getId() %>" 
                    data-is-liked="<%= isLiked %>">
                <i class="<%= isLiked ? "fas" : "far" %> fa-heart"></i>
                <span class="action-count"><%= likeCount %></span>
            </button>
            
            <button class="tweet-action retweet-btn <%= isRetweeted ? "retweeted" : "" %>" 
                    data-tweet-id="<%= tweet.getTweetId() %>" 
                    data-user-id="<%= currentUser.getId() %>" 
                    data-is-retweeted="<%= isRetweeted %>">
                <i class="fas fa-retweet"></i>
                <span class="action-count"><%= retweetCount %></span>
            </button>
            
            <button class="tweet-action comment-btn" onclick="toggleCommentSection(this, <%= tweet.getTweetId() %>)">
                <i class="far fa-comment"></i>
                <span class="action-count" id="commentCount<%= tweet.getTweetId() %>">
                    <%= tweetCommentDao.getCommentsCount(tweet.getTweetId()) %>
                </span>
            </button>
            
            <button class="tweet-action" onclick="openShareModal(<%= tweet.getTweetId() %>)">
                <i class="fas fa-share"></i>
            </button>
        </div>

        <!-- Engagement Section -->
        <div class="engagement-section">
            <div class="engagement-column">
                <div class="engagement-title">Liked by (<%= likeCount %>)</div>
                <div class="engagement-list">
                    <% if (likedByUsers.isEmpty()) { %>
                        <div class="empty-message">No likes yet</div>
                    <% } else { 
                        for (User kuser : likedByUsers) { %>
                            <div class="engagement-user">
                                <div class="engagement-avatar">
                                    <%= kuser.getUsername().substring(0, 1).toUpperCase() %>
                                </div>
                                <div class="engagement-username">
                                    <%= kuser.getUsername() %>
                                </div>
                            </div>
                        <% } 
                    } %>
                </div>
            </div>
            
            <div class="engagement-column">
                <div class="engagement-title">Retweeted by (<%= retweetCount %>)</div>
                <div class="engagement-list">
                    <% if (retweetedByUsers.isEmpty()) { %>
                        <div class="empty-message">No retweets yet</div>
                    <% } else { 
                        for (User kuser : retweetedByUsers) { %>
                            <div class="engagement-user">
                                <div class="engagement-avatar">
                                    <%= kuser.getUsername().substring(0, 1).toUpperCase() %>
                                </div>
                                <div class="engagement-username">
                                    <%= kuser.getUsername() %>
                                </div>
                            </div>
                        <% } 
                    } %>
                </div>
            </div>
        </div>

        <!-- Comment Section -->
        <div class="comment-section" id="commentSection<%= tweet.getTweetId() %>" style="display: none;">
            <div id="commentsList<%= tweet.getTweetId() %>">
                <% if (comments.isEmpty()) { %>
                    <div class="empty-message">No comments yet. Be the first to comment!</div>
                <% } else { 
                    for (TweetComment comment : comments) { 
                        User commenter = userDao.getUserById(comment.getUserId());
                        if (commenter == null) continue;
                %>
                    <div class="comment">
                        <div class="user-avatar">
                            <%= commenter.getUsername().substring(0, 1).toUpperCase() %>
                        </div>
                        <div class="comment-content">
                            <div>
                                <span class="comment-user"><%= commenter.getUsername() %></span>
                                <span class="comment-time"><%= comment.getCommentedAt() %></span>
                            </div>
                            <div class="comment-text"><%= comment.getComment() %></div>
                        </div>
                    </div>
                <% } 
                   } %>
            </div>
            
            <!-- Comment Form -->
            <div class="comment-input-group">
                <input type="text" class="form-control comment-input" 
                       placeholder="Add a comment..." 
                       id="commentInput<%= tweet.getTweetId() %>">
                <button class="btn btn-primary post-comment-btn" data-tweet-id="<%= tweet.getTweetId() %>">
                    Post
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Share Tweet Modal -->
<div class="modal fade" id="shareModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Share Tweet</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <textarea id="shareMessage" class="form-control" placeholder="Add a message before sharing..."></textarea>
        </div>
        <% 
            List<User> followingList = followDao.getFollowing(currentUser.getId());
            for (User kuser : followingList) { 
        %>
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span><%= kuser.getUsername() %></span>
            <button class="btn btn-primary btn-sm" onclick="sendShare(<%= kuser.getId() %>, this)">
              Send
            </button>
          </div>
        <% } %>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
let shareTweetId = 0;

function openShareModal(tweetId) {
    shareTweetId = tweetId;
    document.getElementById("shareMessage").value = "";
    const modal = new bootstrap.Modal(document.getElementById("shareModal"));
    modal.show();
}

function sendShare(receiverId, buttonElement) {
    buttonElement.disabled = true;

    const customContent = document.getElementById("shareMessage").value.trim();
    const messageContent = customContent !== "" ? customContent : "Shared a tweet";

    const formData = new URLSearchParams();
    formData.append("receiverId", receiverId);
    formData.append("content", messageContent);
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

function toggleCommentSection(button, tweetId) {
    const cardBody = $(button).closest('.tweet-card');
    const commentSection = cardBody.find('#commentSection' + tweetId);
    
    if (commentSection.is(':visible')) {
        commentSection.slideUp();
    } else {
        commentSection.slideDown();
        commentSection.find('.comment-input').focus();
    }
}

$(document).on("click", ".post-comment-btn", function(e) {
    e.preventDefault();
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const commentInput = button.closest(".comment-input-group").find(".comment-input");
    const commentText = commentInput.val().trim();
    const commentSection = $("#commentSection" + tweetId);
    const commentsContainer = $("#commentsList" + tweetId);

    if (!commentText) {
        alert("Comment cannot be empty!");
        return;
    }

    const originalText = button.html();
    button.html('<i class="fas fa-spinner fa-spin"></i>').prop('disabled', true);

    $.post("commentTweet", {
        tweetId: tweetId,
        userId: <%= currentUser.getId() %>,
        commentText: commentText
    }).done(function(response) {
        if (response.startsWith("success")) {
            const parts = response.split("|");
            
            if (parts.length >= 4) {
                const username = parts[1];
                const createdAt = parts[2];
                const content = parts[3];

                const newComment = $('<div class="comment">')
                    .append($('<div class="user-avatar">').text(username.substring(0, 1).toUpperCase()))
                    .append($('<div class="comment-content">')
                        .append($('<div>')
                            .append($('<span class="comment-user">').text(username))
                            .append($('<span class="comment-time">').text(createdAt))
                        )
                        .append($('<div class="comment-text">').text(content))
                    );

                if (commentsContainer.find(".empty-message").length > 0) {
                    commentsContainer.html(newComment);
                } else {
                    commentsContainer.prepend(newComment);
                }

                $('#commentCount' + tweetId).text(commentsContainer.find('.comment').length);
                commentInput.val('');
            }
        }
    }).fail(function(xhr) {
        console.error("Error:", xhr.responseText);
        alert("Failed to post comment");
    }).always(function() {
        button.html(originalText).prop('disabled', false);
    });
});

$(document).on("click", ".like-btn", function() {
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const userId = button.data("user-id");
    const isLiked = button.data("is-liked") === true || button.data("is-liked") === "true";
    const action = isLiked ? "unlike" : "like";

    button.toggleClass("liked");
    const heartIcon = button.find("i");
    heartIcon.toggleClass("far fas");

    const likeCountElement = button.find(".action-count");
    let likeCount = parseInt(likeCountElement.text());
    likeCount = isLiked ? likeCount - 1 : likeCount + 1;
    likeCountElement.text(likeCount);
    button.data("is-liked", !isLiked);

    $.post("likeTweet", {
        tweetId: tweetId,
        userId: userId,
        action: action
    }, function(response) {
        if (response !== "success") {
            button.toggleClass("liked");
            heartIcon.toggleClass("far fas");
            likeCountElement.text(isLiked ? likeCount + 1 : likeCount - 1);
            button.data("is-liked", isLiked);
        } else {
            // Refresh the liked by section
            location.reload();
        }
    });
});

$(document).on("click", ".retweet-btn", function() {
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const userId = button.data("user-id");
    const isRetweeted = button.data("is-retweeted") === true || button.data("is-retweeted") === "true";
    const action = isRetweeted ? "unretweet" : "retweet";

    button.toggleClass("retweeted");

    const retweetCountElement = button.find(".action-count");
    let retweetCount = parseInt(retweetCountElement.text());
    retweetCount = isRetweeted ? retweetCount - 1 : retweetCount + 1;
    retweetCountElement.text(retweetCount);
    button.data("is-retweeted", !isRetweeted);

    $.post("retweet", {
        tweetId: tweetId,
        userId: userId,
        action: action
    }, function(response) {
        if (response !== "success") {
            button.toggleClass("retweeted");
            retweetCountElement.text(isRetweeted ? retweetCount + 1 : retweetCount - 1);
            button.data("is-retweeted", isRetweeted);
        } else {
            // Refresh the retweeted by section
            location.reload();
        }
    });
});

$(document).on("click", ".follow-btn", function() {
    const button = $(this);
    const userId = button.data("user-id");
    const isFollowing = button.text().trim() === "Following";

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
            } else {
                button.html('Following').removeClass("btn-primary").addClass("btn-secondary");
            }
        }
        button.prop('disabled', false);
    }, "json");
});
</script>
</body>
</html>