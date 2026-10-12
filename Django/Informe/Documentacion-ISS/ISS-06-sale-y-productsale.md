# ISS-06 - Sale y ProductSale

> **Referencia PedalLibre.** Operación principal: reservations, rentals, rental_events y bicycle_dockings; no existen ventas. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Guía de estudio	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

ISS-06 — Sale y ProductSale
Objetivo
Representar la venta y su detalle con precio histórico. El detalle no se sustituye por un muchos-a-muchos simple.

Requisitos
ISS-05 superado.
ProductSale tiene cantidad, precio y total de línea.
Construcción
apps/sale/managers.py es nuevo. En este ISS el manager todavía no registra la venta: solo existe para que el modelo pueda colgar objects de una clase propia. El método register se agrega en el ISS-11, cuando la operación sea transaccional. Por ahora el archivo declara el queryset vacío y el manager.


cat > apps/sale/managers.py <<'EOF'
from django.db import models


class SaleQuerySet(models.QuerySet):
    pass


class SaleManager(models.Manager.from_queryset(SaleQuerySet)):
    pass
EOF
apps/sale/models.py ya existe. Se reescribe. No use ManyToManyField.


cat > apps/sale/models.py <<'EOF'
from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models, transaction

from apps.client.models import Client
from apps.common.models import StoreLabModel
from apps.common.status import RecordStatus
from apps.product.models import Product
from apps.sale.managers import SaleManager


class Sale(StoreLabModel):
    client = models.ForeignKey(
        Client,
        on_delete=models.RESTRICT,
        related_name="sales",
        db_column="client_id",
    )
    sale_date = models.DateTimeField()
    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    tax = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    discounts = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    total = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))

    objects = SaleManager()

    class Meta:
        db_table = "sales"
        verbose_name = "venta"
        verbose_name_plural = "ventas"
        ordering = ["-sale_date", "-id"]
        constraints = [
            StoreLabModel.status_constraint("sales_status_valid"),
            models.CheckConstraint(
                condition=models.Q(subtotal__gte=0)
                & models.Q(tax__gte=0)
                & models.Q(discounts__gte=0)
                & models.Q(total__gte=0),
                name="sales_amounts_non_neg",
            ),
        ]

    def __str__(self):
        return f"Venta {self.pk}"

    def void(self):
        with transaction.atomic():
            sale = Sale.objects.select_for_update().get(pk=self.pk)
            if sale.status == RecordStatus.INACTIVE:
                return sale
            lines = sale.lines.select_related("product").select_for_update().order_by("product_id")
            for line in lines:
                if line.status != RecordStatus.ACTIVE:
                    continue
                product = Product.objects.select_for_update().get(pk=line.product_id)
                product.stock += line.quantity
                product.save(update_fields=["stock", "updated_at"])
                line.status = RecordStatus.INACTIVE
                line.save(update_fields=["status", "updated_at"])
            sale.status = RecordStatus.INACTIVE
            sale.save(update_fields=["status", "updated_at"])
            return sale


class ProductSale(StoreLabModel):
    sale = models.ForeignKey(
        Sale,
        on_delete=models.RESTRICT,
        related_name="lines",
        db_column="sale_id",
    )
    product = models.ForeignKey(
        Product,
        on_delete=models.RESTRICT,
        related_name="sale_lines",
        db_column="product_id",
    )
    quantity = models.PositiveIntegerField(validators=[MinValueValidator(1)])
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    line_total = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        db_table = "product_sales"
        verbose_name = "detalle de venta"
        verbose_name_plural = "detalles de venta"
        ordering = ["id"]
        constraints = [
            StoreLabModel.status_constraint("product_sales_status_valid"),
            models.CheckConstraint(
                condition=models.Q(quantity__gte=1)
                & models.Q(unit_price__gte=0)
                & models.Q(line_total__gte=0),
                name="psale_amounts_valid",
            ),
        ]

    def __str__(self):
        return f"{self.product} x {self.quantity}"

    def save(self, *args, **kwargs):
        self.line_total = (self.unit_price * self.quantity).quantize(Decimal("0.01"))
        super().save(*args, **kwargs)
EOF
python manage.py makemigrations sale
python manage.py migrate
void() ya está porque la anulación es parte del modelo. El endpoint que la llama llega en el ISS-12. register() no está: sin él no hay forma de crear la venta saltándose el precio histórico. El ISS-11 lo agrega dentro de SaleQuerySet.

Explicación
unit_price es una columna. Si Product.price cambia después, la venta conserva el valor aplicado. line_total se recalcula en save() para que no se persista un total distinto de quantity × unit_price.

No hay ManyToManyField. La navegación es sale.lines.all().


Sale 1 ─────── N ProductSale N ─────── 1 Product
Criterios de aceptación
AC-06-01: existen sales y product_sales.
AC-06-02: las FK usan RESTRICT.
AC-06-03: line_total sale del producto cantidad por precio.
AC-06-04: no hay ManyToManyField hacia Product.
Verificación
Migración sale.0001_initial y el test que cambia Product.price después de vender.

Evidencias
EVI-06-01: migración aplicada en PostgreSQL.
EVI-06-02: el test de precio histórico PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-06-01	migración	EVI-06-01	PASS
AC-06-02	on_delete	modelos	PASS
AC-06-03	ProductSale.save	test de totales	PASS
AC-06-04	ausencia de ManyToMany	sale/models.py	PASS
✅ GATE de la unidad ISS-06 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-06 · 🧠 Aprender · ↑ Ruta Django · → ISS-07 · 🧠 Aprender
