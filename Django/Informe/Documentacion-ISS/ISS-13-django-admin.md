# ISS-13 - Django Admin

> **Referencia PedalLibre.** Administración de las 21 tablas PedalLibre existentes. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Guía de estudio	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

ISS-13 — Django Admin
Objetivo
Dejar las cinco tablas de negocio explorables en el admin: listas que se filtran, se buscan y se ordenan, y formularios agrupados para clientes, tipos y productos. Las ventas se inspeccionan; no se rearman desde aquí.

Requisitos
ISS-12 superado.
django.contrib.admin dentro de INSTALLED_APPS. En StoreLab ese archivo es config/settings/__init__.py, no sitealmacen/settings.py. startproject ya lo incluye.
La ruta admin/ ya está en config/urls.py desde el ISS-00.
Construcción
Superusuario
Con el entorno activo, en la raíz del proyecto:


python manage.py createsuperuser
Django pregunta usuario, correo y contraseña dos veces. Los validadores rechazan una clave común o solo numérica. La contraseña del superusuario tiene que cumplirlos.

StoreUserManager.create_superuser fuerza status=active. Sin eso el admin no dejaría entrar, porque is_active se copia del status.

apps/client/admin.py
startapp ya creó apps/client/admin.py. Se reescribe con cat, porque el comentario inicial no se conserva:


cat > apps/client/admin.py <<'EOF'
Al terminar la clase, cierre el bloque con EOF. Lo mismo para apps/product/admin.py y apps/sale/admin.py: archivo existente, contenido nuevo vía cat >.


from django.contrib import admin

from apps.client.models import Client


