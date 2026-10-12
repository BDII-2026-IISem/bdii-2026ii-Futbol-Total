# Referencia del proyecto PedalLibre

Este archivo es la fuente de verdad para todos los ISS Django de esta carpeta. Los modelos Django representan tablas que ya se crean mediante los scripts de [Creacion de Tablas y Reguistros](./Creacion%20de%20Tablas%20y%20Registros/guia.md); no se deben crear tablas paralelas de StoreLab ni ejecutar migraciones que cambien ese esquema sin una migración SQL coordinada para los cuatro motores.

## Base de datos y entorno

El selector es `DB_DIALECT` y acepta `mysql`, `postgres`, `mssql` u `oracle`. El backend solo valida el bloque activo. Las variables siguen este contrato:

```dotenv
DB_DIALECT=mysql

DB_MYSQL_HOST=172.18.50.255
DB_MYSQL_PORT=3306
DB_MYSQL_USERNAME=admin
DB_MYSQL_PASSWORD=1704
# Texto recibido en la configuración original: -DW
DB_MYSQL_NAME=Pedalibre-Terminal-Dbeaver

DB_POSTGRES_HOST=localhost
DB_POSTGRES_PORT=5432
DB_POSTGRES_USERNAME=admin
DB_POSTGRES_PASSWORD=1704
DB_POSTGRES_NAME=Pedalibre

DB_MSSQL_HOST=localhost
DB_MSSQL_PORT=1433
DB_MSSQL_USERNAME=admin
DB_MSSQL_PASSWORD=1704
DB_MSSQL_NAME=Pedalibre

DB_ORACLE_HOST=localhost
DB_ORACLE_PORT=1521
DB_ORACLE_USERNAME=admin
DB_ORACLE_PASSWORD=1704
DB_ORACLE_NAME=Pedalibre
DB_ORACLE_CONNECT_STRING=localhost:1521/Pedalibre
```

El bloque copiable del laboratorio, incluido con los valores de conexión autorizados, está en [ISS-01](./ISS-01-settings-y-seleccion-del-motor.md). `.env` continúa excluido de Git. La configuración de Django debe traducir estas variables a un único `DATABASES["default"]`: `django.db.backends.mysql`, `django.db.backends.postgresql`, `mssql` y `django.db.backends.oracle`.

## Tablas del dominio

Las 21 tablas son: `roles`, `users`, `clients`, `stations`, `station_locations`, `station_schedules`, `docking_points`, `bicycles`, `bicycle_dockings`, `reservations`, `rates`, `rentals`, `rental_events`, `penalties`, `maintenance`, `payments`, `incidents`, `notifications`, `bicycle_history`, `reviews` e `invoices`.

Relaciones principales: `users.role_id -> roles`; `clients.user_id -> users`; estaciones agrupan ubicaciones, horarios y puntos de anclaje; bicicletas se vinculan a anclajes, reservas, alquileres, mantenimiento e historial; alquileres vinculan cliente, bicicleta, tarifa y estaciones; pagos dependen de alquileres e invoices de pagos.

## Reglas de integración Django

- Use `db_table` y `db_column` con los nombres físicos de los scripts: por ejemplo, `users.user_id`, `clients.client_id`, `rentals.rental_id` y `bicycles.bicycle_id`.
- Cada modelo debe declarar `managed = False` mientras la creación y evolución del esquema sigan en los SQL por motor.
- No cree `Product`, `ProductType`, `Sale`, `ProductSale`, `RoleUser`, `Resource` ni `ResourceRole`: no pertenecen al esquema PedalLibre.
- El usuario de autenticación debe mapear `users`, con `password_hash`, `role_id` e `is_active`; `clients` contiene perfil de cliente, no una contraseña.
- Las APIs de disponibilidad se derivan de bicicletas con `status = 'available'`, puntos de anclaje disponibles y estaciones activas; las operaciones de negocio centrales son reserva, alquiler, devolución, pago, mantenimiento e incidencia.
