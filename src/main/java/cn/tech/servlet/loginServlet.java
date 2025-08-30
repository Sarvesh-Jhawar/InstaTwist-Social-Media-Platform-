package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import cn.tech.connection.DBCon;
import cn.tech.model.User;

@WebServlet("/login")
public class loginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public loginServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect to login page if someone tries to access this servlet via GET
        response.sendRedirect("login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve form data
        String usernameOrEmail = request.getParameter("username");
        String password = request.getParameter("password");

        // Validate user credentials
        User user = validateUser(usernameOrEmail, password);

        if (user != null) {
            // Login successful
        	request.setAttribute("user", user);
            HttpSession session = request.getSession();
            session.setAttribute("user", user); // Store user object in session

            // Debug message
            System.out.println("Login successfully");

            // Redirect to home page
            response.sendRedirect("index.jsp");
        } else {
            // Login failed
            response.sendRedirect("login.jsp?error=1"); // Redirect to login page with error
        }
    }

    private User validateUser(String usernameOrEmail, String password) {
        User user = null;
        String query = "SELECT * FROM users WHERE username = ? OR email = ?";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, usernameOrEmail);
            pstmt.setString(2, usernameOrEmail);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Retrieve the plain text password from the database
                    String storedPassword = rs.getString("password");

                    // Compare the input password with the stored password
                    if (password.equals(storedPassword)) {
                        user = new User();
                        user.setId(rs.getInt("id"));
                        user.setUsername(rs.getString("username"));
                        user.setEmail(rs.getString("email"));
                        user.setCreatedAt(rs.getTimestamp("created_at")); // Set the created_at timestamp
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }
}
