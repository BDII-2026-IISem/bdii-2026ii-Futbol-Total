# ISS-02 - Apps client, product y sale

> **Referencia PedalLibre.** Apps PedalLibre: seguridad, clientes, estaciones, flota, reservas, alquileres y operaciones. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


## Objetivo

Crear las tres apps de negocio con la CLI y registrarlas dentro del paquete `apps`.

## Requisitos

- ISS-01 superado.
- Todavía no se escriben modelos: el Custom User del ISS-03 debe existir antes de migrar.

## Construcción

```bash
mkdir -p apps/client apps/product apps/sale
python manage.py startapp client apps/client
python manage.py startapp product apps/product
python manage.py startapp sale apps/sale
mkdir -p apps
touch apps/__init__.py
```

`startapp` exige que el directorio de destino exista. La CLI crea `models.py`, `admin.py` y `views.py`; no se copian a mano. Tampoco crea `urls.py`: aparecerá con los endpoints.

Actualice los `AppConfig`, sin cambiar los nombres de clase:

```python
# apps/client/apps.py
name = "apps.client"
label = "client"

# apps/product/apps.py
name = "apps.product"
label = "product"

# apps/sale/apps.py
name = "apps.sale"
label = "sale"
```

Al final de `INSTALLED_APPS` de `config/settings/__init__.py`, agregue:

```python
"apps.client.apps.ClientConfig",
"apps.product.apps.ProductConfig",
"apps.sale.apps.SaleConfig",
```

## Explicación

Al vivir dentro de `apps/`, cada `AppConfig.name` debe indicar su ruta completa. El `label` conserva los nombres de dominio para las migraciones.

```text
apps/
|- client/     compradores
|- product/    catálogo e inventario
`- sale/       transacciones
```

## Criterios de aceptación

- AC-02-01: las tres apps fueron creadas con `startapp`.
- AC-02-02: `python manage.py check` no reporta apps mal registradas.
- AC-02-03: todavía no hay modelos de negocio.

## Verificación, evidencias y GATE

```bash
python manage.py check
```

EVI-02-01 es `System check identified no issues` en el entorno final. Los tres criterios cierran en PASS mediante el árbol del repositorio, `check` y la revisión de este ISS.
