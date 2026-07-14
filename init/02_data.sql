INSERT INTO customers (full_name, email) VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com'),
    ('Carol Diaz', 'carol@example.com'),
    ('David Lee', 'david@example.com');

INSERT INTO products (name, category, price, stock) VALUES
    ('Wireless Mouse', 'Electronics', 19.99, 150),
    ('Mechanical Keyboard', 'Electronics', 79.99, 80),
    ('USB-C Hub', 'Electronics', 34.50, 200),
    ('Notebook', 'Stationery', 4.25, 500),
    ('Ceramic Mug', 'Home', 12.00, 300);

INSERT INTO orders (customer_id, status) VALUES
    (1, 'completed'),
    (1, 'pending'),
    (2, 'completed'),
    (3, 'shipped'),
    (4, 'cancelled');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 2, 19.99),
    (1, 4, 5, 4.25),
    (2, 2, 1, 79.99),
    (3, 3, 1, 34.50),
    (3, 5, 3, 12.00),
    (4, 1, 1, 19.99),
    (5, 4, 10, 4.25);
