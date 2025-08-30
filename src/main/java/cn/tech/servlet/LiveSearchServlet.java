package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import cn.tech.model.User;
import cn.tech.Dao.UserDao;

/**
 * Servlet implementation class LiveSearchServlet
 */
@WebServlet("/LiveSearchServlet")
public class LiveSearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("LiveSearchServlet: Received a request");

        String query = request.getParameter("q");
        System.out.println("Query parameter: " + query);

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (query != null && !query.trim().isEmpty()) {
            UserDao userDAO = new UserDao();
            System.out.println("Searching users with query: " + query.trim());

            List<User> matchedUsers = userDAO.searchUsersByNameOrUsername(query.trim());
            System.out.println("Matched users count: " + matchedUsers.size());

            if (matchedUsers.isEmpty()) {
                System.out.println("No users found");
                out.println("<div class='dropdown-item text-muted'>No users found</div>");
            } else {
                for (User user : matchedUsers) {
                    System.out.println("User found: " + user.getUsername() + " (" + user.getId() + ")");
                    
                    // Get the first letter of the username
                    String firstLetter = user.getUsername().substring(0, 1).toUpperCase();
                    
                    out.println("<a href='user.jsp?userId=" + user.getId() + "' class='dropdown-item d-flex align-items-center'>");

                    // Always include the fallback avatar
                    out.println("<div class='avatar-fallback-sm rounded-circle me-2'>" + firstLetter + "</div>");
                    
                    // If profile image exists, add it with an onerror handler
                    if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) {
                        out.println("<img src='post-images/" + user.getProfileImage() + "' " +
                                  "class='rounded-circle me-2' width='30' height='30' " +
                                  "style='display:none;' " +
                                  "onload=\"this.style.display='inline-block'; " +
                                  "this.previousElementSibling.style.display='none'\"/>");
                    }

                    out.println("<span>" + user.getUsername() + "</span>");
                    out.println("</a>");
                }
            }
        } else {
            System.out.println("Query is null or empty");
        }
    }
}