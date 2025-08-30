package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import cn.tech.Dao.FollowDao;
import cn.tech.connection.DBCon;
import cn.tech.model.User;

/**
 * Servlet implementation class FollowersListServlet
 */
@WebServlet("/FollowersListServlet")
public class FollowersListServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));

        try (Connection con = DBCon.getConnection()) {
            FollowDao followDao = new FollowDao(con);
            List<User> followers = followDao.getFollowers(userId);
            List<User> following = followDao.getFollowing(userId);

            request.setAttribute("followers", followers);
            request.setAttribute("following", following);
            request.getRequestDispatcher("followers.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
