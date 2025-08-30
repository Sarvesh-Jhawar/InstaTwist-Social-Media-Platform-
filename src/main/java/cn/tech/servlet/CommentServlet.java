package cn.tech.servlet;

import cn.tech.Dao.CommentDao;
import cn.tech.Dao.NotificationDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Comment;
import cn.tech.model.User;
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
import java.util.List;

@WebServlet("/CommentServlet")
public class CommentServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    HttpSession session = request.getSession();
	    User user = (User) session.getAttribute("user");

	    if (user == null) {
	        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
	        return;
	    }

	    int postId = Integer.parseInt(request.getParameter("postId"));
	    String commentText = request.getParameter("comment");

	    Comment comment = new Comment();
	    comment.setUserId(user.getId());
	    comment.setPostId(postId);
	    comment.setContent(commentText);

	    CommentDao commentDao = new CommentDao();
	    boolean success = commentDao.saveComment(comment);

	    if (success) {
	        try {
	            int recipientId = commentDao.getPostOwnerId(postId);
	            int commentId = comment.getId(); // Retrieved during saveComment()

	            if (recipientId != user.getId()) {
	                NotificationDao.createCommentNotification(recipientId, user.getId(), user.getUsername(), postId, commentId);
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }


	    response.setContentType("text/plain");
	    PrintWriter out = response.getWriter();
	    if (success) {
	        try {
	            int recipientId = commentDao.getPostOwnerId(postId);
	            int commentId = comment.getId(); // retrieved ID

	            if (recipientId != user.getId()) {
	                NotificationDao.createCommentNotification(recipientId, user.getId(), user.getUsername(), postId, commentId);
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	        }

	        // fetch back the saved comment to get timestamp
	        Comment savedComment = commentDao.getCommentById(comment.getId());
	        if (savedComment != null) {
	            // send in a simple plain string separated by |
	            // username|createdAt|content
	            out.print(savedComment.getUsername() + "|" + savedComment.getCreatedAt() + "|" + savedComment.getContent());
	        } else {
	            out.print("Error");
	        }

	    } else {
	        out.print("Error");
	    }

	}

}
