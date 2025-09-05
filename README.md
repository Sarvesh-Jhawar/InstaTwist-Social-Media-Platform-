# InstaTwist Social Media Platform

InstaTwist is a social media platform that allows users to connect, share, and interact with posts and tweets. The application is built using Java Servlets, JSP, and a MySQL database.

## Features

* **User Management:** Register, log in, and manage your profile.
* **Posts and Tweets:** Share text-based posts or tweets. The platform supports uploading images and videos with posts.
* **Likes and Comments:** Users can like and comment on both posts and tweets to engage with content.
* **Following System:** Follow other users to see their content on your feed and engage in private conversations.
* **Private Messaging:** Send private messages to users you follow. Messages can also include shared posts or tweets.
* **Notifications:** Receive notifications for new likes, comments, and followers.
* **Live Search:** Find other users quickly with a live search feature integrated into the navigation bar.

---

## Technologies Used

* **Backend:** Java, Jakarta Servlet (version 5.0.0)
* **Frontend:** JavaServer Pages (JSP), HTML5, CSS3, JavaScript
* **Database:** MySQL
* **Build Tool:** Apache Maven
* **Libraries:**
    * MySQL Connector/J (version 8.0.22)
    * JSTL (version 1.2 / 2.0.0)
    * Gson (version 2.12.0) for JSON handling

---

## Setup and Installation

### Prerequisites

* Java Development Kit (JDK) version 17 or higher
* Apache Maven (version 3.8.1 or higher)
* MySQL Server
* An application server like Apache Tomcat (version 10.0 or compatible with Jakarta EE 9/10)

### Database Setup

1.  Log in to your MySQL server.
2.  Create a database named `social_media`.
    ```sql
    CREATE DATABASE social_media;
    USE social_media;
    ```
3.  Execute the following SQL commands to create the necessary tables. This schema is derived from the SQL queries found throughout the DAO classes in the project.

    ```sql
    -- Table for users
    CREATE TABLE users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        profile_pic VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Table for posts
    CREATE TABLE posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        content TEXT,
        image_path VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for likes on posts
    CREATE TABLE likes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        post_id INT NOT NULL,
        user_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for comments on posts
    CREATE TABLE comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        post_id INT NOT NULL,
        user_id INT NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for followers
    CREATE TABLE followers (
        follower_id INT NOT NULL,
        following_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (follower_id, following_id),
        FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for private messages
    CREATE TABLE messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        receiver_id INT NOT NULL,
        content TEXT,
        post_id INT DEFAULT 0,
        tweet_id INT DEFAULT 0,
        profile_id INT DEFAULT 0,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for notifications
    CREATE TABLE notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        recipient_id INT NOT NULL,
        sender_id INT NOT NULL,
        sender_name VARCHAR(255),
        sender_profile_pic VARCHAR(255),
        type VARCHAR(50) NOT NULL,
        post_id INT,
        comment_id INT,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for tweets
    CREATE TABLE tweets (
        tweet_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        content VARCHAR(280) NOT NULL,
        parent_tweet_id INT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for likes on tweets
    CREATE TABLE tweet_likes (
        like_id INT AUTO_INCREMENT PRIMARY KEY,
        tweet_id INT NOT NULL,
        user_id INT NOT NULL,
        liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for comments on tweets
    CREATE TABLE tweet_comments (
        comment_id INT AUTO_INCREMENT PRIMARY KEY,
        tweet_id INT NOT NULL,
        user_id INT NOT NULL,
        comment TEXT NOT NULL,
        commented_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Table for shares of tweets
    CREATE TABLE tweet_shares (
        share_id INT AUTO_INCREMENT PRIMARY KEY,
        tweet_id INT NOT NULL,
        user_id INT NOT NULL,
        shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    ```

---

### Project Setup and Deployment

1.  **Clone the repository.**
2.  Navigate to the project directory and build the application using Maven:
    ```bash
    mvn clean install
    ```
    This command compiles the project and packages it as a `.war` file in the `target/` directory.
3.  Deploy the generated `social-media.war` file to your Tomcat server's `webapps` directory.
4.  Start your Tomcat server.
5.  Access the application by navigating to `http://localhost:8080/social-media` in your web browser.
