from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import get_db

app = FastAPI(title="Order Management API")


@app.post(
    "/orders/{order_id}/items",
    response_model=schemas.OrderItemResponse,
    status_code=status.HTTP_201_CREATED,
)
def add_item_to_order(
    order_id: int,
    payload: schemas.OrderItemCreate,
    db: Session = Depends(get_db),
):
    try:
        order_item = crud.add_product_to_order(
            db=db,
            order_id=order_id,
            product_id=payload.product_id,
            quantity=payload.quantity,
        )
    except crud.NotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
    except crud.OutOfStockError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc

    return order_item


@app.get("/health")
def healthcheck():
    return {"status": "ok"}
