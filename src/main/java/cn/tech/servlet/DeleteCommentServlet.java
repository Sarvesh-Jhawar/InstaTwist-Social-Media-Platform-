package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

import cn.tech.Dao.CommentDao;
import cn.tech.model.User;

/**
 * Servlet implementation class DeleteCommentServlet
 */
@WebServlet("/DeleteCommentServlet")
public class DeleteCommentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        if (loggedInUser == null) {
            out.print("error:not_logged_in");
            return;
        }

        try {
            int commentId = Integer.parseInt(request.getParameter("commentId"));
            CommentDao commentDao = new CommentDao();

            boolean isDeleted = commentDao.deleteComment(commentId, loggedInUser.getId());

            if (isDeleted) {
                out.print("success");
            } else {
                out.print("error:delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error:server_error");
        } finally {
            out.close();
        }
    }
}