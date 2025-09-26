-- Complete Blog System Database Schema
-- All tables with proper structure and relationships

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    profile_image VARCHAR(255) DEFAULT 'default-avatar.png',
    is_admin TINYINT(1) DEFAULT 0,
    is_banned TINYINT(1) DEFAULT 0,
    email_verified TINYINT(1) DEFAULT 0,
    verification_code VARCHAR(6),
    verification_expires TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- Blog posts table
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    keywords VARCHAR(500),
    featured_image VARCHAR(255),
    author_id INT,
    status ENUM('draft', 'published') DEFAULT 'draft',
    views INT DEFAULT 0,
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL,
    FULLTEXT(title, content, keywords),
    INDEX idx_status (status),
    INDEX idx_author (author_id),
    INDEX idx_created_at (created_at),
    INDEX idx_slug (slug)
);

-- Post likes table
CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
);

-- Post views table
CREATE TABLE IF NOT EXISTS post_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_post_user (post_id, user_id),
    INDEX idx_post_ip (post_id, ip_address),
    INDEX idx_created_at (created_at)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Chat messages table with pagination support
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Site statistics table
CREATE TABLE IF NOT EXISTS site_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE UNIQUE NOT NULL,
    visits INT DEFAULT 0,
    unique_visitors INT DEFAULT 0,
    page_views INT DEFAULT 0,
    INDEX idx_date (date)
);

-- Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
);

-- DDoS protection table
CREATE TABLE IF NOT EXISTS ddos_bans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL UNIQUE,
    ban_reason VARCHAR(255) DEFAULT 'DDoS Attack',
    banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ban_expires TIMESTAMP NULL,
    is_permanent TINYINT(1) DEFAULT 0,
    ban_count INT DEFAULT 1,
    INDEX idx_ip (ip_address),
    INDEX idx_expires (ban_expires)
);

-- Request tracking for DDoS protection
CREATE TABLE IF NOT EXISTS request_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    request_count INT DEFAULT 1,
    last_request TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_method VARCHAR(10) DEFAULT 'GET',
    user_agent TEXT,
    request_uri VARCHAR(255),
    INDEX idx_ip_time (ip_address, last_request)
);

-- Email verification codes table
CREATE TABLE IF NOT EXISTS email_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    code VARCHAR(6) NOT NULL,
    type ENUM('registration', 'password_reset') DEFAULT 'registration',
    expires_at TIMESTAMP NOT NULL,
    used TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_code (email, code),
    INDEX idx_expires (expires_at),
    INDEX idx_type (type)
);

-- Security logs table
CREATE TABLE IF NOT EXISTS security_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    description TEXT,
    user_agent TEXT,
    user_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ip_time (ip_address, created_at),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at)
);

-- Failed login attempts tracking
CREATE TABLE IF NOT EXISTS failed_logins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    username VARCHAR(100),
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_agent TEXT,
    INDEX idx_ip_time (ip_address, attempt_time),
    INDEX idx_username (username)
);

-- Session security table
CREATE TABLE IF NOT EXISTS secure_sessions (
    session_id VARCHAR(128) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
);

-- Triggers to update post counts automatically
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS update_post_likes_count 
AFTER INSERT ON post_likes 
FOR EACH ROW 
BEGIN 
    UPDATE posts SET likes = (SELECT COUNT(*) FROM post_likes WHERE post_id = NEW.post_id) WHERE id = NEW.post_id;
END$$

CREATE TRIGGER IF NOT EXISTS update_post_likes_count_delete 
AFTER DELETE ON post_likes 
FOR EACH ROW 
BEGIN 
    UPDATE posts SET likes = (SELECT COUNT(*) FROM post_likes WHERE post_id = OLD.post_id) WHERE id = OLD.post_id;
END$$

CREATE TRIGGER IF NOT EXISTS update_post_views_count 
AFTER INSERT ON post_views 
FOR EACH ROW 
BEGIN 
    UPDATE posts SET views = (SELECT COUNT(*) FROM post_views WHERE post_id = NEW.post_id) WHERE id = NEW.post_id;
END$$

DELIMITER ;

-- Insert admin user with specified credentials
INSERT INTO users (username, email, password, is_admin, email_verified) VALUES 
('admin', 'admin-sunatullo@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 1)
ON DUPLICATE KEY UPDATE 
    email = 'admin-sunatullo@gmail.com',
    is_admin = 1,
    email_verified = 1;

-- Sample data for testing
INSERT INTO posts (title, slug, content, keywords, author_id, status) VALUES 
('Welcome to Our Blog', 'welcome-to-our-blog', '<h2>Welcome to our amazing blog!</h2><p>This is a sample post to get you started. You can edit or delete this post and create your own content.</p><p>Our blog system supports:</p><ul><li>Rich text editing</li><li>Image uploads</li><li>Comments system</li><li>User management</li><li>And much more!</li></ul>', 'welcome, blog, sample', 1, 'published'),
('Getting Started Guide', 'getting-started-guide', '<h2>How to use this blog system</h2><p>This guide will help you understand all the features available in this blog system.</p><h3>For Users:</h3><ul><li>Register an account</li><li>Browse and read posts</li><li>Leave comments</li><li>Use the chat system</li></ul><h3>For Admins:</h3><ul><li>Create and manage posts</li><li>Manage users</li><li>Monitor security</li><li>View analytics</li></ul>', 'guide, tutorial, help', 1, 'published')
ON DUPLICATE KEY UPDATE title=title;

-- Sample chat messages
INSERT INTO chat_messages (user_id, message) VALUES 
(1, 'Welcome to our chat system! 👋'),
(1, 'Feel free to start conversations here.'),
(1, 'This chat supports real-time messaging and stores all messages.')
ON DUPLICATE KEY UPDATE message=message;