@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = ("name", "email", "phone", "address", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("name", "email", "phone", "address")
    list_editable = ("status",)
    ordering = ("name", "email")
    readonly_fields = ("created_at", "updated_at")
    fieldsets = (
        ("Información del cliente", {"fields": ("name", "email", "phone", "address")}),
        ("Estado", {"fields": ("status",)}),
        (
            "Auditoría",
            {"fields": ("created_at", "updated_at"), "classes": ("collapse",)},
        ),
    )
@admin.register sustituye a admin.site.register(Client, ClientAdmin). Hace lo mismo junto a la clase.

list_display son las columnas. Están name, email, phone, address y, además, status y created_at, que este modelo sí tiene.
list_filter queda en status. Esa barra parte la lista en active e inactive. Nombre y correo se consultan con search_fields.
search_fields cubre nombre, correo, teléfono y dirección: es el cuadro de búsqueda, no la barra lateral.
list_editable permite cambiar status en la lista sin abrir el formulario. El primer campo de list_display no puede ser editable: es el enlace a la ficha. Por eso name va primero.
ordering ordena la lista por nombre y, en empate, por correo.
fieldsets agrupa el formulario. No hay grupo de credenciales: Client no tiene password. La contraseña vive en el usuario de security, y su admin llega en la Fase II.
created_at y updated_at son de solo lectura y van plegados. Django los llena solo.
apps/product/admin.py

from django.contrib import admin

from apps.product.models import Product, ProductType


@admin.register(ProductType)
class ProductTypeAdmin(admin.ModelAdmin):
    list_display = ("name", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("name", "description")
    list_editable = ("status",)
    ordering = ("name",)
    readonly_fields = ("created_at", "updated_at")
    fieldsets = (
        (None, {"fields": ("name", "description", "status")}),
        (
            "Auditoría",
            {"fields": ("created_at", "updated_at"), "classes": ("collapse",)},
        ),
    )


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("name", "product_type", "price", "stock", "status")
    list_filter = ("status", "product_type")
    search_fields = ("name", "description")
    list_editable = ("price", "stock", "status")
    ordering = ("name",)
    autocomplete_fields = ("product_type",)
    readonly_fields = ("created_at", "updated_at")
    fieldsets = (
        ("Información", {"fields": ("name", "description", "product_type")}),
        ("Precio y stock", {"fields": ("price", "stock")}),
        ("Estado", {"fields": ("status",)}),
        (
            "Auditoría",
            {"fields": ("created_at", "updated_at"), "classes": ("collapse",)},
        ),
    )

    def get_queryset(self, request):
        return super().get_queryset(request).select_related("product_type")
El tipo se registra con su propia clase y la misma lista filtrable: product_types tiene name, description y status.

En el producto no existen brand, quantity ni min_stock. Las columnas equivalentes de este modelo son product_type, price y stock. list_editable aplica a precio, stock y estado, que son los datos de catálogo que el admin sí puede corregir. get_queryset hace select_related("product_type") para no consultar el tipo una vez por fila.

autocomplete_fields = ("product_type",) cambia el desplegable por un buscador. Django solo lo acepta si ProductTypeAdmin define search_fields. Eso lo cumple name y description.

apps/sale/admin.py

from django.contrib import admin

from apps.sale.models import ProductSale, Sale


class ProductSaleInline(admin.TabularInline):
    model = ProductSale
    extra = 0
    can_delete = False
    show_change_link = True
    fields = ("product", "quantity", "unit_price", "line_total", "status")
    readonly_fields = ("product", "quantity", "unit_price", "line_total", "status")

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(Sale)
class SaleAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "client",
        "sale_date",
        "subtotal",
        "tax",
        "discounts",
        "total",
        "status",
    )
    list_filter = ("status", "sale_date")
    search_fields = ("client__name", "client__email")
    ordering = ("-sale_date",)
    date_hierarchy = "sale_date"
    readonly_fields = (
        "client",
        "sale_date",
        "subtotal",
        "tax",
        "discounts",
        "total",
        "status",
        "created_at",
        "updated_at",
    )
    fieldsets = (
        ("Información de la venta", {"fields": ("client", "status")}),
        (
            "Totales",
            {
                "fields": ("subtotal", "tax", "discounts", "total"),
                "classes": ("collapse",),
            },
        ),
        ("Fecha", {"fields": ("sale_date",), "classes": ("collapse",)}),
        (
            "Auditoría",
            {"fields": ("created_at", "updated_at"), "classes": ("collapse",)},
        ),
    )
    inlines = (ProductSaleInline,)

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

    def get_queryset(self, request):
        return super().get_queryset(request).select_related("client")


@admin.register(ProductSale)
class ProductSaleAdmin(admin.ModelAdmin):
    list_display = ("sale", "product", "quantity", "unit_price", "line_total", "status")
    list_filter = ("status", "sale__sale_date", "product__status")
    search_fields = ("sale__client__name", "product__name")
    ordering = ("-sale__sale_date", "id")
    readonly_fields = (
        "sale",
        "product",
        "quantity",
        "unit_price",
        "line_total",
        "status",
        "created_at",
        "updated_at",
    )
    fieldsets = (
        ("Línea", {"fields": ("sale", "product", "quantity", "unit_price", "line_total")}),
        ("Estado", {"fields": ("status",)}),
        (
            "Auditoría",
            {"fields": ("created_at", "updated_at"), "classes": ("collapse",)},
        ),
    )

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

    def get_queryset(self, request):
        return super().get_queryset(request).select_related(
            "sale", "sale__client", "product"
        )
La lista de ventas muestra los importes reales: subtotal, tax, discounts y total. date_hierarchy parte esa lista por año, mes y día de sale_date. ordering = ("-sale_date",) pone la más reciente arriba. La búsqueda usa client__name y client__email: el doble guion bajo cruza la FK. get_queryset trae el cliente en la misma consulta.

El inline muestra la línea con sus campos: quantity, unit_price y line_total. El importe de la línea es line_total. extra = 0 y has_add_permission en False dejan el formulario sin filas vacías. Una línea creada en el admin no pasaría por la transacción que copia el precio y descuenta el stock. La venta se crea con POST /api/sales/ y se anula con DELETE, que llama a void(). Por eso Sale y ProductSale no se agregan ni se borran en el admin, y su status no es list_editable: cambiarlo en la lista no devolvería el stock.

show_change_link abre la ficha de la línea desde la venta. Esa ficha también es de solo lectura.

Explicación

/admin/
   │
   ├── Client          lista + formulario  (alta y edición)
   ├── ProductType     lista + formulario
   ├── Product         lista + formulario, tipo por autocompletado
   ├── Sale            lista + ficha de solo lectura, líneas en inline
   └── ProductSale     lista + ficha de solo lectura
El admin usa sesión y CSRF. No es OPEN, ni JWT con token, ni JWT con token + RBAC. Sirve para mirar y, en catálogo y clientes, para corregir datos. No reemplaza la API.

Un DELETE del admin sobre un cliente o un producto sería físico y chocaría con RESTRICT si ya hay ventas. En ventas y detalles ese botón se apaga. La baja de una venta sigue siendo la de la API.

Criterios de aceptación
AC-13-01: Client, ProductType, Product, Sale y ProductSale están registrados, con list_display, list_filter y search_fields.
AC-13-02: el formulario de cliente agrupa sus campos y no pide contraseña.
AC-13-03: el producto lista price y stock, no marca ni quantity.
AC-13-04: la venta no se agrega ni se borra desde el admin, y el inline no crea líneas.
AC-13-05: python manage.py check no se queja del autocompletado.
Verificación

python manage.py check
Entrar a /admin/ con el superusuario y abrir cada modelo de negocio. En clientes y productos debe haber alta. En ventas, no.

Evidencias
EVI-13-01: System check identified no issues.
GATE
AC	Verificación	Evidencia	Resultado
AC-13-01	admin.py de client, product y sale	revisión	PASS
AC-13-02	fieldsets de Client	client/admin.py	PASS
AC-13-03	columnas de Product	product/admin.py	PASS
AC-13-04	has_add_permission y has_delete_permission	sale/admin.py	PASS
AC-13-05	check	EVI-13-01	PASS
✅ GATE de la unidad ISS-13 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Evaluación del cuaderno
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-13 · 🧠 Aprender · ↑ Ruta Django · → ISS-14 · 🧠 Aprender
