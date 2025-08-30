package cn.tech.servlet;

import cn.tech.Dao.MessageDao;
import cn.tech.Dao.PostDao;
import cn.tech.connection.DBCon;
import cn.tech.model.Message;
import cn.tech.model.Post;
import cn.tech.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;

import com.google.gson.Gson;  // Import Gson

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {
   /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {

	    HttpSession session = request.getSession();
	    User loggedInUser = (User) session.getAttribute("user");

	    if (loggedInUser == null) {
	        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
	        return;
	    }

	    try {
	        int receiverId = Integer.parseInt(request.getParameter("receiverId"));
	        int senderId = loggedInUser.getId();

	        MessageDao dao = new MessageDao();
	        PostDao dao2 = new PostDao();
	        List<Message> messages = dao.getMessagesBetweenUsers(senderId, receiverId);
	        dao.markMessagesAsRead(receiverId, senderId); // Mark as read after fetching messages

	        response.setContentType("text/html");
	        PrintWriter out = response.getWriter();

	        for (Message msg : messages) {
	            String senderClass = (msg.getSenderId() == senderId) ? "you" : "other";
	            out.println("<div class='message " + senderClass + "'>");

	            if (msg.getPostId() != 0) {
	                // Handle post sharing
	                // Fetch post content from PostDao (you can adjust the logic depending on your structure)
	                Post post = dao2.getPostById(msg.getPostId());

	                // Ensure the post content and image URL are valid
	                if (post != null) {
	                    out.println("<div class='shared-post'>");

	                    // Construct the full image URL by prepending '/images/' to the image name
	                    String imageUrl = "/images/" + post.getImagePath();  // Assuming post.getImageUrl() returns the image name
	                    
	                    // Display the image with the correct URL
	                    out.println("<img src='" + imageUrl + "' alt='Post Image' class='post-image' />");
	                    out.println("<div class='post-content'>" + post.getContent() + "</div>");
	                    out.println("</div>");
	                }
	            } else {
	                // Regular text message
	                out.println("<div class='message-content'>" + msg.getContent() + "</div>");
	            }

	            out.println("</div>");
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	    }
	}
}
