<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%@ page import="java.util.List" %>
<%@ page import="cn.tech.Dao.TweetDao" %>
<%@ page import="cn.tech.Dao.FollowDao" %>

<%@ page import="cn.tech.Dao.TweetCommentDao" %>
<%@ page import="cn.tech.Dao.TweetLikeDao" %>
<%@ page import="cn.tech.Dao.UserDao" %>
<%@ page import="cn.tech.model.Tweet" %>
<%@ page import="cn.tech.model.TweetComment" %>
<%@ page import="cn.tech.model.User" %>
<%@ page import="java.util.Collections" %>

<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    TweetDao tweetDao = new TweetDao();
    TweetCommentDao tweetCommentDao = new TweetCommentDao();
    TweetLikeDao tweetLikeDao = new TweetLikeDao();
    UserDao userDao = new UserDao();
    List<Tweet> tweets = tweetDao.getAllTweets();
    Collections.shuffle(tweets);
    UserDao userDAO = new UserDao(); 
    FollowDao followDao=new FollowDao();
%>

<!DOCTYPE html>
<html lang="en">
<head>

    <meta charset="UTF-8">
    <title>Twittar - Home</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .comment-section {
            display: none;
        }
        
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
            background-color: var(--light-color);
            color: var(--dark-color);
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }
        
        .main-container {
            display: flex;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px 15px;
            gap: 20px;
        }
        
        .content-area {
            flex: 2;
            max-width: 600px;
        }
        
        .sidebar-area {
            flex: 1;
            max-width: 350px;
            position: sticky;
            top: 20px;
            height: fit-content;
        }
        
        .tweet-card, .sidebar-card {
            background-color: white;
            border-radius: 16px;
            border: 1px solid var(--border-color);
            margin-bottom: 15px;
            transition: box-shadow 0.2s;
        }
        
        .tweet-card:hover {
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
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
            flex-shrink: 0;
        }
        
        .tweet-header {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
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
            font-size: 1.1em;
            line-height: 1.4;
            margin-bottom: 12px;
        }
        
        .tweet-actions {
            display: flex;
            justify-content: space-between;
            max-width: 400px;
            margin-top: 10px;
        }
        
        .tweet-action {
            display: flex;
            align-items: center;
            color: #657786;
            font-size: 0.9em;
            cursor: pointer;
            padding: 5px 10px;
            border-radius: 20px;
            transition: all 0.2s;
        }
        
        .tweet-action:hover {
            background-color: rgba(29, 161, 242, 0.1);
        }
        
        .tweet-action i {
            margin-right: 5px;
        }
        
        .comment-section {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
        }
        
        .comment {
            display: flex;
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
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
            font-weight: 700;
            margin-right: 5px;
        }
        
        .comment-text {
            margin-top: 3px;
        }
        
        .suggestion-user {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
        }
        
        .suggestion-user:last-child {
            border-bottom: none;
        }
        
        .follow-btn {
            border-radius: 20px;
            padding: 3px 12px;
            font-size: 0.85em;
            font-weight: bold;
        }
        
        .sidebar-title {
            font-size: 1.2em;
            font-weight: 700;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .tweet-form {
            margin-bottom: 20px;
        }
        
        .tweet-form textarea {
            border: none;
            resize: none;
            padding: 15px;
            font-size: 1.1em;
            border-radius: 10px;
            margin-bottom: 10px;
        }
        
        .tweet-form textarea:focus {
            box-shadow: none;
            outline: none;
        }
        
        .tweet-submit {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 20px;
            padding: 5px 20px;
            font-weight: bold;
            float: right;
        }
        
        .tweet-submit:hover {
            background-color: #1991da;
        }
        
        .char-count {
            color: #657786;
            font-size: 0.9em;
        }
        
        .liked {
            color: var(--danger-color) !important;
        }
        
        .retweeted {
            color: var(--success-color) !important;
        }
        
        .action-count {
            margin-left: 5px;
        }
        
        .like-btn, .retweet-btn {
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            color: inherit;
            font-size: inherit;
        }
        
        .toast-notification {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: #28a745;
            color: white;
            padding: 12px 24px;
            border-radius: 4px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: none;
            z-index: 1000;
        }

        .comment-input-group {
            margin-top: 15px;
        }
        
        .comment-input {
            border-radius: 20px;
            padding: 8px 15px;
        }
    </style>
</head>
<body>

<div class="main-container">
    <div class="content-area">
        <!-- New Tweet Form -->
        <div class="card tweet-card tweet-form">
            <div class="card-body">
                <form id="tweetForm" onsubmit="return postTweet(event)">
                    <input type="hidden" name="userId" value="<%= currentUser.getId() %>">
                    <div class="form-group">
                        <textarea class="form-control" name="content" rows="3" placeholder="What's happening?" required maxlength="280"></textarea>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted char-count" id="charCount">280 characters remaining</small>
                        <button type="submit" class="btn btn-primary tweet-submit">Tweet</button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Tweets Feed -->
        <div id="tweetsContainer">
            <% for (Tweet tweet : tweets) {
                User tweetUser = userDao.getUserById(tweet.getUserId());
                if (tweetUser == null) continue;
                int likeCount = tweetLikeDao.getLikesCount(tweet.getTweetId());
                int retweetCount = tweetDao.getRetweetCount(tweet.getTweetId());
                boolean isLiked = tweetLikeDao.isLiked(tweet.getTweetId(), currentUser.getId());
                boolean isRetweeted = tweetDao.isRetweeted(tweet.getTweetId(), currentUser.getId());
                List<TweetComment> comments = tweetCommentDao.getCommentsForTweet(tweet.getTweetId());
            %>
           <div class="card tweet-card" 
     id="tweet-<%= tweet.getTweetId() %>" 
     data-tweet-id="<%= tweet.getTweetId() %>">
                <div class="card-body">
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
                        
                        <button class="tweet-action"
        onclick="openShareModal(<%= tweet.getTweetId() %>)">
    <i class="fas fa-share"></i> 
</button>
                        
                    </div>

                    <!-- Comment Section -->
                    <div class="comment-section" id="commentSection<%= tweet.getTweetId() %>">
                        <div id="commentsList<%= tweet.getTweetId() %>">
                            <% if (comments.isEmpty()) { %>
                                <p class="text-muted">No comments yet. Be the first to comment!</p>
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
                                            <span class="tweet-time"><%= comment.getCommentedAt() %></span>
                                        </div>
                                        <div class="comment-text"><%= comment.getComment() %></div>
                                    </div>
                                </div>
                            <% } 
                               } %>
                        </div>
                        
                        <% if (currentUser != null) { %>
                            <div class="comment-input-group">
                                <input type="text" class="form-control comment-input" 
       placeholder="Write a comment..." 
       id="commentInput<%= tweet.getTweetId() %>">
<button class="btn btn-primary post-comment-btn mt-2" data-tweet-id="<%= tweet.getTweetId() %>">
    <i class="fas fa-paper-plane mr-2"></i> Post Comment
</button>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Sidebar -->
    <div class="sidebar-area">
        <div class="card sidebar-card">
            <div class="card-body">
                <h5 class="sidebar-title">Suggestions For You</h5>
                <ul class="list-unstyled">
                    <% 
                    List<User> suggestedUsers = userDAO.getSuggestedUsers(currentUser != null ? currentUser.getId() : 0);
                    Collections.shuffle(suggestedUsers);
                    for (User u : suggestedUsers) { 
                        boolean isFollowing = currentUser != null && userDAO.isFollowing(currentUser.getId(), u.getId());
                    %>
                    <li>
                        <div class="suggestion-user">
                            <div class="user-avatar">
                                <%= u.getUsername().substring(0, 1).toUpperCase() %>
                            </div>
                            <h6><a href="user.jsp?userId=<%= u.getId() %>" class="text-decoration-none"><%= u.getUsername() %></a></h6>
                            <% if (currentUser != null) { %>
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
<!-- Share Tweet Modal -->
<div class="modal fade" id="shareModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-scrollable">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
//card click to go to tweet page
$(document).on("click", ".tweet-card", function(event) {
    if ($(event.target).closest('.tweet-action, button, i').length > 0) {
        return;
    }
    const tweetId = $(this).data("tweet-id");
    window.location.href = "tweet.jsp?tweetId=" + tweetId;
});

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

// Toggle comment section visibility
function toggleCommentSection(button, tweetId) {
    const cardBody = $(button).closest('.card-body');
    const commentSection = cardBody.find('#commentSection' + tweetId);
    
    if (commentSection.is(':visible')) {
        commentSection.slideUp();
    } else {
        commentSection.slideDown();
        // Focus the input when shown
        commentSection.find('.comment-input').focus();
    }
}

// Handle comment submission
$(document).on("click", ".post-comment-btn", function(e) {
    e.preventDefault();
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const commentInput = button.closest(".comment-input-group").find(".comment-input");
    const commentText = commentInput.val().trim();
    const commentSection = $("#commentSection" + tweetId);
    const commentsContainer = $("#commentsList" + tweetId);

    if (!commentText) {
        showToast("Comment cannot be empty!");
        return;
    }

    // Add loading state
    const originalText = button.html();
    button.html('<i class="fas fa-spinner fa-spin"></i>').prop('disabled', true);

    $.post("commentTweet", {
        tweetId: tweetId,
        userId: <%= currentUser.getId() %>,
        commentText: commentText
    }).done(function(response) {
        console.log("Server response:", response);
        if (response.startsWith("success")) {
            const parts = response.split("|");
            console.log("Split parts:", parts);
            
            if (parts.length >= 4) {
                const username = parts[1];
                const createdAt = parts[2];
                const content = parts[3];

                // Create new comment element using jQuery DOM creation
                const newComment = $('<div class="comment">')
                    .append($('<div class="user-avatar">').text(username.substring(0, 1).toUpperCase()))
                    .append($('<div class="comment-content">')
                        .append($('<div>')
                            .append($('<span class="comment-user">').text(username))
                            .append($('<span class="tweet-time">').text(createdAt))
                        )
                        .append($('<div class="comment-text">').text(content))
                    );

                // Insert the new comment
                if (commentsContainer.find(".text-muted").length > 0) {
                    commentsContainer.html(newComment);
                } else {
                    commentsContainer.prepend(newComment);
                }

                // Update comment count
                const count = commentsContainer.find('.comment').length;
                $('#commentCount' + tweetId).text(count);

                // Clear input
                commentInput.val('');
                showToast("Comment posted!");
            } else {
                showToast("Invalid response format!");
            }
        } else {
            showToast("Error posting comment!");
        }
    }).fail(function(xhr) {
        console.error("Error:", xhr.responseText);
        showToast("Failed to post comment");
    }).always(function() {
        button.html(originalText).prop('disabled', false);
    });
});

// Toast notification function
function showToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast-notification';
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.display = 'block';
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, 3000);
    }, 10);
}

