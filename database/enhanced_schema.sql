-- Enhanced Blog System Database Schema with Likes, Views, and Email Verification
-- Run this script to add new tables and features

-- Post likes table
CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (post_id, user_id)
);

-- Post views table (track which users viewed which posts)
CREATE TABLE IF NOT EXISTS post_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_view (post_id, user_id)
);

-- Email verification table
CREATE TABLE IF NOT EXISTS email_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    code_type ENUM('registration', 'password_reset') NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_code (email, verification_code),
    INDEX idx_expires (expires_at)
);

-- Add email_verified column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified TINYINT(1) DEFAULT 0;

-- Add likes_count and views_count to posts table for performance
ALTER TABLE posts ADD COLUMN IF NOT EXISTS likes_count INT DEFAULT 0;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS views_count INT DEFAULT 0;

-- Update existing posts with current counts
UPDATE posts SET 
    likes_count = (SELECT COUNT(*) FROM post_likes WHERE post_likes.post_id = posts.id),
    views_count = (SELECT COUNT(*) FROM post_views WHERE post_views.post_id = posts.id);

-- Create triggers to automatically update counts
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS update_likes_count_insert 
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
END$$

CREATE TRIGGER IF NOT EXISTS update_likes_count_delete 
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
END$$

CREATE TRIGGER IF NOT EXISTS update_views_count_insert 
AFTER INSERT ON post_views
FOR EACH ROW
BEGIN
    UPDATE posts SET views_count = views_count + 1 WHERE id = NEW.post_id;
END$$

DELIMITER ;
