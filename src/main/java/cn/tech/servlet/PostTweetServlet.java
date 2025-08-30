package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.Date;

import cn.tech.Dao.TweetDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Tweet;
import cn.tech.model.User;

/**
 * Servlet implementation class PostTweetServlet
 */
@WebServlet("/postTweet")
public class PostTweetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Date formatter for createdAt string
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Get current user from session
            User currentUser = (User) request.getSession().getAttribute("user");
            if (currentUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String content = request.getParameter("content").trim();
            String parentTweetIdStr = request.getParameter("parentTweetId");
            
            if (content == null || content.isEmpty()) {
                out.print("<div class='alert alert-danger'>Tweet cannot be empty!</div>");
                return;
            }

            if (content.length() > 280) {
                out.print("<div class='alert alert-danger'>Tweet exceeds 280 characters limit!</div>");
                return;
            }

            // Create and save tweet
            Tweet tweet = new Tweet();
            tweet.setUserId(currentUser.getId());
            tweet.setContent(content);
            tweet.setCreatedAt(dateFormat.format(new Date())); // Set as formatted string
            
            // Set parent tweet ID if this is a reply
            if (parentTweetIdStr != null && !parentTweetIdStr.isEmpty()) {
                try {
                    tweet.setParentTweetId(Integer.parseInt(parentTweetIdStr));
                } catch (NumberFormatException e) {
                    out.print("<div class='alert alert-danger'>Invalid parent tweet ID</div>");
                    return;
                }
            }
            
            TweetDao tweetDao = new TweetDao();
            boolean success = tweetDao.saveTweet(tweet);
            
            if (!success) {
                out.print("<div class='alert alert-danger'>Failed to save tweet</div>");
                return;
            }

            // Get the newly created tweet with full details
            Tweet newTweet = tweetDao.getLatestTweetByUser(currentUser.getId());
            if (newTweet == null) {
                out.print("<div class='alert alert-danger'>Failed to retrieve new tweet</div>");
                return;
            }

            // Generate HTML for the new tweet
            String tweetHtml = generateTweetHtml(newTweet, currentUser);
            out.print(tweetHtml);

        } catch (Exception e) {
            e.printStackTrace();
            out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        } finally {
            out.close();
        }
    }

    private String generateTweetHtml(Tweet tweet, User user) {
        StringBuilder html = new StringBuilder();
        
        // Start tweet card
        html.append("<div class='card tweet-card mb-3' id='tweet-").append(tweet.getTweetId()).append("'>")
           .append("<div class='card-body'>");
        
        // User info section
        html.append("<div class='tweet-header'>")
           .append("<div class='user-avatar' style='background: linear-gradient(135deg, #4361ee, #3f37c9);'>")
           .append(user.getUsername().charAt(0))
           .append("</div>")
           .append("<div class='flex-grow-1'>")
           .append("<div class='d-flex align-items-center'>")
           .append("<span class='tweet-user'>").append(user.getUsername()).append("</span>")
           .append("<span class='tweet-username'>@").append(user.getUsername().toLowerCase()).append("</span>")
           .append("<span class='tweet-time'>· ").append(formatDisplayTime(tweet.getCreatedAt())).append("</span>")
           .append("</div></div></div>");
        
        // Tweet content (with line breaks preserved)
        html.append("<div class='tweet-content'>")
           .append(tweet.getContent().replace("\n", "<br>"))
           .append("</div>");
        
        // Tweet actions
        html.append("<div class='tweet-actions'>")
           .append("<button class='tweet-action comment-btn' onclick='toggleCommentSection(this, ").append(tweet.getTweetId()).append(")'>")
           .append("<i class='far fa-comment'></i>")
           .append("<span class='action-count'>0</span>")
           .append("</button>")
           .append("<button class='tweet-action retweet-btn' data-tweet-id='").append(tweet.getTweetId())
           .append("' data-user-id='").append(user.getId()).append("' data-is-retweeted='false'>")
           .append("<i class='fas fa-retweet'></i>")
           .append("<span class='action-count'>0</span>")
           .append("</button>")
           .append("<button class='tweet-action like-btn' data-tweet-id='").append(tweet.getTweetId())
           .append("' data-user-id='").append(user.getId()).append("' data-is-liked='false'>")
           .append("<i class='far fa-heart'></i>")
           .append("<span class='action-count'>0</span>")
           .append("</button>")
           .append("</div>");
        
        // Comment section (initially hidden)
        html.append("<div class='comment-section' id='commentSection").append(tweet.getTweetId()).append("' style='display:none;'>")
           .append("<div id='commentsList").append(tweet.getTweetId()).append("'>")
           .append("<p class='text-muted'>No comments yet. Be the first to comment!</p>")
           .append("</div>")
           .append("<div class='comment-input-group'>")
           .append("<input type='text' class='form-control comment-input' placeholder='Write a comment...' id='commentInput").append(tweet.getTweetId()).append("'>")
           .append("<button class='btn btn-primary post-comment-btn mt-2' data-tweet-id='").append(tweet.getTweetId())
           .append("' data-user-id='").append(user.getId())
           .append("' data-username='").append(user.getUsername())
           .append("' data-user-avatar='").append(user.getUsername().charAt(0))
           .append("'><i class='fas fa-paper-plane mr-2'></i> Post Comment</button>")
           .append("</div></div>");
        
        // Close card
        html.append("</div></div>");
        
        return html.toString();
    }

    private String formatDisplayTime(String dbTime) {
        try {
            Date tweetDate = dateFormat.parse(dbTime);
            long diffInMillis = System.currentTimeMillis() - tweetDate.getTime();
            
            // Convert to different time units
            long diffInSeconds = diffInMillis / 1000;
            long diffInMinutes = diffInSeconds / 60;
            long diffInHours = diffInMinutes / 60;
            long diffInDays = diffInHours / 24;
            
            if (diffInDays > 30) {
                return new SimpleDateFormat("MMM d, yyyy").format(tweetDate);
            } else if (diffInDays > 0) {
                return diffInDays + (diffInDays == 1 ? " day ago" : " days ago");
            } else if (diffInHours > 0) {
                return diffInHours + (diffInHours == 1 ? " hour ago" : " hours ago");
            } else if (diffInMinutes > 0) {
                return diffInMinutes + (diffInMinutes == 1 ? " minute ago" : " minutes ago");
            } else {
                return "just now";
            }
        } catch (Exception e) {
            return dbTime; // fallback to raw string if parsing fails
        }
    }
}