// Character counter for tweet textarea
$('textarea[name="content"]').on('input', function() {
    const remaining = 280 - $(this).val().length;
    $('#charCount').text(remaining + ' characters remaining');
    
    if (remaining < 0) {
        $(this).css('borderColor', 'red');
        $('#charCount').css('color', 'red');
    } else if (remaining < 20) {
        $(this).css('borderColor', 'orange');
        $('#charCount').css('color', 'orange');
    } else {
        $(this).css('borderColor', '');
        $('#charCount').css('color', '');
    }
});

// Prevent form resubmission on page refresh
if (window.history.replaceState) {
    window.history.replaceState(null, null, window.location.href);
}

// Like/unlike tweet with AJAX
$(document).on("click", ".like-btn", function() {
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const userId = button.data("user-id");
    const isLiked = button.data("is-liked") === true || button.data("is-liked") === "true";
    const action = isLiked ? "unlike" : "like";

    // Immediate UI update
    button.toggleClass("liked");
    const heartIcon = button.find("i");
    heartIcon.toggleClass("far fas");

    const likeCountElement = button.find(".action-count");
    let likeCount = parseInt(likeCountElement.text());
    likeCount = isLiked ? likeCount - 1 : likeCount + 1;
    likeCountElement.text(likeCount);
    button.data("is-liked", !isLiked);

    // Send request to server
    $.post("likeTweet", {
        tweetId: tweetId,
        userId: userId,
        action: action
    }, function(response) {
        if (response !== "success") {
            // Revert UI changes if server failed
            button.toggleClass("liked");
            heartIcon.toggleClass("far fas");
            likeCountElement.text(isLiked ? likeCount + 1 : likeCount - 1);
            button.data("is-liked", isLiked);
            showToast("Error updating like status!");
        }
    });
});

