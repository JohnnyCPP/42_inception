<?php
$servername = "mariadb_container";
$username = getenv("MYSQL_USER") ?: "root";
$password = getenv("MYSQL_PASSWORD") ?: "";
$dbname = getenv("MYSQL_DATABASE") ?: "mysql";

// create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to WordPress database";
$conn->close();
?>
