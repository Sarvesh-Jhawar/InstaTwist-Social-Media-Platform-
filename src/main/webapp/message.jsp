<%@ page import="cn.tech.model.User, cn.tech.model.Message, cn.tech.Dao.MessageDao, cn.tech.Dao.FollowDao" %>
<%@ page import="cn.tech.model.Post, cn.tech.Dao.PostDao" %>
<%@ include file="includes/head.jsp" %>
<%@ include file="includes/navbar.jsp" %>
<%@ page import="cn.tech.model.Tweet, cn.tech.Dao.TweetDao" %>
<%@ page import="java.util.*, java.util.HashSet, java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    MessageDao messageDao = new MessageDao();
    FollowDao followDao = new FollowDao();
    PostDao postDao = new PostDao();
    TweetDao tweetDao = new TweetDao();

    List<User> recentConversations = messageDao.getRecentConversations(currentUser.getId());
    if (recentConversations == null) recentConversations = new ArrayList<>();

    List<User> following = followDao.getFollowing(currentUser.getId());
    if (following == null) following = new ArrayList<>();

    Set<Integer> recentUserIds = new HashSet<>();
    for (User u : recentConversations) recentUserIds.add(u.getId());

    List<User> followingNotInRecent = new ArrayList<>();
    for (User u : following) {
        if (!recentUserIds.contains(u.getId())) {
            followingNotInRecent.add(u);
        }
    }

    Integer otherUserId = null;
    List<Message> messages = null;
    String userIdParam = request.getParameter("userId");
    if (userIdParam != null && !userIdParam.isEmpty()) {
        otherUserId = Integer.parseInt(userIdParam);
        if (followDao.isFollowing(currentUser.getId(), otherUserId)) {
            messages = messageDao.getMessagesBetweenUsers(currentUser.getId(), otherUserId);
            messageDao.markMessagesAsRead(otherUserId, currentUser.getId());
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Messages</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/emojionearea@3.4.2/dist/emojionearea.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color:#f0f2f5; }
        .conversation-panel {
            background:#fff; 
            border-radius:10px; 
            border:1px solid #ddd;
            overflow:hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .conversation-item { 
            cursor:pointer; 
            padding:12px 15px; 
            border-bottom:1px solid #eee; 
            display:flex; 
            align-items:center; 
            gap:12px; 
            transition:background 0.3s;
        }
        .conversation-item:hover { background:#f8f9fa; }
        .conversation-item.active { background:#e7f0ff; }
        .user-avatar { 
            width:45px; height:45px; border-radius:50%; 
            background:#0d6efd; 
            color:white; display:flex; 
            align-items:center; justify-content:center; 
            font-weight:bold; 
            font-size:18px;
            flex-shrink: 0;
        }
        .user-info {
            flex-grow: 1;
            min-width: 0;
        }
        .user-name {
            font-weight: 600;
            margin-bottom: 2px;
        }
        .last-message {
            font-size: 13px;
            color: #6c757d;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .message-container {
            display: flex;
            flex-direction: column;
            margin-bottom: 8px;
            max-width: 80%;
        }
        .message-bubble { 
            padding: 10px 15px;
            border-radius: 18px;
            word-wrap: break-word;
            position: relative;
            display: inline-block;
            max-width: 100%;
        }
        .sent { 
            background:#0d6efd; 
            color:white; 
            align-self: flex-end;
            border-bottom-right-radius: 4px;
        }
        .received { 
            background:#e4e6eb; 
            color:#000; 
            align-self: flex-start;
            border-bottom-left-radius: 4px;
        }
        .message-time {
            font-size: 11px;
            color: rgba(255, 255, 255, 0.8);
            margin-top: 4px;
            text-align: right;
        }
        .received .message-time {
            color: #6c757d;
        }
        .post-preview, .tweet-preview { 
            border-radius:10px; 
            padding:8px; 
            margin-top:5px; 
            background:#fff; 
            border:1px solid #ddd;
        }
        #messageArea { 
            height:550px; 
            overflow-y:auto; 
            background:white; 
            border-top:1px solid #ddd; 
            border-bottom:1px solid #ddd;
            padding:15px; 
            display: flex;
            flex-direction: column;
        }
        .chat-header { 
            background:#fff; 
            padding:12px 15px; 
            border-bottom:1px solid #ddd; 
            display:flex; 
            align-items:center; 
            gap:10px;
        }
        .send-btn {
            background-color:#0d6efd;
            border:none;
            color:white;
            border-radius:30px;
            padding:8px 20px;
        }
        .send-btn:hover {
            background-color:#0b5ed7;
        }
        .message-input {
            border:none; 
            border-radius:20px; 
            padding:8px 15px;
            width:100%;
            resize:none;
        }
        .unread-count {
            background-color: #dc3545;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            margin-left: auto;
        }
        .section-title {
            padding: 10px 15px;
            font-size: 14px;
            font-weight: 600;
            color: #6c757d;
            background-color: #f8f9fa;
            text-transform: uppercase;
        }
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            padding: 20px;
            text-align: center;
            color: #6c757d;
        }
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            color: #dee2e6;
        }
    </style>
</head>
<body class="container py-4">
<h3 class="mb-4">Messages</h3>
<div class="row conversation-panel shadow-sm">
    <!-- Conversations list -->
    <div class="col-md-4 p-0 border-end">
        <% if (!recentConversations.isEmpty()) { %>
            <div class="section-title">Recent Conversations</div>
            <% for (User kuser : recentConversations) {
                boolean isActive = (otherUserId != null && otherUserId.equals(kuser.getId()));
                int unreadCount = messageDao.getUnreadMessageCount(kuser.getId(), currentUser.getId());
                String lastMessage = messageDao.getLastMessagePreview(currentUser.getId(), kuser.getId());
            %>
                <div class="conversation-item <%= isActive ? "active" : "" %>"
                     onclick="loadChat(<%=kuser.getId()%>, this)">
                    <div class="user-avatar"><%= kuser.getUsername().substring(0,1).toUpperCase() %></div>
                    <div class="user-info">
                        <div class="user-name"><%= kuser.getUsername() %></div>
                        <div class="last-message">
                            <%= lastMessage.equals("No messages yet") ? "Tap to chat" : lastMessage %>
                        </div>
                    </div>
                    <% if (unreadCount > 0) { %>
                        <div class="unread-count"><%= unreadCount %></div>
                    <% } %>
                </div>
            <% } %>
        <% } %>
        
        <% if (!followingNotInRecent.isEmpty()) { %>
            <div class="section-title">Your Following</div>
            <% for (User kuser : followingNotInRecent) { %>
                <div class="conversation-item"
                     onclick="loadChat(<%=kuser.getId()%>, this)"
>
                    <div class="user-avatar"><%= kuser.getUsername().substring(0,1).toUpperCase() %></div>
                    <div class="user-info">
                        <div class="user-name"><%= kuser.getUsername() %></div>
                        <div class="last-message">Tap to chat</div>
                    </div>
                </div>
            <% } %>
        <% } %>
        
        <% if (recentConversations.isEmpty() && followingNotInRecent.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-comment-dots"></i>
                <h5>No conversations yet</h5>
                <p>Start a conversation with someone you follow</p>
            </div>
        <% } %>
    </div>

    <!-- Chat area -->
<div class="col-md-8 d-flex flex-column p-0" id="chatPanel">
        <% if (otherUserId != null && messages != null) { %>
            <div class="chat-header">
                <div class="user-avatar">
                    <% for(User u: following) { if(u.getId() == otherUserId) { out.print(u.getUsername().substring(0,1).toUpperCase()); break; } } %>
                </div>
                <strong>
                    <% for(User u: following) { if(u.getId() == otherUserId) { out.print(u.getUsername()); break; } } %>
                </strong>
            </div>
            <div id="messageArea">
                <% if (messages.isEmpty()) { %>
                    <div class="empty-state" style="height: 100%;">
                        <i class="fas fa-comment-slash"></i>
                        <h5>No messages yet</h5>
                        <p>Send a message to start the conversation</p>
                    </div>
                <% } else { %>
                    <% for (Message m : messages) { 
                        boolean isSent = m.getSenderId() == currentUser.getId();
                    %>
                        <div class="message-container">
                            <div class="message-bubble <%= isSent ? "sent" : "received" %>">
                                <%= m.getContent() %>
                                <% if (m.getPostId() != 0) {
                                    Post sharedPost = postDao.getPostById(m.getPostId());
                                    if(sharedPost != null) { %>
                                        <div class="post-preview mt-2">
                                            <a href="post.jsp?postId=<%= sharedPost.getId() %>" class="text-decoration-none text-dark">
                                                <p><%= sharedPost.getContent() %></p>
                                                <% if (sharedPost.getImagePath() != null && !sharedPost.getImagePath().isEmpty()) {
                                                    String ext = sharedPost.getImagePath().substring(sharedPost.getImagePath().lastIndexOf(".")+1).toLowerCase();
                                                    boolean isVideo = ext.matches("mp4|webm|ogg"); %>
                                                    <% if (isVideo) { %>
                                                        <video controls style="max-width:100%">
                                                            <source src="post-images/<%= sharedPost.getImagePath() %>" type="video/<%=ext%>">
                                                        </video>
                                                    <% } else { %>
                                                        <img src="post-images/<%= sharedPost.getImagePath() %>" style="max-width:100%" alt="Post image">
                                                    <% } %>
                                                <% } %>
                                            </a>
                                        </div>
                                    <% }
                                } %>
                                <% if (m.getTweetId() != 0) { 
                                    Tweet sharedTweet = tweetDao.getTweetById(m.getTweetId());
                                    if(sharedTweet != null) { %>
                                        <div class="tweet-preview mt-2">
                                            <a href="tweet.jsp?tweetId=<%= sharedTweet.getTweetId() %>" class="text-decoration-none text-dark">
                                                <%= sharedTweet.getContent() %>
                                            </a>
                                        </div>
                                    <% }
                                } %>
                                <div class="message-time">
                                    <%= m.getCreatedAt().toString().substring(11,16) %>
                                    <% if (isSent) { %>
                                        <i class="fas fa-check ml-1" style="font-size:10px;"></i>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
            <form class="p-3 border-top d-flex gap-2 align-items-center" onsubmit="return sendMessage(event)">
    <input type="hidden" id="receiverId" value="<%=otherUserId%>">
    <input type="hidden" id="tweetIdField" value="0">
    <textarea id="messageContent" class="message-input" placeholder="Type your message..."></textarea>
    <button type="submit" class="send-btn">Send</button>
</form>

        <% } else { %>
            <div class="empty-state" style="height: 100%;">
                <i class="fas fa-comments"></i>
                <h5>Select a conversation</h5>
                <p>Choose a contact to start chatting</p>
            </div>
        <% } %>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/emojionearea@3.4.2/dist/emojionearea.min.js"></script>
<script>
function loadChat(userId, clickedElement) {
    $.get("message?userId=" + userId, function (html) {
        const newChatHTML = $(html).find("#chatPanel").html();
        $("#chatPanel").html(newChatHTML);

        // Update browser URL
        history.pushState(null, "", "message.jsp?userId=" + userId);

        // Highlight active user
        $(".conversation-item").removeClass("active");
        $(clickedElement).addClass("active");

        // Scroll to bottom
        const messageArea = document.getElementById("messageArea");
        if (messageArea) messageArea.scrollTop = messageArea.scrollHeight;
    });
}
function sendMessage(event) {
    event.preventDefault();

    const content = $("#messageContent").val().trim();
    const receiverId = $("#receiverId").val();
    const tweetId = $("#tweetIdField").val();

    if (content === "") return false;

    $.post("message", {
        receiverId: receiverId,
        content: content,
        tweetId: tweetId,
        postId: 0
    }).done(function(response) {
        if (response.startsWith("success")) {
            const parts = response.split("|");
            if (parts.length >= 4) {
                const username = parts[1];
                const createdAt = parts[2];
                const messageText = parts[3];

                const messageBubble = $('<div class="message-container">').append(
                    $('<div class="message-bubble sent">')
                        .text(messageText)
                        .append(
                            $('<div class="message-time">')
                                .html(createdAt + ' <i class="fas fa-check ml-1" style="font-size:10px;"></i>')
                        )
                );

                $('#messageArea').append(messageBubble);
                $('#messageContent').val('').emojioneArea()[0].emojioneArea.setText('');

                let area = document.getElementById("messageArea");
                area.scrollTop = area.scrollHeight;
            }
        } else {
            alert("Failed to send message.");
        }
    }).fail(function() {
        alert("Server error while sending message.");
    });

    return false;
}
    $(document).ready(function(){
        $("#messageContent").emojioneArea({
            pickerPosition: "top",
            tonesStyle: "bullet"
        });
    });
    window.onload = function(){
        const messageArea = document.getElementById('messageArea');
        if(messageArea) messageArea.scrollTop = messageArea.scrollHeight;
    }
</script>
</body>
</html>