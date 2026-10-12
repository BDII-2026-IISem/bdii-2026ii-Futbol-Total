# ISS-10 - Disponibles con ListAPIView

> **Referencia PedalLibre.** Disponibilidad de bicicletas, estaciones y puntos de anclaje. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.

[🧠 Comprender este bloque →](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-10-aprendizaje/) · [✅ GATE de la unidad](https://tecnogua.com/academic/site/backend2026/django/manual/11-ISS-10-disponibles-con-listapiview/#gate)
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.
Publicar una lectura filtrada que no es el CRUD del producto.
- ISS-09 superado.
- El endpoint debe justificar GenericAPIView. No se crea para completar un cuadro.
apps/product/urls.py ya tiene el router. Se parchea: la lectura especial entra en urlpatterns antes de router.urls.
```
ARCHIVO: apps/product/urls.py

UBICAR:
from rest_framework.routers import SimpleRouter

REEMPLAZAR POR:
from django.urls import path
from rest_framework.routers import SimpleRouter

UBICAR el import de las vistas y AGREGAR AvailableProductListAPIView.

REEMPLAZAR:
urlpatterns = router.urls

POR:
urlpatterns = [
    path(
        "products/available/",
        AvailableProductListAPIView.as_view(),
        name="product-available",
    ),
]
urlpatterns += router.urls

```
config/urls.py no cambia: include("apps.product.urls") ya delega todo lo que cuelga de api/.
Django prueba urlpatterns en orden y se queda con la primera coincidencia. Con lookup_value_converter = "int", la cadena available no entra en <int:pk>, así que el orden ya no evita un choque. Aun así la ruta literal va primero: deja escrito que available es una colección distinta y no un id. Si el convertidor volviera a ser texto, el detalle se comería esta URL.
La clase se agrega al archivo de vistas, que ya tiene los viewsets. No se reescribe el CRUD.
```
ARCHIVO: apps/product/views.py

ENCIMA DE:
from rest_framework import viewsets

AGREGAR, en la misma línea de imports de rest_framework si ya está viewsets:
from rest_framework.generics import ListAPIView

AL FINAL DEL ARCHIVO, AGREGAR:

```
```
class AvailableProductListAPIView(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = ProductSerializer

    def get_queryset(self):
        return Product.objects.select_related("product_type").filter(
            status=RecordStatus.ACTIVE,
            stock__gt=0,
            product_type__status=RecordStatus.ACTIVE,
        )

```
AllowAny es el acceso OPEN de esta fase. El ISS-22 lo cambia. Hay que importar AllowAny si el archivo de vistas todavía no lo tiene.
La prueba del filtro se agrega al archivo de tests, que ya cubre el CRUD en OPEN. No se reescribe la clase.
```
ARCHIVO: apps/product/tests.py

AL FINAL DE class ProductApiTests, AGREGAR:

    def test_product_crud_and_available_filter(self):
        created = self.client.post(
            "/api/products/",
            {
                "productTypeId": self.product_type.id,
                "name": "Agua",
                "price": "2.50",
                "stock": 4,
                "status": "active",
            },
            format="json",
        )
        self.assertEqual(created.status_code, 201)
        available = self.client.get("/api/products/available/")
        self.assertEqual(available.status_code, 200)
        self.assertEqual(len(available.data), 1)
        Product.objects.filter(pk=created.data["id"]).update(stock=0)
        empty = self.client.get("/api/products/available/")
        self.assertEqual(empty.data, [])

```
```
python manage.py test apps.product.tests.ProductApiTests.test_product_crud_and_available_filter

```
Sigue siendo OPEN: el GET no envía Bearer.
ListAPIView es GenericAPIView más ListModelMixin. Automatiza la serialización de un queryset y deja el filtro en get_queryset. No ofrece POST, PUT ni DELETE. Un ModelViewSet obligaría a apagar esos métodos. Una APIView reescribiría el ciclo que el mixin ya resuelve.
```
GET /api/products/available/
        │
        ▼
  ListAPIView
        │
        ▼
  status active AND stock > 0 AND tipo active

```
Capa HTTP, acceso OPEN. Es un solo método del mismo archivo de tests. El POST crea el producto y el GET comprueba el filtro. Al poner el stock en cero por el ORM, la lista queda vacía y la fila sigue en products.
```
python manage.py test apps.product.tests.ProductApiTests.test_product_crud_and_available_filter
        │
        ▼
POST /api/products/          Agua, stock 4, active
        │
        ▼
GET /api/products/available/     200   un elemento
        │
        ▼
stock = 0 en la tabla
        │
        ▼
GET /api/products/available/     200   []

```
En Swagger, este GET se pulsa en el ISS-14, todavía OPEN, junto al resto del catálogo. No se abre el navegador en este ISS.
- AC-10-01: un producto activo con stock aparece.
- AC-10-02: al quedar el stock en cero, desaparece de esta lista y sigue en la tabla.
ProductApiTests.test_product_crud_and_available_filter.
- EVI-10-01: la lista pasa de un elemento a [] sin borrar el producto. PASS.
✅ GATE de la unidad ISS-10 — este bloque no añade ningún criterio nuevo.
Las condiciones de cierre son las de esta misma página:
- 📋 Criterios de aceptación → [Criterios de aceptación](https://tecnogua.com/academic/site/backend2026/django/manual/11-ISS-10-disponibles-con-listapiview/#criterios-de-aceptacion)
- ✅ GATE → [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/11-ISS-10-disponibles-con-listapiview/#gate)
- 🔎 Verificación → [Verificación](https://tecnogua.com/academic/site/backend2026/django/manual/11-ISS-10-disponibles-con-listapiview/#verificacion)
- 🧠 Autoevaluación → [Evaluación del cuaderno](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-10-aprendizaje/#k-cuestionario-de-defensa-oral-tecnica)
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.
Navegación de la ruta: ← [ISS-10 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-10-aprendizaje/) · [↑ Ruta Django](https://tecnogua.com/academic/site/backend2026/django/) · → [ISS-11 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-11-aprendizaje/)
