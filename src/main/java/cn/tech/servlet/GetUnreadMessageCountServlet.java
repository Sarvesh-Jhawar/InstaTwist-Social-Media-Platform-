package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import cn.tech.Dao.MessageDao;
import cn.tech.model.User;

/**
 * Servlet implementation class GetUnreadMessageCountServlet
 */
@WebServlet("/GetUnreadMessageCountServlet")
public class GetUnreadMessageCountServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        MessageDao dao = new MessageDao();
        int unreadCount = dao.getUnreadMessageCount(user.getId());

        response.setContentType("text/plain");
        response.getWriter().write(String.valueOf(unreadCount));
    }
}
