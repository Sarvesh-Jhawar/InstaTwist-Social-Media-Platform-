package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import cn.tech.Dao.PostDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Post;
import cn.tech.model.User;

/**
 * Servlet implementation class DeletePostServlet
 */
@WebServlet("/DeletePostServlet")
public class DeletePostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        try {
            User loggedInUser = (User) session.getAttribute("user");

            // Authentication check
            if (loggedInUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("error:Authentication required. Please login.");
                return;
            }

            // Validate postId parameter
            int postId;
            try {
                postId = Integer.parseInt(request.getParameter("postId"));
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("error:Invalid post ID format");
                return;
            }

            PostDao postDao = new PostDao();
            Post post = postDao.getPostById(postId);

            // Post existence check
            if (post == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("error:Post not found");
                return;
            }

            // Authorization check
            if (post.getUserId() != loggedInUser.getId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("error:Unauthorized - You can only delete your own posts");
                return;
            }

            // Transaction processing
            Connection conn = null;
            try {
                conn = DBCon.getConnection();
                conn.setAutoCommit(false);

                // Delete associated likes
                if (!deletePostLikes(conn, postId)) {
                    conn.rollback();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("error:Failed to delete post likes");
                    return;
                }

                // Delete associated comments
                if (!deletePostComments(conn, postId)) {
                    conn.rollback();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("error:Failed to delete post comments");
                    return;
                }

                // Delete the post
                boolean isPostDeleted = postDao.deletePost(postId, loggedInUser.getId(), conn);
                if (!isPostDeleted) {
                    conn.rollback();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("error:Failed to delete post");
                    return;
                }

                conn.commit();
                out.print("success:Post deleted successfully");

            } catch (SQLException e) {
                try {
                    if (conn != null) conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("error:Database error occurred");
            } finally {
                try {
                    if (conn != null) conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("error:Server error occurred");
        } finally {
            out.flush();
            out.close();
        }
    }

    // ... rest of your servlet methods ...

    private boolean deletePostLikes(Connection conn, int postId) throws SQLException {
        String query = "DELETE FROM likes WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            int rows = pstmt.executeUpdate();
            System.out.println("DEBUG: Likes deleted = " + rows);
            return rows >= 0;
        }
    }

    private boolean deletePostComments(Connection conn, int postId) throws SQLException {
        String query = "DELETE FROM comments WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, postId);
            int rows = pstmt.executeUpdate();
            System.out.println("DEBUG: Comments deleted = " + rows);
            return rows >= 0;
        }
    }
}