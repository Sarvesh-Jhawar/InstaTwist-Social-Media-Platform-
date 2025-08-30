<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="includes/head.jsp" %>

<%@ page import="java.util.List" %>
<%@ page import="cn.tech.model.User" %>
<%@ page import="cn.tech.model.Message" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="cn.tech.Dao.FollowDao" %>
<%@ page import="cn.tech.connection.*" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.ArrayList" %>
s

<%
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

FollowDao followDao = new FollowDao(DBCon.getConnection());
List<User> followingList = followDao.getFollowing(currentUser.getId());
List<User> messagedUsers = (List<User>) request.getAttribute("messagedUsers");
List<User> notMessagedUsers = (List<User>) request.getAttribute("notMessagedUsers");

// Ensure users don't appear in both sections
if (messagedUsers != null && followingList != null) {
    Set<Integer> messagedUserIds = new HashSet<>();
    for (User u : messagedUsers) {
        messagedUserIds.add(u.getId());
    }
    
    // Create filtered list of not messaged users
    if (notMessagedUsers == null) {
        notMessagedUsers = new ArrayList<>();
        for (User u : followingList) {
            if (!messagedUserIds.contains(u.getId())) {
                notMessagedUsers.add(u);
            }
        }
    }
} else if (notMessagedUsers == null) {
    notMessagedUsers = followingList;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Messages - Social Media</title>
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
            --chat-bg: #f5f7fb;
            --your-message: #dcf8c6;
            --their-message: #ffffff;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--chat-bg);
            margin: 0;
            height: 100vh;
        }

        .chat-container {
            display: flex;
            height: calc(100vh - 60px);
        }

        /* Sidebar Styles */
        .sidebar {
            width: 350px;
            background-color: white;
            border-right: 1px solid var(--light-gray);
            height: 100%;
            overflow-y: auto;
            box-shadow: var(--box-shadow);
        }

        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid var(--light-gray);
            font-weight: 600;
            font-size: 1.2rem;
            color: var(--dark-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .home-btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 5px;
            padding: 5px 10px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background-color 0.2s;
        }

        .home-btn:hover {
            background-color: var(--secondary-color);
        }

        .search-container {
            padding: 10px 20px;
            border-bottom: 1px solid var(--light-gray);
        }

        .search-input {
            width: 100%;
            padding: 8px 15px;
            border-radius: 20px;
            border: 1px solid var(--light-gray);
            outline: none;
            font-size: 0.9rem;
        }

        .search-input:focus {
            border-color: var(--accent-color);
        }

        .user-list {
            padding: 0;
            margin: 0;
            list-style: none;
        }

        .user-item {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            border-bottom: 1px solid var(--light-gray);
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .user-item:hover {
            background-color: var(--light-gray);
        }

        .user-item.active {
            background-color: rgba(67, 97, 238, 0.1);
        }

        .user-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 12px;
            border: 2px solid var(--light-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            background-color: var(--primary-color);
        }

        .user-info {
            flex-grow: 1;
        }

        .username {
            font-weight: 600;
            margin-bottom: 2px;
            color: var(--dark-color);
        }

        .last-message {
            font-size: 0.85rem;
            color: var(--gray-color);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 200px;
        }

        .unread-count {
            background-color: var(--primary-color);
            color: white;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .section-title {
            padding: 12px 20px;
            font-weight: 600;
            color: var(--gray-color);
            background-color: rgba(233, 236, 239, 0.5);
            font-size: 0.9rem;
            text-transform: uppercase;
        }

        /* Chat Area Styles */
        .chat-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .chat-header {
            padding: 16px 24px;
            background-color: white;
            border-bottom: 1px solid var(--light-gray);
            display: flex;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .chat-title {
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--dark-color);
            margin: 0;
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background-color: var(--chat-bg);
            background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AkEEjIZJQjJXQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAANElEQVQ4y2NgGAWjYBSMglEwCkbBKBgFowA3YGRkZPwPxQzQzIjMj5QZGRn/QzEjMj9SZmRk/A8AqJcHpQ0b0KQAAAAASUVORK5CYII=');
            background-repeat: repeat;
        }

        .message {
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            max-width: 70%;
        }

        .message.you {
            align-items: flex-end;
            margin-left: auto;
        }

        .message.other {
            align-items: flex-start;
            margin-right: auto;
        }

        .message-content {
            padding: 12px 16px;
            border-radius: 18px;
            line-height: 1.4;
            word-wrap: break-word;
            position: relative;
        }

        .message.you .message-content {
            background-color: var(--your-message);
            color: var(--dark-color);
            border-top-right-radius: 4px;
        }

        .message.other .message-content {
            background-color: var(--their-message);
            color: var(--dark-color);
            border-top-left-radius: 4px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        .message-time {
            font-size: 0.75rem;
            color: var(--gray-color);
            margin-top: 4px;
        }

        .chat-input-container {
            padding: 16px;
            background-color: white;
            border-top: 1px solid var(--light-gray);
        }

        .chat-input-wrapper {
            display: flex;
            align-items: center;
            background-color: white;
            border-radius: 24px;
            padding: 8px 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .chat-input {
            flex: 1;
            border: none;
            outline: none;
            resize: none;
            padding: 8px 0;
            font-family: inherit;
            font-size: 0.95rem;
            max-height: 120px;
            min-height: 40px;
        }

        .send-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background-color 0.2s;
            margin-left: 8px;
        }

        .send-button:hover {
            background-color: var(--secondary-color);
        }

        .send-button i {
            font-size: 1.1rem;
        }

        /* Empty States */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            text-align: center;
            padding: 40px;
            color: var(--gray-color);
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 16px;
            color: var(--light-gray);
        }

        .empty-state h3 {
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--dark-color);
        }

        .small-empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: var(--gray-color);
            text-align: center;
        }

        .small-empty-state i {
            font-size: 1.5rem;
            margin-bottom: 8px;
            color: var(--light-gray);
        }

        /* Loading Indicator */
        .loading {
            display: flex;
            justify-content: center;
            padding: 20px;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid rgba(67, 97, 238, 0.2);
            border-radius: 50%;
            border-top-color: var(--primary-color);
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .chat-container {
                flex-direction: column;
                height: calc(100vh - 60px);
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                max-height: 40vh;
                border-right: none;
                border-bottom: 1px solid var(--light-gray);
            }
            
            .chat-area {
                flex: 1;
            }
            
            .message {
                max-width: 85%;
            }
        }
    </style>
