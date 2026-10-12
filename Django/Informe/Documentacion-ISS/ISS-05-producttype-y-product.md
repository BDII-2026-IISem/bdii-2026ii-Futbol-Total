# ISS-05 - ProductType y Product

> **Referencia PedalLibre.** Catálogo operacional: stations, docking_points, bicycles y rates; no existen productos. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


## Objetivo

Modelar el catálogo y la integridad `ProductType 1 -> N Product`.

## Requisitos

- ISS-04 superado.
- Eliminar un tipo referenciado debe restringirse.

## Construcción

Reescriba `apps/product/models.py`. No hay marca, stock mínimo ni cantidad: no pertenecen al diccionario StoreLab.

```python
from decimal import Decimal

from django.core.validators import MinLengthValidator, MinValueValidator
from django.db import models

from apps.common.models import StoreLabModel


class ProductType(StoreLabModel):
    name = models.CharField(max_length=100, unique=True, validators=[MinLengthValidator(2)])
    description = models.CharField(max_length=255, null=True, blank=True)

    class Meta:
        db_table = "product_types"
        verbose_name = "tipo de producto"
        verbose_name_plural = "tipos de producto"
        ordering = ["name", "id"]
        constraints = [StoreLabModel.status_constraint("product_types_status_valid")]

    def __str__(self):
        return self.name


class Product(StoreLabModel):
    product_type = models.ForeignKey(
        ProductType,
        on_delete=models.RESTRICT,
        related_name="products",
        db_column="product_type_id",
    )
    name = models.CharField(max_length=120, unique=True, validators=[MinLengthValidator(2)])
    description = models.CharField(max_length=255, null=True, blank=True)
    price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0"))],
    )
    stock = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = "products"
        verbose_name = "producto"
        verbose_name_plural = "productos"
        ordering = ["name", "id"]
        constraints = [
            StoreLabModel.status_constraint("products_status_valid"),
            models.CheckConstraint(condition=models.Q(price__gte=0), name="product_price_non_neg"),
        ]

    def __str__(self):
        return self.name
```

```bash
python manage.py makemigrations product
python manage.py migrate
```

## Explicación

`RESTRICT` impide borrar el padre mientras haya hijos; la prueba llama `product_type.delete()` y espera `RestrictedError`.

```text
ProductType 1 --------- N Product
```

## Criterios de aceptación

- AC-05-01: `product_type_id` es obligatorio.
- AC-05-02: borrar el tipo con productos falla.
- AC-05-03: el nombre de producto es único.
- AC-05-04: status y stock por defecto son `inactive` y 0.

## Evidencias y GATE

- EVI-05-01: migración `product.0001_initial`.
- EVI-05-02: `RestrictedError` observado por el test.

Las pruebas `ProductApiTests.test_default_status_and_type_restriction` y `test_duplicate_product_name` cierran los cuatro criterios en PASS.
