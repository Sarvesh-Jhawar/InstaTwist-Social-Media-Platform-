<%@ page import="cn.tech.model.User" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Get the logged-in user from the session
    User user = (User) session.getAttribute("user");
%>

<!-- Sidebar Navigation -->
<div class="sidebar-nav d-flex flex-column flex-shrink-0 p-3 bg-light" style="width: 280px; height: 100vh; position: fixed; left: 0; top: 0; box-shadow: 2px 0 10px rgba(0,0,0,0.1); z-index: 1000;">
    <!-- Brand/Logo -->
    <a href="index.jsp" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-decoration-none">
        <i class="fas fa-dove fs-3 text-primary me-2"></i>
        <span class="fs-4 fw-bold">SocialMedia</span>
    </a>
    
    <hr>
    
    <!-- Main Navigation -->
    <ul class="nav nav-pills flex-column mb-auto">
        <!-- Home -->
        <li class="nav-item">
            <a href="index.jsp" class="nav-link active d-flex align-items-center">
                <i class="fas fa-home me-2"></i>
                Home
            </a>
        </li>
        
        <!-- Search Bar - Placed right after Home -->
        <% if (user != null) { %>
            <li class="nav-item mb-3 position-relative">
                <div class="input-group">
                    <input type="text" id="liveSearchInput" name="q" class="form-control" placeholder="Search users..." autocomplete="off">
                    <button class="btn btn-primary" type="button">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
                <div id="liveSearchResults" class="position-absolute bg-white rounded shadow mt-1" style="width: 250px; left: 100%; top: 0; z-index: 1050; display: none; max-height: 400px; overflow-y: auto;"></div>
            </li>
        <% } %>
        
        <% if (user == null) { %>
            <!-- Show Login & Register when user is not logged in -->
            <li class="nav-item">
                <a href="login.jsp" class="nav-link d-flex align-items-center">
                    <i class="fas fa-sign-in-alt me-2"></i>
                    Login
                </a>
            </li>
            <li class="nav-item">
                <a href="registration.jsp" class="nav-link d-flex align-items-center">
                    <i class="fas fa-user-plus me-2"></i>
                    Register
                </a>
            </li>
        <% } else { %>
            <!-- Profile -->
            <li class="nav-item">
                <a href="profile.jsp" class="nav-link d-flex align-items-center">
                    <i class="fas fa-user me-2"></i>
                    <%= user.getUsername() %>
                </a>
            </li>
            <li class="nav-item">
                <a href="home.jsp" class="nav-link d-flex align-items-center">
                    <i class="fas fa-feather-alt me-2"></i>
                    Tweets
                    <span class="badge bg-success rounded-pill ms-auto" id="tweetBadge"></span>
                </a>
            </li>
            
            <!-- Messages -->
            <li class="nav-item">
                <a href="message.jsp" class="nav-link d-flex align-items-center">
                    <i class="fas fa-envelope me-2"></i>
                    Messages
                    <span class="badge bg-primary rounded-pill ms-auto" id="messageBadge"></span>
                </a>
            </li>
            
            <!-- Notifications -->
            <li class="nav-item">
                <a href="#" class="nav-link d-flex align-items-center" data-bs-toggle="collapse" data-bs-target="#notificationsCollapse">
                    <i class="fas fa-bell me-2"></i>
                    Notifications
                    <span class="badge bg-danger rounded-pill ms-auto" id="notificationBadge"></span>
                </a>
                <div class="collapse" id="notificationsCollapse">
                    <div class="p-2 bg-white rounded mt-2" style="max-height: 300px; overflow-y: auto;">
                        <div id="notificationItems">
                            <div class="text-center py-2">
                                <div class="spinner-border spinner-border-sm" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                            </div>
                        </div>
                        <div class="d-grid mt-2">
                            <a href="notifications?action=viewAll" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>
                    </div>
                </div>
            </li>
            
            <!-- Logout -->
            <li class="nav-item">
                <a href="log-out" class="nav-link d-flex align-items-center">
                    <i class="fas fa-sign-out-alt me-2"></i>
                    Logout
                </a>
            </li>
        <% } %>
    </ul>
</div>

<!-- Main Content Area (needs padding to account for fixed sidebar) -->
<div class="main-content" style="margin-left: 280px; padding: 20px;">
    <!-- Your page content goes here -->
</div>

<!-- Custom CSS for the Sidebar -->
<style>
.avatar-fallback-sm {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: #4361ee;
    color: white;
    font-weight: bold;
    margin-right: 10px;
}

