package cn.tech.connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.concurrent.atomic.AtomicReference;

public class DBCon {
    private static final AtomicReference<Connection> connectionRef = new AtomicReference<>();
    private static final String URL = "jdbc:mysql://localhost:3306/social_media";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    static {
        try {
            // Load the MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Failed to load MySQL driver", e);
        }
    }

    public DBCon() {
        // Private constructor to prevent instantiation
    }

    public static Connection getConnection() throws SQLException {
        Connection connection = connectionRef.get();
        if (connection == null || connection.isClosed()) {
            synchronized (DBCon.class) {
                connection = connectionRef.get();
                if (connection == null || connection.isClosed()) {
                    connection = DriverManager.getConnection(URL, USER, PASSWORD);
                    connectionRef.set(connection);
                    System.out.println("Database connected successfully");
                }
            }
        }
        return connection;
    }

    public static void closeConnection() {
        Connection connection = connectionRef.get();
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Database connection closed");
            } catch (SQLException e) {
                System.err.println("Failed to close database connection: " + e.getMessage());
            } finally {
                connectionRef.set(null);
            }
        }
    }
}