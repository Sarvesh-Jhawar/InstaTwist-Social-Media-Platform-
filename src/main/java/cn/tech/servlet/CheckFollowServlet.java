package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;

import cn.tech.Dao.FollowDao;
import cn.tech.connection.DBCon;

/**
 * Servlet implementation class CheckFollowServlet
 */
@WebServlet("/CheckFollowServlet")
public class CheckFollowServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user"); // Logged-in user ID
        int followingId = Integer.parseInt(request.getParameter("followingId"));

        if (userId == null) {
            response.getWriter().write("NotLoggedIn");
            return;
        }

        try (Connection con = DBCon.getConnection()) {
            FollowDao followDao = new FollowDao(con);
            boolean isFollowing = followDao.isFollowing(userId, followingId);
            response.getWriter().write(isFollowing ? "Following" : "NotFollowing");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error");
        }
    }
}
