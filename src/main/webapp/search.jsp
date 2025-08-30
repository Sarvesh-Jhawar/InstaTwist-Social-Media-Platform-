<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, cn.tech.connection.DBCon" %>
<%
    String query = request.getParameter("query");
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
%>

<h3>Search Results for "<%= query %>"</h3>
<ul>
<%
try {
    con = DBCon.getConnection();
    String sql = "SELECT * FROM users WHERE username LIKE ?";
    pst = con.prepareStatement(sql);
    pst.setString(1, "%" + query + "%");
    rs = pst.executeQuery();

    boolean found = false;
    while (rs.next()) {
        found = true;
%>
    <li>
        <a href="user.jsp?userId=<%= rs.getInt("id") %>">
            <%= rs.getString("username") %>
        </a>
    </li>
<%
    }
    if (!found) {
%>
    <li>No users found matching "<%= query %>"</li>
<%
    }
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (pst != null) pst.close(); } catch (Exception ignored) {}
}
%>
</ul>
