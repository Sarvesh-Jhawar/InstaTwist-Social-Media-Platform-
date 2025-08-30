package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

import cn.tech.Dao.TweetCommentDao;
import cn.tech.model.TweetComment;

/**
 * Servlet implementation class GetCommentsServlet
 */
@WebServlet("/getComments")
public class GetCommentsServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int tweetId = Integer.parseInt(request.getParameter("tweetId"));
        TweetCommentDao dao = new TweetCommentDao();
        List<TweetComment> comments = dao.getCommentsForTweet(tweetId);
        System.out.println("GEtcomment");
        response.setContentType("text/html;charset=UTF-8");
        for (TweetComment comment : comments) {
            response.getWriter().write("<div class='d-flex mb-2'>"
                    + "<div class='user-avatar me-2' style='width: 30px; height: 30px; font-size: 12px;'>"
                    + comment.getUserId()
                    + "</div><div class='flex-grow-1'>"
                    + "<p class='mb-0'>" + comment.getComment() + "</p>"
                    + "</div></div>");
        }
    }
}