.rounded-circle {
    border-radius: 50%;
}
    .sidebar-nav {
        transition: all 0.3s ease;
    }
    
    .sidebar-nav .nav-link {
        border-radius: 8px;
        margin-bottom: 5px;
        transition: all 0.2s ease;
        padding: 10px 15px;
    }
    
    .sidebar-nav .nav-link:hover {
        background-color: rgba(0, 0, 0, 0.05);
    }
    
    .sidebar-nav .nav-link.active {
        background-color: #4361ee;
        color: white;
    }
    
    .sidebar-nav .nav-link i {
        width: 20px;
        text-align: center;
    }
    
    .notification-item {
        padding: 8px 12px;
        border-bottom: 1px solid #eee;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    
    .notification-item:hover {
        background-color: #f8f9fa;
    }
    
    .notification-item.unread {
        font-weight: 500;
        background-color: #f8f9fa;
    }
    
    .notification-time {
        font-size: 0.8rem;
        color: #6c757d;
    }
    
    #liveSearchResults {
        border: 1px solid #dee2e6;
        padding: 5px;
    }
    
    #liveSearchResults a {
        display: flex;
        align-items: center;
        padding: 8px 12px;
        text-decoration: none;
        color: #212529;
    }
    
    #liveSearchResults a:hover {
        background-color: #f8f9fa;
    }
    
    .search-user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        margin-right: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: bold;
        background-color: #4361ee;
    }
    
    /* Responsive adjustments */
    @media (max-width: 992px) {
        .sidebar-nav {
            width: 250px;
        }
        
        .main-content {
            margin-left: 250px;
        }
    }
    
    @media (max-width: 768px) {
        .sidebar-nav {
            transform: translateX(-100%);
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            z-index: 1050;
        }
        
        .sidebar-nav.show {
            transform: translateX(0);
        }
        
        .main-content {
            margin-left: 0;
        }
        
        #liveSearchResults {
            width: 250px;
            left: auto !important;
            right: 0 !important;
        }
        
        /* Mobile toggle button */
        .sidebar-toggle {
            position: fixed;
            left: 10px;
            top: 10px;
            z-index: 1051;
            background: #4361ee;
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
    }
</style>

<!-- Mobile Toggle Button (hidden on desktop) -->
<button class="sidebar-toggle d-lg-none">
    <i class="fas fa-bars"></i>
</button>

<!-- jQuery & AJAX for Sidebar Functionality -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(document).ready(function() {
    // Mobile sidebar toggle
    $('.sidebar-toggle').click(function() {
        $('.sidebar-nav').toggleClass('show');
    });
    
    // Live search functionality
    // Live search functionality
$('#liveSearchInput').keyup(function() {
    let query = $(this).val().trim();
    if (query.length === 0) {
        $('#liveSearchResults').hide().empty();
        return;
    }

    $.ajax({
        url: 'LiveSearchServlet',
        method: 'GET',
        data: { q: query },
        success: function(data) {
            const $results = $('#liveSearchResults');
            if ($.trim(data) === '') {
                $results.html('<div class="p-2 text-muted">No users found</div>');
            } else {
                $results.html(data);
            }
            $results.show();
        },
        error: function() {
            $('#liveSearchResults').html('<div class="p-2 text-danger">Error loading results</div>').show();
        }
    });
});

    // Hide dropdown when clicking outside
    $(document).click(function(e) {
        if (!$(e.target).closest('#liveSearchInput, #liveSearchResults').length) {
            $('#liveSearchResults').hide();
        }
    });

    // Notification functions
    function updateMessageBadge() {
        $.get('GetUnreadMessageCountServlet', function(count) {
            $('#messageBadge').text(parseInt(count) > 0 ? count : '');
        }).fail(function() {
            console.error("Failed to load unread message count");
        });
    }

    function updateNotificationBadge() {
        $.get('notifications?action=count', function(count) {
            $('#notificationBadge').text(parseInt(count) > 0 ? count : '');
        }).fail(function() {
            console.error("Failed to load notification count");
        });
    }

    function loadNotificationDropdown() {
        const $items = $('#notificationItems');
        $items.html('<div class="text-center py-2 text-muted">Loading...</div>');

        $.get('notifications?action=preview', function(data) {
            if ($.trim(data) === '') {
                $items.html('<div class="dropdown-item text-center text-muted py-2">No notifications</div>');
            } else {
                $items.html(data);
            }
        }).fail(function() {
            $items.html('<div class="dropdown-item text-center text-danger">Error loading notifications</div>');
        });
    }

    $(document).on('click', '.notification-item', function(e) {
        e.preventDefault();
        const notificationId = $(this).data('id');
        const targetUrl = $(this).attr('href');
        
        if (notificationId) {
            $.post('notifications', {
                action: 'markAsRead',
                id: notificationId
            }, function() {
                window.location.href = targetUrl;
            });
        }
    });

    // Initialize functions
    updateNotificationBadge();
    updateMessageBadge();
    setInterval(updateNotificationBadge, 30000);
    setInterval(updateMessageBadge, 30000);
    
    // Load notifications when collapse is shown
    $('#notificationsCollapse').on('show.bs.collapse', loadNotificationDropdown);
});
</script>
