-- Complete Blog System Database Schema
-- All tables with proper structure and relationships

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    profile_image VARCHAR(255) DEFAULT 'default-avatar.jpg',
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

-- Insert admin user with specified credentials
INSERT INTO users (username, email, password, is_admin, email_verified, verification_code) VALUES 
('admin', 'admin-sunatullo@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 1, NULL)
ON DUPLICATE KEY UPDATE 
    email = 'admin-sunatullo@gmail.com',
    is_admin = 1,
    email_verified = 1,
    verification_code = NULL;

-- Sample data for testing with beautiful post
INSERT INTO posts (title, slug, content, keywords, author_id, status) VALUES 
('🚀 Complete Web Development Guide 2025', 'complete-web-development-guide-2025', 
'<div style="text-align: center; margin-bottom: 2rem;">
    <img src="https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1" alt="Web Development" style="width: 100%; max-width: 800px; border-radius: 12px; box-shadow: 0 8px 25px rgba(0,0,0,0.1);">
</div>

<h2 style="color: #667eea; margin-bottom: 1.5rem;">🎯 Introduction</h2>
<p style="font-size: 1.1rem; line-height: 1.8; color: #334155;">Welcome to the most comprehensive web development guide for 2025! This tutorial will take you from beginner to advanced level, covering all the essential technologies and best practices.</p>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">📚 What You''ll Learn</h3>
<ul style="font-size: 1.05rem; line-height: 1.7; color: #475569;">
    <li>Modern HTML5 and CSS3 techniques</li>
    <li>JavaScript ES6+ features and frameworks</li>
    <li>Responsive design principles</li>
    <li>Backend development with PHP/Node.js</li>
    <li>Database design and optimization</li>
</ul>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">💻 Code Example</h3>
<pre style="background: linear-gradient(145deg, #1e293b, #334155); color: #e2e8f0; padding: 24px; border-radius: 12px; overflow-x: auto; margin: 2rem 0; box-shadow: 0 8px 25px rgba(0,0,0,0.2);"><code>// Modern JavaScript Example
const fetchUserData = async (userId) => {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const userData = await response.json();
        
        return {
            success: true,
            data: userData
        };
    } catch (error) {
        console.error("Error fetching user:", error);
        return {
            success: false,
            error: error.message
        };
    }
};

// Usage
fetchUserData(123).then(result => {
    if (result.success) {
        console.log("User data:", result.data);
    }
});</code></pre>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">🎥 Tutorial Video</h3>
<div style="position: relative; width: 100%; height: 0; padding-bottom: 56.25%; margin: 2rem 0; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 25px rgba(0,0,0,0.1);">
    <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" 
            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none;" 
            allowfullscreen></iframe>
</div>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">🔧 Tools and Resources</h3>
<p style="font-size: 1.05rem; line-height: 1.7; color: #475569;">Here are some essential tools every web developer should know:</p>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin: 2rem 0;">
    <div style="background: linear-gradient(145deg, #f8fafc, #e2e8f0); padding: 1.5rem; border-radius: 12px; border: 1px solid rgba(102, 126, 234, 0.1);">
        <h4 style="color: #667eea; margin-bottom: 0.5rem;">🎨 Design Tools</h4>
        <p style="color: #64748b; font-size: 0.95rem;">Figma, Adobe XD, Sketch</p>
    </div>
    <div style="background: linear-gradient(145deg, #f8fafc, #e2e8f0); padding: 1.5rem; border-radius: 12px; border: 1px solid rgba(102, 126, 234, 0.1);">
        <h4 style="color: #667eea; margin-bottom: 0.5rem;">⚡ Development</h4>
        <p style="color: #64748b; font-size: 0.95rem;">VS Code, Git, Docker</p>
    </div>
</div>

<blockquote style="border-left: 4px solid #667eea; padding: 20px 24px; margin: 2rem 0; background: linear-gradient(145deg, #f8fafc, #f1f5f9); border-radius: 0 12px 12px 0; font-style: italic; color: #475569; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
    "The best way to learn web development is by building real projects. Start small, think big, and never stop learning!" - Web Dev Expert
</blockquote>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">📥 Download Resources</h3>
<p style="font-size: 1.05rem; line-height: 1.7; color: #475569; margin-bottom: 1.5rem;">Get access to exclusive resources, code examples, and project files:</p>

<div id="downloadSection" style="text-align: center; padding: 2rem; background: linear-gradient(145deg, #667eea, #764ba2); border-radius: 16px; color: white; margin: 2rem 0;">
    <h4 style="margin-bottom: 1rem;">🎁 Free Resource Pack</h4>
    <p style="margin-bottom: 1.5rem; opacity: 0.9;">Complete source code, templates, and bonus materials</p>
    <button id="downloadBtn" onclick="startDownload()" style="background: rgba(255,255,255,0.2); color: white; border: 2px solid rgba(255,255,255,0.3); padding: 12px 24px; border-radius: 25px; font-size: 1.1rem; font-weight: 600; cursor: pointer; transition: all 0.3s ease;">
        📥 Download Now (Free)
    </button>
    <div id="countdown" style="display: none; margin-top: 1rem;">
        <p>Please wait <span id="timer">10</span> seconds...</p>
        <div style="width: 100%; background: rgba(255,255,255,0.2); border-radius: 10px; margin: 1rem 0;">
            <div id="progressBar" style="width: 0%; height: 8px; background: white; border-radius: 10px; transition: width 0.1s ease;"></div>
        </div>
        <button id="continueBtn" onclick="window.open(''https://github.com/example/web-dev-resources'', ''_blank'')" style="display: none; background: rgba(255,255,255,0.9); color: #667eea; border: none; padding: 12px 24px; border-radius: 25px; font-size: 1.1rem; font-weight: 600; cursor: pointer;">
            🚀 Continue to Download
        </button>
    </div>
</div>

<script>
function startDownload() {
    document.getElementById(''downloadBtn'').style.display = ''none'';
    document.getElementById(''countdown'').style.display = ''block'';
    
    let timeLeft = 10;
    const timer = document.getElementById(''timer'');
    const progressBar = document.getElementById(''progressBar'');
    const continueBtn = document.getElementById(''continueBtn'');
    
    const countdown = setInterval(() => {
        timeLeft--;
        timer.textContent = timeLeft;
        progressBar.style.width = ((10 - timeLeft) / 10 * 100) + ''%'';
        
        if (timeLeft <= 0) {
            clearInterval(countdown);
            document.getElementById(''countdown'').innerHTML = ''<p style="color: #4ade80; font-weight: 600;">✅ Ready to download!</p>'';
            continueBtn.style.display = ''inline-block'';
        }
    }, 1000);
}
</script>

<h3 style="color: #764ba2; margin: 2rem 0 1rem;">🎯 Conclusion</h3>
<p style="font-size: 1.1rem; line-height: 1.8; color: #334155;">Web development is an exciting journey filled with continuous learning and growth. With the right tools, resources, and dedication, you can build amazing web applications that make a real impact.</p>

<div style="background: linear-gradient(145deg, #f0f9ff, #e0f2fe); padding: 2rem; border-radius: 16px; margin: 2rem 0; border: 1px solid rgba(14, 165, 233, 0.2);">
    <h4 style="color: #0369a1; margin-bottom: 1rem;">💡 Pro Tip</h4>
    <p style="color: #0c4a6e; margin: 0;">Join our community of developers and get access to exclusive tutorials, code reviews, and career guidance. Follow us on social media for daily tips and updates!</p>
</div>', 
'web development, programming, javascript, html, css, tutorial, 2025, guide, coding, frontend, backend', 1, 'published'),

('Getting Started with Our Blog', 'getting-started-guide', 
'<h2>Welcome to Our Amazing Blog Platform!</h2>
<p>This is your complete guide to using all the features of our blog system.</p>
<h3>For Users:</h3>
<ul>
    <li>Create an account and verify your email</li>
    <li>Browse and read amazing posts</li>
    <li>Leave comments and engage with the community</li>
    <li>Use our real-time chat system</li>
</ul>
<h3>For Admins:</h3>
<ul>
    <li>Create and manage posts with rich content</li>
    <li>Manage users and moderate content</li>
    <li>Monitor security and view analytics</li>
    <li>Access advanced admin features</li>
</ul>', 
'guide, tutorial, help, blog, getting started', 1, 'published')
ON DUPLICATE KEY UPDATE title=title;

-- Sample chat messages
INSERT INTO chat_messages (user_id, message) VALUES 
(1, 'Welcome to our amazing chat system! 👋'),
(1, 'Feel free to start conversations here and connect with other users.'),
(1, 'This chat supports real-time messaging with infinite scroll - try it out!')
ON DUPLICATE KEY UPDATE message=message;