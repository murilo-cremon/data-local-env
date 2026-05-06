CREATE TABLE IF NOT EXISTS orders (
    id          SERIAL PRIMARY KEY,
    customer    VARCHAR(100) NOT NULL,
    product     VARCHAR(100) NOT NULL,
    quantity    INT          NOT NULL,
    unit_price  NUMERIC(10,2) NOT NULL,
    created_at  TIMESTAMP    DEFAULT NOW()
);

INSERT INTO orders (customer, product, quantity, unit_price) VALUES
    ('Alice',   'Notebook',  2, 3500.00),
    ('Bob',     'Mouse',     5,   89.90),
    ('Carol',   'Teclado',   3,  199.90),
    ('Dave',    'Monitor',   1, 1299.00),
    ('Eve',     'Headset',   2,  349.90);