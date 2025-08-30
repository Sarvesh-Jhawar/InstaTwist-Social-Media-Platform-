package cn.tech.servlet;

import cn.tech.Dao.FollowDao;
import cn.tech.connection.DBCon;
import cn.tech.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        FollowDao followDao = null;
		try {
			followDao = new FollowDao(DBCon.getConnection());
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        List<User> followingList = followDao.getFollowing(currentUser.getId());

        request.setAttribute("followingList", followingList);
        request.getRequestDispatcher("chat.jsp").forward(request, response);
    }
}
