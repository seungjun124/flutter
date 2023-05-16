<?php
$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "schoolDB";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$name = $_GET['name'];
$sql = "SELECT *, CONCAT(month, day) AS month_day FROM school_db WHERE name = '$name' ORDER BY month_day ASC;";
$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row; 
    }
}

echo json_encode($data); 

$conn->close();
?>

