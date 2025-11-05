-- ========================================
-- 2.1
-- ========================================
SELECT 
    c.name AS client_name,
    SUM(oi.quantity * oi.price_at_order) AS total_amount
FROM clients c
JOIN orders o ON c.id = o.client_id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY c.name
ORDER BY total_amount DESC;
-- ========================================
-- 2.2
-- ========================================
SELECT 
    parent.id AS category_id,
    parent.name AS category_name,
    COUNT(child.id) AS child_count
FROM categories parent
LEFT JOIN categories child ON child.parent_id = parent.id
GROUP BY parent.id, parent.name
ORDER BY parent.id;
-- ========================================
-- 2.3.1
-- ========================================
CREATE OR REPLACE VIEW top5_products_last_month AS
WITH RECURSIVE category_path AS (
    SELECT id, name, parent_id, name AS root_name
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.id, c.name, c.parent_id, cp.root_name
    FROM categories c
    JOIN category_path cp ON c.parent_id = cp.id
)
SELECT 
    p.name AS product_name,
    cp.root_name AS top_level_category,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN orders o ON o.id = oi.order_id
JOIN products p ON p.id = oi.product_id
JOIN category_path cp ON cp.id = p.category_id
WHERE o.created_at >= NOW() - INTERVAL '1 month'
GROUP BY p.name, cp.root_name
ORDER BY total_sold DESC
LIMIT 5;
SELECT * FROM top5_products_last_month;
-- ========================================
-- 2.3.2
-- ========================================

При росте объёма данных (1000 заказов в день) он может начать работать медленно из-за большого количества соединений и агрегаций. Основные узкие места - это JOIN-ы между orders, order_items и products, фильтрация по дате, а также рекурсивное построение категорий.
Для повышения производительности предлагаются следующие меры оптимизации:

1)Создание индексов:
CREATE INDEX idx_orders_created_at ON orders(created_at);
ускоряет фильтрацию по последнему месяцу.

CREATE INDEX idx_order_items_order_id ON order_items(order_id);

CREATE INDEX idx_order_items_product_id ON order_items(product_id);
ускоряют соединения между таблицами.

CREATE INDEX idx_products_category_id ON products(category_id);
ускоряет выборку категорий товаров.

2) Денормализация данных
Добавить в таблицу products поле root_category_id, чтобы хранить корневую категорию товара. Это позволит избавиться от рекурсивного запроса WITH RECURSIVE и ускорить агрегацию.

3)  Материализованное представление
Создать материализованный view, например mv_top_products_month, который хранит предварительно рассчитанные суммы продаж по месяцам. Представление можно обновлять раз в день:
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_products_month;
Таким образом, отчёт "Топ-5 товаров" будет строиться мгновенно из уже агрегированных данных.

4) Партиционирование таблиц
Для таблиц orders и order_items целесообразно реализовать секционирование по дате (по месяцам), чтобы при выборке последних данных PostgreSQL читал только актуальный раздел, а не всю таблицу.

5) Кэширование отчётов
Если отчёт используется часто (например, в админ-панели), результат запроса можно кэшировать в Redis или на уровне приложения и обновлять по расписанию.