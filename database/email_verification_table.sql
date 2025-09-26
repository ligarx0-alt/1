-- Email verification table for registration and password reset
CREATE TABLE IF NOT EXISTS email_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    code_type ENUM('registration', 'password_reset') NOT NULL DEFAULT 'registration',
    expires_at DATETIME NOT NULL,
    is_used TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_code (email, verification_code),
    INDEX idx_expires (expires_at),
    INDEX idx_type (code_type)
);
