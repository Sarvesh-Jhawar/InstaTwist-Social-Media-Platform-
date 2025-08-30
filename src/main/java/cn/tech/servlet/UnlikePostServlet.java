package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import cn.tech.Dao.LikeDao;
import cn.tech.model.User;

/**
 * Servlet implementation class UnlikePostServlet
 */
@WebServlet("/UnlikePostServlet")
public class UnlikePostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");

        if (loggedInUser == null) {
            out.print("error:User not logged in");
            return;
        }

        try {
            int postId = Integer.parseInt(request.getParameter("postId"));
            LikeDao likeDao = new LikeDao();

            // Check if user has liked the post
            if (!likeDao.checkIfLiked(postId, loggedInUser.getId())) {
                out.print("error:You haven't liked this post");
                return;
            }

            // Unlike the post
            likeDao.unlikePost(postId, loggedInUser.getId());
            
            // Get updated like count
            int newLikeCount = likeDao.getLikeCount(postId);
            out.print("success:" + newLikeCount);

        } catch (Exception e) {
            out.print("error:Failed to unlike post");
            e.printStackTrace();
        } finally {
            out.flush();
            out.close();
        }
    }
}