</head>
<body>

<div class="chat-container">
    <!-- Left sidebar showing users -->
    <div class="sidebar">
        <div class="sidebar-header">
            <span><i class="fas fa-comments me-2"></i> Messages</span>
            <button class="home-btn" onclick="window.location.href='index.jsp'">
                <i class="fas fa-home"></i> Home
            </button>
        </div>
        
        <!-- Search Bar -->
        <div class="search-container">
            <input type="text" class="search-input" placeholder="Search conversations..." id="searchInput">
        </div>
        
        <!-- Recent Conversations Section -->
        <div class="section-title">Recent Conversations</div>
        <ul class="user-list" id="messagedUsersList">
            <% if (messagedUsers != null && !messagedUsers.isEmpty()) { %>
                <% for (User u : messagedUsers) { %>
                    <li class="user-item" onclick="startChat(<%= u.getId() %>, '<%= u.getUsername() %>')">
                        <% if (u.getProfileImage() != null && !u.getProfileImage().isEmpty()) { %>
                            <img src="post-images/<%= u.getProfileImage() %>" 
                                 class="user-avatar" alt="<%= u.getUsername() %>">
                        <% } else { %>
                            <div class="user-avatar"><%= u.getUsername().substring(0, 1).toUpperCase() %></div>
                        <% } %>
                        <div class="user-info">
                            <div class="username"><%= u.getUsername() %></div>
                            <div class="last-message">Last message preview...</div>
                        </div>
                        <% if (u.getUnreadCount() > 0) { %>
                            <div class="unread-count"><%= u.getUnreadCount() %></div>
                        <% } %>
                    </li>
                <% } %>
            <% } else { %>
                <div class="small-empty-state">
                    <i class="fas fa-comment-slash"></i>
                    <p>No conversations yet</p>
                </div>
            <% } %>
        </ul>
        
        <!-- People You Follow Section - Always shown -->
        <div class="section-title">People You Follow</div>
        <ul class="user-list" id="notMessagedUsersList">
            <% if (notMessagedUsers != null && !notMessagedUsers.isEmpty()) { %>
                <% for (User u : notMessagedUsers) { %>
                    <li class="user-item" onclick="startChat(<%= u.getId() %>, '<%= u.getUsername() %>')">
                        <% if (u.getProfileImage() != null && !u.getProfileImage().isEmpty()) { %>
                            <img src="post-images/<%= u.getProfileImage() %>" 
                                 class="user-avatar" alt="<%= u.getUsername() %>">
                        <% } else { %>
                            <div class="user-avatar"><%= u.getUsername().substring(0, 1).toUpperCase() %></div>
                        <% } %>
                        <div class="user-info">
                            <div class="username"><%= u.getUsername() %></div>
                            <div class="last-message">Click to start chatting</div>
                        </div>
                    </li>
                <% } %>
            <% } else { %>
                <div class="small-empty-state">
                    <i class="fas fa-user-plus"></i>
                    <p>You're not following anyone yet</p>
                </div>
            <% } %>
        </ul>
    </div>

    <!-- Main chat area -->
    <div class="chat-area">
        <div class="chat-header">
            <h2 class="chat-title" id="chatHeader">Select a conversation</h2>
        </div>
        
        <div class="chat-messages" id="chatMessages">
            <div class="empty-state">
                <i class="fas fa-comment-dots"></i>
                <h3>No conversation selected</h3>
                <p>Select a user from the sidebar to start chatting</p>
            </div>
        </div>
        
        <div class="chat-input-container" style="display: none;" id="messageInputContainer">
            <div class="chat-input-wrapper">
                <textarea class="chat-input" id="messageInput" placeholder="Type a message..."></textarea>
                <button class="send-button" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    let receiverId = null;
    let currentUsername = null;

    // Function to start a chat with a selected user
    function startChat(id, username) {
        console.log("startChat called with ID:", id, "username:", username);
        receiverId = id;
        currentUsername = username;
        
        // Update URL to reflect the current conversation
        window.history.pushState({}, '', 'messages.jsp?userId=' + id);
        
        // Update UI
        document.getElementById("chatHeader").innerText = username;
        document.getElementById("messageInputContainer").style.display = 'block';
        
        // Highlight selected user
        document.querySelectorAll('.user-item').forEach(item => {
            item.classList.remove('active');
        });
        event.currentTarget.classList.add('active');
        
        // Clear and prepare chat area
        const chatBox = document.getElementById("chatMessages");
        chatBox.innerHTML = `
            <div class="loading">
                <div class="spinner"></div>
            </div>
        `;
        
        // Fetch messages
        fetch("<%= request.getContextPath() %>/GetMessagesServlet?receiverId=" + receiverId)
            .then(res => {
                if (!res.ok) throw new Error("Failed to fetch messages");
                return res.text();
            })
            .then(html => {
                console.log("Fetched messages:", html);
                
                if (html.trim().length === 0) {
                    chatBox.innerHTML = `
                        <div class="empty-state">
                            <i class="fas fa-comment-medical"></i>
                            <h3>No messages yet</h3>
                            <p>Start a conversation with ${username}</p>
                        </div>
                    `;
                } else {
                    chatBox.innerHTML = html;
                }
                
                // Scroll to bottom
                chatBox.scrollTop = chatBox.scrollHeight;
            })
            .catch(err => {
                console.error("Error fetching messages:", err);
                chatBox.innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-exclamation-triangle"></i>
                        <h3>Error loading messages</h3>
                        <p>Please try again later</p>
                    </div>
                `;
            });
    }

    // Function to send a message
    function sendMessage() {
        const content = document.getElementById("messageInput").value.trim();
        if (!receiverId || !content) {
            alert("Please enter a message.");
            return;
        }

        // Optimistic UI update
        const chatBox = document.getElementById("chatMessages");
        if (chatBox.querySelector('.empty-state')) {
            chatBox.innerHTML = '';
        }
        
        const tempMsgId = 'temp-' + Date.now();
        chatBox.innerHTML += `
            <div class="message you" id="${tempMsgId}">
                <div class="message-content">${content}</div>
                <div class="message-time">Just now</div>
            </div>
        `;
        document.getElementById("messageInput").value = '';
        chatBox.scrollTop = chatBox.scrollHeight;
        
        // Send to server
        fetch("MessageServlet", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "receiverId=" + receiverId +
                  "&content=" + encodeURIComponent(content) +
                  "&postId=0&profileId=0"
        })
        .then(res => res.text())
        .then(html => {
            // Replace temporary message with server response
            const tempMsg = document.getElementById(tempMsgId);
            if (tempMsg) {
                tempMsg.outerHTML = html;
            } else {
                chatBox.innerHTML += html;
            }
            chatBox.scrollTop = chatBox.scrollHeight;
            
            // Refresh the sidebar to update conversation lists
            refreshSidebar();
        })
        .catch(err => {
            console.error("Error sending message:", err);
            // Show error on the temporary message
            const tempMsg = document.getElementById(tempMsgId);
            if (tempMsg) {
                tempMsg.querySelector('.message-content').innerHTML += 
                    '<br><small style="color:red">(Failed to send - please try again)</small>';
            }
        });
    }

    // Refresh sidebar to update conversation lists
    function refreshSidebar() {
        fetch("<%= request.getContextPath() %>/GetContactsServlet")
            .then(response => response.text())
            .then(html => {
                // Create a temporary element to parse the HTML
                const temp = document.createElement('div');
                temp.innerHTML = html;
                
                // Extract the sidebar content
                const newSidebar = temp.querySelector('.sidebar');
                if (newSidebar) {
                    // Replace our sidebar content
                    document.querySelector('.sidebar').innerHTML = newSidebar.innerHTML;
                    
                    // Reattach event listeners
                    document.querySelectorAll('.user-item').forEach(item => {
                        const onclick = item.getAttribute('onclick');
                        if (onclick && onclick.includes(receiverId)) {
                            item.classList.add('active');
                        }
                    });
                    
                    // Reattach search functionality
                    document.getElementById('searchInput').addEventListener('input', searchHandler);
                }
            })
            .catch(err => console.error("Error refreshing sidebar:", err));
    }

    // Search functionality
    function searchHandler() {
        const searchTerm = this.value.toLowerCase();
        searchInList('messagedUsersList', searchTerm);
        searchInList('notMessagedUsersList', searchTerm);
    }
    
    function searchInList(listId, searchTerm) {
        const list = document.getElementById(listId);
        if (!list) return;
        
        const items = list.getElementsByClassName('user-item');
        const emptyState = list.querySelector('.small-empty-state');
        
        let hasVisibleItems = false;
        
        for (let item of items) {
            const username = item.querySelector('.username').textContent.toLowerCase();
            if (username.includes(searchTerm)) {
                item.style.display = 'flex';
                hasVisibleItems = true;
            } else {
                item.style.display = 'none';
            }
        }
        
        // Show/hide empty state if needed
        if (emptyState) {
            emptyState.style.display = hasVisibleItems ? 'none' : 'flex';
        }
    }

    // Initialize search functionality
    document.getElementById('searchInput').addEventListener('input', searchHandler);

    // Auto-resize textarea
    document.getElementById('messageInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });

    // Send message on Enter key (but allow Shift+Enter for new lines)
    document.getElementById('messageInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Check URL for conversation ID on page load
    window.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const userId = urlParams.get('userId');
        
        if (userId) {
            // Find the user in either list and trigger click
            const userItem = document.querySelector(`.user-item[onclick*="${userId}"]`);
            if (userItem) {
                userItem.click();
            }
        }
    });
</script>

</body>
</html>