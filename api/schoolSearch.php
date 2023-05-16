<?php
$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "schoolDB";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$searchTerm = $_GET['search'];

$sql = "SELECT DISTINCT name FROM school_DB WHERE name LIKE ?";
$stmt = $conn->prepare($sql);
$searchTerm = "%$searchTerm%";
$stmt->bind_param("s", $searchTerm);
$stmt->execute();
$result = $stmt->get_result();

$rows = array();
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}

$stmt->close();
$conn->close();

header('Content-Type: application/json');
echo json_encode($rows);
?>

