<!DOCTYPE html>
<html>
<head><title>Database Test</title></head>
<body>
<h1>WordPress Database Connection Test</h1>
<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "mariadb_container";
$username = getenv("MYSQL_USER") ?: "root";
$password = getenv("MYSQL_PASSWORD") ?: "";
$dbname = getenv("MYSQL_DATABASE") ?: "mysql";

echo "<p>Connecting to: <strong>$servername</strong> as <strong>$username</strong></p>";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo "<p style='color:red;font-weight:bold'>❌ Connection failed: " . $conn->connect_error . "</p>";
} else {
    echo "<p style='color:green;font-weight:bold'>✅ Connected successfully to WordPress database</p>";
    echo "<p>Server version: " . $conn->server_info . "</p>";
    
    // Show tables
    $result = $conn->query("SHOW TABLES");
    echo "<p>Number of tables: " . $result->num_rows . "</p>";
    
    echo "<ul>";
    while ($row = $result->fetch_array()) {
        echo "<li>" . $row[0] . "</li>";
    }
    echo "</ul>";
    
    $conn->close();
}
?>
</body>
</html>
