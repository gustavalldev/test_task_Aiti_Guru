-- ========================================
-- 1. Таблица категорий (дерево категорий)
-- ========================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL
);

-- Индекс для ускорения поиска по родителю
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

-- ========================================
-- 2. Таблица товаров (номенклатура)
-- ========================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL
);

CREATE INDEX idx_products_category_id ON products(category_id);

-- ========================================
-- 3. Таблица клиентов
-- ========================================
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT
);

-- ========================================
-- 4. Таблица заказов
-- ========================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_client_id ON orders(client_id);

-- ========================================
-- 5. Таблица позиций заказа (order_items)
-- ========================================
CREATE TABLE order_items (
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_order NUMERIC(10,2) NOT NULL CHECK (price_at_order >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_order_items_product_id ON order_items(product_id);


-- Уровень 1
INSERT INTO categories (name, parent_id) VALUES
('Бытовая техника', NULL),
('Компьютеры', NULL);

-- Уровень 2 (подкатегории для "Бытовая техника")
INSERT INTO categories (name, parent_id) VALUES
('Стиральные машины', 1),
('Холодильники', 1),
('Телевизоры', 1);

-- Уровень 3 (вложенные категории внутри "Холодильники")
INSERT INTO categories (name, parent_id) VALUES
('Однокамерные', 3),
('Двухкамерные', 3);

-- Уровень 2 (подкатегории для "Компьютеры")
INSERT INTO categories (name, parent_id) VALUES
('Ноутбуки', 2),
('Моноблоки', 2);

-- Уровень 3 (вложенные категории внутри "Ноутбуки")
INSERT INTO categories (name, parent_id) VALUES
('17"', 8),
('19"', 8);

-- ========================================
-- 📦 Товары (products)
-- ========================================
INSERT INTO products (name, price, quantity, category_id) VALUES
-- Бытовая техника
('Стиральная машина LG TurboWash', 45000, 5, 3),
('Стиральная машина Samsung EcoBubble', 52000, 3, 3),
('Холодильник Indesit DF 4180', 38000, 4, 4),
('Холодильник LG DoorCooling двухкамерный', 56000, 2, 7),
('Телевизор Samsung 43"', 42000, 6, 5),
('Телевизор LG OLED 55"', 79000, 3, 5),

-- Компьютеры / Ноутбуки
('Ноутбук HP 17" Pavilion', 61000, 5, 10),
('Ноутбук ASUS 19" ProBook', 72000, 2, 11),
('Моноблок Acer Aspire', 58000, 3, 9);

-- ========================================
-- 👤 Клиенты
-- ========================================
INSERT INTO clients (name, address) VALUES
('ООО Альфа', 'Москва, ул. Ленина, д. 10'),
('ИП Иванов Петр', 'Санкт-Петербург, пр. Невский, д. 25'),
('ООО Гамма', 'Казань, ул. Баумана, д. 5'),
('ООО Омега', 'Новосибирск, ул. Кирова, д. 42');

-- ========================================
-- 🧾 Заказы
-- ========================================
INSERT INTO orders (client_id, created_at) VALUES
(1, NOW() - INTERVAL '10 days'),
(2, NOW() - INTERVAL '5 days'),
(3, NOW() - INTERVAL '3 days'),
(4, NOW() - INTERVAL '1 day');

-- ========================================
-- 🛒 Позиции заказов (order_items)
-- ========================================

INSERT INTO order_items (order_id, product_id, quantity, price_at_order) VALUES
-- Заказ 1 (ООО Альфа)
(1, 1, 1, 45000),
(1, 3, 1, 38000),
(1, 5, 2, 42000),

-- Заказ 2 (ИП Иванов)
(2, 2, 1, 52000),
(2, 4, 1, 56000),
(2, 7, 1, 61000),

-- Заказ 3 (ООО Гамма)
(3, 6, 1, 79000),
(3, 8, 1, 72000),
(3, 9, 1, 58000),

-- Заказ 4 (ООО Омега)
(4, 7, 2, 61000),
(4, 1, 1, 45000),
(4, 5, 1, 42000);
