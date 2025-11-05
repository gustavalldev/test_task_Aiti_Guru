from decimal import Decimal

from pydantic import BaseModel, conint


class OrderItemCreate(BaseModel):
    product_id: int
    quantity: conint(gt=0)


class ProductInfo(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


class OrderItemResponse(BaseModel):
    order_id: int
    product_id: int
    product: ProductInfo
    quantity: int
    price_at_order: Decimal

    class Config:
        from_attributes = True
