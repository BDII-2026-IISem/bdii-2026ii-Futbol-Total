# ISS-12 - Consulta y anulación de ventas

> **Referencia PedalLibre.** Consulta, cancelación y cierre de reservas y alquileres. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.

[🧠 Comprender este bloque →](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-12-aprendizaje/) · [✅ GATE de la unidad](https://tecnogua.com/academic/site/backend2026/django/manual/13-ISS-12-consulta-y-anulacion-de-ventas/#gate)
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.
Leer una venta con sus líneas y anularla sin borrar el histórico.
- ISS-11 superado.
SaleReadViewSet mezcla ListModelMixin, RetrieveModelMixin, DestroyModelMixin y GenericViewSet. No incluye update ni create: los totales no se editan por CRUD y el alta ya tiene su APIView.
GET /api/sales/ ya está registrado: es el mismo path("sales/") del ISS-11. SaleCollectionAPIView.get reutiliza el queryset y el serializer del viewset sobre el request ya autenticado. No se agrega otra línea al URLconf del proyecto.
El detalle sí es una ruta nueva, en la app:
```
ARCHIVO: apps/sale/urls.py

UBICAR:
from apps.sale.views import SaleCollectionAPIView

REEMPLAZAR POR:
from apps.sale.views import SaleCollectionAPIView, SaleReadViewSet

DEBAJO DE:
    path("sales/", SaleCollectionAPIView.as_view(), name="sale-collection"),

AGREGAR:
    path(
        "sales/<int:pk>/",
        SaleReadViewSet.as_view({"get": "retrieve", "delete": "destroy"}),
        name="sale-detail",
    ),

```
Un viewset no se publica con as_view() vacío. El diccionario fija qué método HTTP llama a qué acción. GET entra a retrieve y DELETE a destroy. No se enlazan put, patch ni post: el router lo habría hecho solo. <int:pk> es el mismo convertidor que lookup_value_converter = "int".
DELETE /api/sales/<int:pk>/ llama sale.void():
```
si la venta ya está inactive → no toca el stock
si está active → devuelve la cantidad de cada línea active y pasa venta y líneas a inactive

```
El queryset usa select_related("client") y prefetch_related("lines__product").
Las pruebas siguen en acceso OPEN. Se agregan al final de SaleTransactionTests, sin tocar el setUp. El GET del detalle comprueba el precio histórico después de cambiar el precio vivo del producto. El listado y el DELETE comprueban la anulación.
```
ARCHIVO: apps/sale/tests.py

AL FINAL DE class SaleTransactionTests, AGREGAR:

    def test_detail_keeps_historical_price(self):
        response = self.client.post(
            "/api/sales/",
            self._payload([{"productId": self.water.id, "quantity": 1}]),
            format="json",
        )
        Product.objects.filter(pk=self.water.pk).update(price=Decimal("99.00"))
        detail = self.client.get(f"/api/sales/{response.data['id']}/")
        self.assertEqual(detail.status_code, 200)
        self.assertEqual(detail.data["lines"][0]["unit_price"], "10.00")

    def test_list_returns_the_registered_sale(self):
        created = self.client.post(
            "/api/sales/",
            self._payload([{"productId": self.water.id, "quantity": 1}]),
            format="json",
        )
        listed = self.client.get("/api/sales/")
        self.assertEqual(listed.status_code, 200)
        self.assertTrue(any(row["id"] == created.data["id"] for row in listed.data))

    def test_void_restores_stock_once(self):
        created = self.client.post(
            "/api/sales/",
            self._payload([{"productId": self.water.id, "quantity": 2}]),
            format="json",
        )
        sale_id = created.data["id"]
        first = self.client.delete(f"/api/sales/{sale_id}/")
        second = self.client.delete(f"/api/sales/{sale_id}/")
        self.assertEqual(first.status_code, 204)
        self.assertEqual(second.status_code, 204)
        self.water.refresh_from_db()
        self.assertEqual(self.water.stock, 5)
        sale = Sale.objects.get(pk=sale_id)
        self.assertEqual(sale.status, RecordStatus.INACTIVE)

```
```
python manage.py test apps.sale

```
Anular no es QuerySet.delete(). La fila demuestra que la venta existió. El stock se repone una sola vez: la segunda llamada ve la venta inactiva y no suma de nuevo.
El admin, en el ISS-13, tampoco ofrece borrado físico de estas tablas.
Capa HTTP, acceso OPEN. Se reutiliza el POST del ISS-11 y se agregan las lecturas y la anulación. product_sales no tiene ruta: las líneas viajan dentro de la venta.
```
python manage.py test apps.sale
        │
        ├── GET  /api/sales/            200   la venta recién creada está en la lista
        ├── GET  /api/sales/<id>/       200   unit_price sigue en 10.00 aunque el catálogo pase a 99
        └── DELETE /api/sales/<id>/     204
                │
                ├── primera vez    stock vuelve al original, venta y líneas inactive
                └── segunda vez    204 otra vez, el stock no sube de más

```
Swagger de la lista, el detalle y el DELETE, en OPEN, se hace en el ISS-14, cuando el esquema ya publica estas rutas. lines es la tabla product_sales vista desde la venta.
- AC-12-01: GET del detalle incluye las líneas y el unit_price guardado.
- AC-12-02: DELETE responde 204.
- AC-12-03: la fila sales sigue existiendo en inactive.
- AC-12-04: anular dos veces deja el stock en el valor original, no por encima.
test_void_restores_stock_once y el GET del test de registro.
- EVI-12-01: ambos comportamientos PASS.
✅ GATE de la unidad ISS-12 — este bloque no añade ningún criterio nuevo.
Las condiciones de cierre son las de esta misma página:
- 📋 Criterios de aceptación → [Criterios de aceptación](https://tecnogua.com/academic/site/backend2026/django/manual/13-ISS-12-consulta-y-anulacion-de-ventas/#criterios-de-aceptacion)
- ✅ GATE → [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/13-ISS-12-consulta-y-anulacion-de-ventas/#gate)
- 🔎 Verificación → [Verificación](https://tecnogua.com/academic/site/backend2026/django/manual/13-ISS-12-consulta-y-anulacion-de-ventas/#verificacion)
- 🧠 Autoevaluación → [Evaluación del cuaderno](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-12-aprendizaje/#l-cuestionario-de-preguntas-de-defensa-oral-tecnica)
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.
Navegación de la ruta: ← [ISS-12 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-12-aprendizaje/) · [↑ Ruta Django](https://tecnogua.com/academic/site/backend2026/django/) · → [ISS-13 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-13-aprendizaje/)
