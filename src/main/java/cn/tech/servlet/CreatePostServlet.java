package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;

import cn.tech.Dao.PostDao;
import cn.tech.Dao.UserDao;
import cn.tech.model.Post;
import cn.tech.model.User;

/**
 * Servlet implementation class CreatePostServlet
 */
@WebServlet("/CreatePostServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1MB
    maxFileSize = 1024 * 1024 * 50,     // 50MB
    maxRequestSize = 1024 * 1024 * 60   // 60MB
)
public class CreatePostServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "post-images";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            User loggedInUser = (User) request.getSession().getAttribute("user");
            if (loggedInUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String content = request.getParameter("content");
            Part mediaPart = request.getPart("media");
            
            // Validate media is required (matches your frontend validation)
            if (mediaPart == null || mediaPart.getSize() == 0) {
                out.print("<div class='error'>Media is required</div>");
                return;
            }

            // Create upload directory if it doesn't exist
            String applicationPath = request.getServletContext().getRealPath("");
            String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadFilePath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Save the file with timestamp prefix
            String fileName = System.currentTimeMillis() + getFileExtension(mediaPart.getSubmittedFileName());
            mediaPart.write(uploadFilePath + File.separator + fileName);

            // Create and save post
            Post post = new Post();
            post.setUserId(loggedInUser.getId());
            post.setContent(content);
            post.setImagePath(fileName);
            post.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            post.setLikeCount(0);

            PostDao postDao = new PostDao();
            boolean success = postDao.createPost(post);

            if (success) {
                // Get updated user info (in case profile image changed)
                UserDao userDao = new UserDao();
                User updatedUser = userDao.getUserById(loggedInUser.getId());
                
                // Generate HTML for the new post (matches your frontend structure exactly)
                String postHtml = generatePostHtml(post, updatedUser);
                out.print(postHtml);
            } else {
                out.print("<div class='error'>Error creating post</div>");
            }
        } catch (Exception e) {
            out.print("<div class='error'>Error: " + e.getMessage() + "</div>");
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null) return "";
        int lastDot = fileName.lastIndexOf('.');
        return lastDot == -1 ? "" : fileName.substring(lastDot);
    }

    private String generatePostHtml(Post post, User user) {
        StringBuilder html = new StringBuilder();
        
        // Start post card (matches your frontend structure)
        html.append("<div class='card post-card'>")
           .append("<div class='card-body'>");
        
        // User info section
        html.append("<div class='user-info'>");
        if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) {
            html.append("<div class='avatar'>")
               .append("<img src='post-images/").append(user.getProfileImage()).append("' alt='").append(user.getUsername()).append("'>")
               .append("</div>");
        } else {
            html.append("<div class='avatar' style='background: linear-gradient(135deg, #4361ee, #3f37c9);'>")
               .append(user.getUsername().substring(0, 1).toUpperCase())
               .append("</div>");
        }
        html.append("<div class='user-info-content'>")
           .append("<h5><a href='user.jsp?userId=").append(user.getId()).append("' class='text-decoration-none'>").append(user.getUsername()).append("</a></h5>")
           .append("<small>").append(post.getCreatedAt()).append("</small>")
           .append("</div></div>");
        
        // Post content
        html.append("<div class='post-content'>")
           .append("<a href='post.jsp?postId=").append(post.getId()).append("' class='text-decoration-none text-dark'>")
           .append("<p>").append(post.getContent()).append("</p>");
        
        // Media content (matches your frontend preview structure)
        if (post.getImagePath() != null) {
            String fileExt = post.getImagePath().substring(post.getImagePath().lastIndexOf('.') + 1).toLowerCase();
            boolean isVideo = fileExt.matches("mp4|webm|ogg");
            
            html.append("<div class='post-image-container'>");
            if (isVideo) {
                html.append("<video controls class='post-image'>")
                   .append("<source src='post-images/").append(post.getImagePath()).append("' type='video/").append(fileExt).append("'>")
                   .append("Your browser does not support the video tag.")
                   .append("</video>");
            } else {
                html.append("<img src='post-images/").append(post.getImagePath()).append("' class='post-image' alt='Post image'>");
            }
            html.append("</div>");
        }
        html.append("</a></div></div>"); // Close post-content and card-body
        
        // Card footer with actions (matches your frontend exactly)
        html.append("<div class='card-footer'>")
           .append("<div class='post-actions'>")
           .append("<button class='btn btn-like' data-post-id='").append(post.getId()).append("'>")
           .append("<i class='fas fa-thumbs-up'></i> <span class='like-count'>").append(post.getLikeCount()).append("</span></button>")
           .append("<button class='btn btn-comment' onclick='toggleCommentSection(this)'>")
           .append("<i class='fas fa-comment'></i> <span class='d-none d-md-inline'>Comment</span></button>")
           .append("<button class='btn btn-share' onclick='openShareModal(").append(post.getId()).append(")'>")
           .append("<i class='fas fa-share'></i> <span class='d-none d-md-inline'>Share</span></button>")
           .append("</div>")
           .append("<div class='comment-section' style='display:none;'>")
           .append("<div class='comment-input-group mt-3'>")
           .append("<textarea class='form-control comment-textarea' placeholder='Write a comment...'></textarea>")
           .append("<button class='btn btn-primary post-comment-btn mt-2' data-post-id='").append(post.getId()).append("'>")
           .append("<i class='fas fa-paper-plane mr-2'></i> Post Comment</button>")
           .append("</div></div></div></div>"); // Close all divs
        
        return html.toString();
    }
}