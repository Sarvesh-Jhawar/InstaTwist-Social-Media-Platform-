<%@ page import="java.util.List, cn.tech.model.Notification" %>
<%@ include file="includes/head.jsp" %>

<div class="container mt-5">
    <div class="row">
        <div class="col-md-8 offset-md-2">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="mb-0">Notifications</h2>
                <button id="markAllAsRead" class="btn btn-outline-secondary btn-sm">Mark all as read</button>
            </div>

            <div class="list-group" id="notificationsList">

                <!-- Unread Notifications -->
                <h5 class="mb-3">Unread</h5>
                
                
                <%
                    List<Notification> unread = (List<Notification>) request.getAttribute("unreadNotifications");
                    if (unread != null && !unread.isEmpty()) {
                        for (Notification n : unread) {
                            String profilePic = (n.getSenderProfilePic() != null) ? n.getSenderProfilePic() : "images/default-profile.png";
                            String senderName = (n.getSenderName() != null) ? n.getSenderName() : "Someone";
                            String actionText = "";
                            switch (n.getType()) {
                                case "like": actionText = "liked your post"; break;
                                case "comment": actionText = "commented on your post"; break;
                                case "follow": actionText = "started following you"; break;
                                case "mention": actionText = "mentioned you in a comment"; break;
                                default: actionText = "interacted with you"; break;
                            }
                            String link = "#";
                            if ("like".equals(n.getType()) || "comment".equals(n.getType())) {
                                link = "post.jsp?id=" + n.getPostId();
                            } else if ("mention".equals(n.getType())) {
                                link = "post.jsp?id=" + n.getPostId() + (n.getCommentId() != null ? "#comment-" + n.getCommentId() : "");
                            } else if ("follow".equals(n.getType())) {
                                link = "profile.jsp?id=" + n.getSenderId();
                            }
                %>
                    <a href="<%= link %>" class="list-group-item list-group-item-action list-group-item-primary notification-item" data-id="<%= n.getId() %>">
                        <div class="d-flex align-items-center">
                            <img src="<%= profilePic %>" class="rounded-circle me-3" width="50" height="50" alt="Profile Picture">
                            <div>
                                <strong><%= senderName %></strong> <%= actionText %>
                                <div class="text-muted small"><%= n.getCreatedAt() %></div>
                            </div>
                        </div>
                    </a>
                <%
                        }
                    } else {
                %>
                    <div class="alert alert-info text-center">No unread notifications</div>
                <% } %>

                <!-- Read Notifications -->
                <h5 class="mb-3 mt-4">Read</h5>
                <%
                    List<Notification> read = (List<Notification>) request.getAttribute("readNotifications");
                    if (read != null && !read.isEmpty()) {
                        for (Notification n : read) {
                            String profilePic = (n.getSenderProfilePic() != null) ? n.getSenderProfilePic() : "images/default-profile.png";
                            String senderName = (n.getSenderName() != null) ? n.getSenderName() : "Someone";
                            String actionText = "";
                            switch (n.getType()) {
                                case "like": actionText = "liked your post"; break;
                                case "comment": actionText = "commented on your post"; break;
                                case "follow": actionText = "started following you"; break;
                                case "mention": actionText = "mentioned you in a comment"; break;
                                default: actionText = "interacted with you"; break;
                            }
                            String link = "#";
                            if ("like".equals(n.getType()) || "comment".equals(n.getType())) {
                                link = "post.jsp?id=" + n.getPostId();
                            } else if ("mention".equals(n.getType())) {
                                link = "post.jsp?id=" + n.getPostId() + (n.getCommentId() != null ? "#comment-" + n.getCommentId() : "");
                            } else if ("follow".equals(n.getType())) {
                                link = "profile.jsp?id=" + n.getSenderId();
                            }
                %>
                    <a href="<%= link %>" class="list-group-item list-group-item-action list-group-item-light notification-item" data-id="<%= n.getId() %>">
                        <div class="d-flex align-items-center">
                            <img src="<%= profilePic %>" class="rounded-circle me-3" width="50" height="50" alt="Profile Picture">
                            <div>
                                <strong><%= senderName %></strong> <%= actionText %>
                                <div class="text-muted small"><%= n.getCreatedAt() %></div>
                            </div>
                        </div>
                    </a>
                <%
                        }
                    } else {
                %>
                    <div class="alert alert-secondary text-center">No read notifications</div>
                <% } %>
            </div>
        </div>
    </div>
</div>
<!-- jQuery CDN -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
$(document).ready(function() {
    // Mark individual notification as read
    $('.notification-item').click(function() {
        const notificationId = $(this).data('id');
        $.post('notifications', {
            action: 'markAsRead',
            id: notificationId
        });
    });

    // Mark all notifications as read
    $('#markAllAsRead').click(function() {
    	$.post('notifications', {
    	    action: 'markAllAsRead'
    	}, function(response) {
    	    console.log("Server Response: ", response);  // Log server response
    	    location.reload();
    	}).fail(function() {
    	    alert('Error marking notifications as read.');
    	});

    });
});
</script>

<%@ include file="includes/footer.jsp" %>