// Retweet/unretweet with AJAX
$(document).on("click", ".retweet-btn", function() {
    const button = $(this);
    const tweetId = button.data("tweet-id");
    const userId = button.data("user-id");
    const isRetweeted = button.data("is-retweeted") === true || button.data("is-retweeted") === "true";
    const action = isRetweeted ? "unretweet" : "retweet";

    // Immediate UI update
    button.toggleClass("retweeted");

    const retweetCountElement = button.find(".action-count");
    let retweetCount = parseInt(retweetCountElement.text());
    retweetCount = isRetweeted ? retweetCount - 1 : retweetCount + 1;
    retweetCountElement.text(retweetCount);
    button.data("is-retweeted", !isRetweeted);

    // Send request to server
    $.post("retweet", {
        tweetId: tweetId,
        userId: userId,
        action: action
    }, function(response) {
        if (response !== "success") {
            // Revert UI changes if server failed
            button.toggleClass("retweeted");
            retweetCountElement.text(isRetweeted ? retweetCount + 1 : retweetCount - 1);
            button.data("is-retweeted", isRetweeted);
            showToast("Error updating retweet status!");
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

//Post new tweet
function postTweet(event) {
    event.preventDefault();
    const form = $(event.target);
    const content = form.find('textarea[name="content"]').val().trim();
    const userId = form.find('input[name="userId"]').val();
    const parentTweetId = form.find('input[name="parentTweetId"]').val(); // For replies
    const submitButton = form.find('button[type="submit"]');
    
    if (content === "") {
        showToast("Tweet cannot be empty!");
        return false;
    }

    if (content.length > 280) {
        showToast("Tweet exceeds 280 characters limit!");
        return false;
    }

    // Add loading state
    const originalText = submitButton.html();
    submitButton.html('<i class="fas fa-spinner fa-spin mr-2"></i> Posting...');
    submitButton.prop('disabled', true);

    // Prepare form data
    const formData = {
        userId: userId,
        content: content
    };

    // Add parentTweetId if it exists (for replies)
    if (parentTweetId) {
        formData.parentTweetId = parentTweetId;
    }

    $.ajax({
        url: "postTweet",
        type: "POST",
        data: formData,
        success: function(htmlResponse) {
            // Check if this is a reply
            if (parentTweetId) {
                // For replies, append to the comment section of the parent tweet
                $(`#commentSection${parentTweetId} #commentsList${parentTweetId} p.text-muted`).remove();
                $(`#commentSection${parentTweetId} #commentsList${parentTweetId}`).append(htmlResponse);
                // Show the comment section if it was hidden
                $(`#commentSection${parentTweetId}`).show();
            } else {
                // For new tweets, prepend to the main container
                $('#tweetsContainer').prepend(htmlResponse);
            }
            
            // Reset form
            form.find('textarea[name="content"]').val('');
            $('#charCount').text('280 characters remaining');
            
            // Show success message
            showToast(parentTweetId ? "Reply posted successfully!" : "Tweet posted successfully!");
            
            // Close the comment section if this was a reply
            if (parentTweetId) {
                $(`#tweet-${parentTweetId} .comment-section`).hide();
            }
        },
        error: function(xhr) {
            let errorMsg = "Error posting tweet";
            try {
                const errorResponse = xhr.responseText;
                if (errorResponse.startsWith("<div class='alert alert-danger'>")) {
                    errorMsg = $(errorResponse).text();
                } else {
                    errorMsg += ": " + (errorResponse || 'Please try again');
                }
            } catch (e) {
                errorMsg += ": Please try again";
            }
            showToast(errorMsg);
        },
        complete: function() {
            submitButton.html(originalText);
            submitButton.prop('disabled', false);
        }
    });
    
    return false;
}
//Function to prepend new tweet to feed
// Function to prepend new tweet to feed
function prependNewTweet(tweetData) {
    // Escape HTML and preserve line breaks
    const escapedContent = $('<div>').text(tweetData.content).html().replace(/\n/g, '<br>');
    
    const tweetHtml = `
        <div class="card tweet-card mb-3" id="tweet-${tweetData.id}">
            <div class="card-body">
                <div class="tweet-header">
                    <div class="user-avatar" style="background: linear-gradient(135deg, #4361ee, #3f37c9);">
                        ${tweetData.userName.charAt(0).toUpperCase()}
                    </div>
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center">
                            <span class="tweet-user">${tweetData.userName}</span>
                            <span class="tweet-username">@${tweetData.userHandle}</span>
                            <span class="tweet-time">· just now</span>
                        </div>
                    </div>
                </div>
                
                <div class="tweet-content">${escapedContent}</div>

                <div class="tweet-actions">
                    <button class="tweet-action comment-btn" onclick="toggleCommentSection(this, ${tweetData.id})">
                        <i class="far fa-comment"></i>
                        <span class="action-count">0</span>
                    </button>
                    
                    <button class="tweet-action retweet-btn" 
                            data-tweet-id="${tweetData.id}" 
                            data-user-id="${tweetData.currentUserId}" 
                            data-is-retweeted="false">
                        <i class="fas fa-retweet"></i>
                        <span class="action-count">0</span>
                    </button>
                    
                    <button class="tweet-action like-btn" 
                            data-tweet-id="${tweetData.id}" 
                            data-user-id="${tweetData.currentUserId}" 
                            data-is-liked="false">
                        <i class="far fa-heart"></i>
                        <span class="action-count">0</span>
                    </button>
                </div>

                <div class="comment-section" id="commentSection${tweetData.id}" style="display: none;">
                    <div id="commentsList${tweetData.id}">
                        <p class="text-muted">No comments yet. Be the first to comment!</p>
                    </div>
                    
                    <div class="comment-input-group">
                        <input type="text" class="form-control comment-input" 
                               placeholder="Write a comment..." 
                               id="commentInput${tweetData.id}">
                        <button class="btn btn-primary post-comment-btn mt-2" 
                                data-tweet-id="${tweetData.id}"
                                data-user-id="${tweetData.currentUserId}"
                                data-username="${tweetData.userName}"
                                data-user-avatar="${tweetData.userName.charAt(0).toUpperCase()}">
                            <i class="fas fa-paper-plane mr-2"></i> Post Comment
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    $('#tweetsContainer').prepend(tweetHtml);
}

</script>
</body>
</html>