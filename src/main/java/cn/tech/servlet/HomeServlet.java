package cn.tech.servlet;

import cn.tech.Dao.PostDao;
import cn.tech.model.Post;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/posts")
public class HomeServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PostDao postDAO = new PostDao();
        List<Post> posts = postDAO.getAllPosts();
        
        request.setAttribute("posts", posts);
        request.getRequestDispatcher("home.jsp").forward(request, response);
    }
}
