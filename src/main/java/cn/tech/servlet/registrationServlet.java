package cn.tech.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import cn.tech.connection.DBCon;
import cn.tech.model.*;

@WebServlet("/register")
public class registrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public registrationServlet() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve form data
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Insert user into the database
        boolean success = registerUser(username, email, password);

        if (success) {
            // Registration successful, redirect to login page
            response.sendRedirect("login.jsp?register=success");
        } else {
            // Registration failed, redirect back with an error
            response.sendRedirect("registration.jsp?error=1");
        }
    }

    private boolean registerUser(String username, String email, String password) {
        String query = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";

        try (Connection conn = DBCon.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, username);
            pstmt.setString(2, email);
            pstmt.setString(3, password); // Storing plain text password (Not secure!)

            int rowsInserted = pstmt.executeUpdate();
            return rowsInserted > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
