from typing import Optional

from sqlalchemy.orm import Session

from . import models


class NotFoundError(Exception):
    pass


class OutOfStockError(Exception):
    pass


def get_order(db: Session, order_id: int) -> models.Order:
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if order is None:
        raise NotFoundError(f"Order {order_id} not found")
    return order


def get_product(db: Session, product_id: int) -> models.Product:
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if product is None:
        raise NotFoundError(f"Product {product_id} not found")
    return product


def get_order_item(db: Session, order_id: int, product_id: int) -> Optional[models.OrderItem]:
    return (
        db.query(models.OrderItem)
        .filter(
            models.OrderItem.order_id == order_id,
            models.OrderItem.product_id == product_id,
        )
        .first()
    )


def add_product_to_order(db: Session, order_id: int, product_id: int, quantity: int) -> models.OrderItem:
    order = get_order(db, order_id)
    product = get_product(db, product_id)

    order_item = get_order_item(db, order.id, product.id)

    if product.quantity < quantity:
        raise OutOfStockError(
            f"Not enough stock for product {product.id}. Available={product.quantity}, required={quantity}"
        )

    if order_item:
        order_item.quantity += quantity
    else:
        order_item = models.OrderItem(
            order_id=order.id,
            product_id=product.id,
            quantity=quantity,
            price_at_order=product.price,
        )
        db.add(order_item)

    product.quantity -= quantity

    db.commit()
    db.refresh(order_item)

    return order_item
