<?php
// index.php - Main E-commerce Product Page
// Author: Muhammad Saif Rahman
// Purpose: Displays products from database with connection to VM2

// Database configuration (VM2)
define('DB_HOST', '192.168.56.11');  // VM2's IP
define('DB_USER', 'webuser');
define('DB_PASS', 'GadgetZone2024!');
define('DB_NAME', 'gadgetzone');

// Create connection
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($conn->connect_error) {
    error_log("DB Connection failed: " . $conn->connect_error);
    die(json_encode(['error' => 'Database connection failed']));
}

// Handle API requests
$action = $_GET['action'] ?? '';

if ($action === 'health') {
    echo json_encode(['status' => 'ok', 'database' => 'connected']);
    exit;
}

if ($action === 'products') {
    $result = $conn->query("SELECT id, name, price, stock, description FROM products WHERE stock > 0");
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
    echo json_encode($products);
    exit;
}

// HTML output for normal browsing
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GadgetZone - Tech Products</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #333; text-align: center; }
        .products { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .product { background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .product h3 { margin: 0 0 10px 0; color: #0066cc; }
        .price { font-size: 1.5em; color: #28a745; font-weight: bold; }
        .stock { color: #666; font-size: 0.9em; }
        .error { color: red; text-align: center; padding: 20px; }
        .footer { text-align: center; margin-top: 40px; padding: 20px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛒 GadgetZone</h1>
        <h2>Latest Tech Products</h2>
        <div class="products" id="products">
            <div class="error">Loading products...</div>
        </div>
        <div class="footer">
            <p>Secure Connection | High Availability Infrastructure</p>
            <p>Server: <?php echo gethostname(); ?> | Database: <?php echo DB_HOST; ?></p>
        </div>
    </div>

    <script>
        fetch('/?action=products')
            .then(response => response.json())
            .then(products => {
                const container = document.getElementById('products');
                if (products.error) {
                    container.innerHTML = `<div class="error">${products.error}</div>`;
                    return;
                }
                if (products.length === 0) {
                    container.innerHTML = '<div class="error">No products available</div>';
                    return;
                }
                container.innerHTML = products.map(p => `
                    <div class="product">
                        <h3>${escapeHtml(p.name)}</h3>
                        <div class="price">$${parseFloat(p.price).toFixed(2)}</div>
                        <div class="stock">📦 Stock: ${p.stock} units</div>
                        <div class="description">${escapeHtml(p.description || 'No description')}</div>
                    </div>
                `).join('');
            })
            .catch(error => {
                document.getElementById('products').innerHTML = '<div class="error">Failed to load products. Please try again.</div>';
            });
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>
<?php
$conn->close();
?>