from datetime import datetime, timedelta
from decimal import Decimal

from .database import Base, SessionLocal, engine
from . import models


def seed():
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        if db.query(models.Category).count() > 0:
            return

        categories = {}

        def add_category(name, parent_name=None):
            parent = categories.get(parent_name)
            category = models.Category(name=name, parent=parent)
            db.add(category)
            db.flush()
            categories[name] = category

        add_category("Бытовая техника")
        add_category("Компьютеры")
        add_category("Стиральные машины", "Бытовая техника")
        add_category("Холодильники", "Бытовая техника")
        add_category("Телевизоры", "Бытовая техника")
        add_category("Однокамерные", "Холодильники")
        add_category("Двухкамерные", "Холодильники")
        add_category("Ноутбуки", "Компьютеры")
        add_category("Моноблоки", "Компьютеры")
        add_category('17"', "Ноутбуки")
        add_category('19"', "Ноутбуки")

        products = {}
        products_data = [
            ("Стиральная машина LG TurboWash", Decimal("45000"), 5, "Стиральные машины"),
            ("Стиральная машина Samsung EcoBubble", Decimal("52000"), 3, "Стиральные машины"),
            ("Холодильник Indesit DF 4180", Decimal("38000"), 4, "Однокамерные"),
            ("Холодильник LG DoorCooling двухкамерный", Decimal("56000"), 2, "Двухкамерные"),
            ('Телевизор Samsung 43"', Decimal("42000"), 6, "Телевизоры"),
            ('Телевизор LG OLED 55"', Decimal("79000"), 3, "Телевизоры"),
            ('Ноутбук HP 17" Pavilion', Decimal("61000"), 5, '17"'),
            ('Ноутбук ASUS 19" ProBook', Decimal("72000"), 2, '19"'),
            ("Моноблок Acer Aspire", Decimal("58000"), 3, "Моноблоки"),
        ]

        for name, price, quantity, category_name in products_data:
            product = models.Product(
                name=name,
                price=price,
                quantity=quantity,
                category=categories[category_name],
            )
            db.add(product)
            db.flush()
            products[name] = product

        clients = {}
        clients_data = [
            ("ООО Альфа", "Москва, ул. Ленина, д. 10"),
            ("ИП Иванов Петр", "Санкт-Петербург, пр. Невский, д. 25"),
            ("ООО Гамма", "Казань, ул. Баумана, д. 5"),
            ("ООО Омега", "Новосибирск, ул. Кирова, д. 42"),
        ]

        for name, address in clients_data:
            client = models.Client(name=name, address=address)
            db.add(client)
            db.flush()
            clients[name] = client

        orders = {}
        now = datetime.utcnow()
        orders_data = [
            ("ООО Альфа", now - timedelta(days=10)),
            ("ИП Иванов Петр", now - timedelta(days=5)),
            ("ООО Гамма", now - timedelta(days=3)),
            ("ООО Омега", now - timedelta(days=1)),
        ]

        for client_name, created_at in orders_data:
            order = models.Order(client=clients[client_name], created_at=created_at)
            db.add(order)
            db.flush()
            orders[client_name] = order

        order_items_data = [
            (orders["ООО Альфа"], products["Стиральная машина LG TurboWash"], 1, Decimal("45000")),
            (orders["ООО Альфа"], products["Холодильник Indesit DF 4180"], 1, Decimal("38000")),
            (orders["ООО Альфа"], products['Телевизор Samsung 43"'], 2, Decimal("42000")),
            (orders["ИП Иванов Петр"], products["Стиральная машина Samsung EcoBubble"], 1, Decimal("52000")),
            (orders["ИП Иванов Петр"], products["Холодильник LG DoorCooling двухкамерный"], 1, Decimal("56000")),
            (orders["ИП Иванов Петр"], products['Ноутбук HP 17" Pavilion'], 1, Decimal("61000")),
            (orders["ООО Гамма"], products['Телевизор LG OLED 55"'], 1, Decimal("79000")),
            (orders["ООО Гамма"], products['Ноутбук ASUS 19" ProBook'], 1, Decimal("72000")),
            (orders["ООО Гамма"], products["Моноблок Acer Aspire"], 1, Decimal("58000")),
            (orders["ООО Омега"], products['Ноутбук HP 17" Pavilion'], 2, Decimal("61000")),
            (orders["ООО Омега"], products["Стиральная машина LG TurboWash"], 1, Decimal("45000")),
            (orders["ООО Омега"], products['Телевизор Samsung 43"'], 1, Decimal("42000")),
        ]

        for order, product, qty, price in order_items_data:
            item = models.OrderItem(
                order=order,
                product=product,
                quantity=qty,
                price_at_order=price,
            )
            db.add(item)
            product.quantity = max(product.quantity - qty, 0)

        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    seed()
