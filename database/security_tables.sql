-- Added additional security tables for enhanced logging and tracking

-- Enhanced request tracking table
ALTER TABLE request_tracking ADD COLUMN IF NOT EXISTS request_method VARCHAR(10) DEFAULT 'GET';
ALTER TABLE request_tracking ADD COLUMN IF NOT EXISTS user_agent TEXT;
ALTER TABLE request_tracking ADD COLUMN IF NOT EXISTS request_uri VARCHAR(255);

-- Enhanced DDoS bans table
ALTER TABLE ddos_bans ADD COLUMN IF NOT EXISTS ban_count INT DEFAULT 1;
ALTER TABLE ddos_bans ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Security logs table for comprehensive logging
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
