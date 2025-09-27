<?php
// Database Auto Starter - Creates all required tables automatically
// Run this file to set up your complete blog database

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database configuration
$host = 'localhost';
$db_name = 'stacknro_blog';
$username = 'stacknro_blog';
$password = 'admin-2025';
$charset = 'utf8mb4';

echo "🚀 Starting Database Auto Setup...\n";
echo "=====================================\n";

try {
    // Create PDO connection
    $dsn = "mysql:host=$host;charset=$charset";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    
    $pdo = new PDO($dsn, $username, $password, $options);
    echo "✅ Connected to MySQL server\n";
    
    // Create database if not exists
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$db_name` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    echo "✅ Database '$db_name' created/verified\n";
    
    // Connect to the specific database
    $pdo->exec("USE `$db_name`");
    echo "✅ Using database '$db_name'\n";
    
    // Read SQL file
    $sqlFile = __DIR__ . '/../database/all.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("SQL file not found: $sqlFile");
    }
    
    $sql = file_get_contents($sqlFile);
    echo "✅ SQL file loaded successfully\n";
    
    // Split SQL into individual statements
    $statements = array_filter(
        array_map('trim', preg_split('/;(?=(?:[^\'"]|\'[^\']*\'|"[^"]*")*$)/', $sql)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^(--|\/\*)/', $stmt);
        }
    );
    
    echo "📊 Found " . count($statements) . " SQL statements to execute\n";
    echo "=====================================\n";
    
    $successCount = 0;
    $skipCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $statement) {
        try {
            $pdo->exec($statement);
            $successCount++;
            
            // Extract operation type for better logging
            if (preg_match('/CREATE TABLE.*?`?(\w+)`?/i', $statement, $matches)) {
                echo "✅ Created table: {$matches[1]}\n";
            } elseif (preg_match('/CREATE TRIGGER.*?`?(\w+)`?/i', $statement, $matches)) {
                echo "✅ Created trigger: {$matches[1]}\n";
            } elseif (preg_match('/INSERT INTO.*?`?(\w+)`?/i', $statement, $matches)) {
                echo "✅ Inserted data into: {$matches[1]}\n";
            } elseif (preg_match('/CREATE INDEX.*?`?(\w+)`?/i', $statement, $matches)) {
                echo "✅ Created index: {$matches[1]}\n";
            } else {
                echo "✅ Executed: " . substr($statement, 0, 50) . "...\n";
            }
            
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'already exists') !== false || 
                strpos($e->getMessage(), 'Duplicate entry') !== false) {
                $skipCount++;
                if (preg_match('/CREATE TABLE.*?`?(\w+)`?/i', $statement, $matches)) {
                    echo "ℹ️  Table already exists: {$matches[1]}\n";
                } else {
                    echo "ℹ️  Skipped (already exists): " . substr($statement, 0, 50) . "...\n";
                }
            } else {
                $errorCount++;
                echo "⚠️  Error: " . $e->getMessage() . "\n";
                echo "   Statement: " . substr($statement, 0, 100) . "...\n";
            }
        }
    }
    
    echo "=====================================\n";
    echo "🎉 Database setup completed!\n";
    echo "✅ Successful operations: $successCount\n";
    echo "ℹ️  Skipped (already exists): $skipCount\n";
    echo "⚠️  Errors: $errorCount\n";
    
    // Verify tables were created
    echo "\n🔍 Verifying database structure...\n";
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    
    $expectedTables = [
        'users', 'posts', 'post_likes', 'post_views', 'comments', 
        'chat_messages', 'site_stats', 'contact_messages', 'ddos_bans', 
        'request_tracking', 'email_verifications', 'security_logs', 
        'failed_logins', 'secure_sessions'
    ];
    
    $missingTables = array_diff($expectedTables, $tables);
    
    if (empty($missingTables)) {
        echo "✅ All required tables created successfully!\n";
    } else {
        echo "❌ Missing tables: " . implode(', ', $missingTables) . "\n";
    }
    
    echo "\n📊 Database Statistics:\n";
    foreach ($tables as $table) {
        try {
            $count = $pdo->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
            echo "   📋 $table: $count records\n";
        } catch (Exception $e) {
            echo "   ❌ $table: Error reading\n";
        }
    }
    
    // Test admin user
    echo "\n👤 Checking admin user...\n";
    $adminCheck = $pdo->query("SELECT username, email, is_admin FROM users WHERE is_admin = 1 LIMIT 1")->fetch();
    if ($adminCheck) {
        echo "✅ Admin user found: {$adminCheck['username']} ({$adminCheck['email']})\n";
        echo "🔑 Admin login: admin-blog / admin2025\n";
    } else {
        echo "⚠️  No admin user found\n";
    }
    
    echo "\n🎯 Setup complete! Your blog system is ready to use.\n";
    echo "🌐 You can now access:\n";
    echo "   - Main site: index.php\n";
    echo "   - Admin panel: panel.php\n";
    echo "   - Chat system: chat.php\n";
    
} catch (Exception $e) {
    echo "❌ Critical Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>