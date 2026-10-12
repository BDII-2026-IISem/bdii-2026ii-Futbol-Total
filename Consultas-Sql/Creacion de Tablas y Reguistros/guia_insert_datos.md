# Guia de insercion de datos — PedalLibre

Cada script inserta **100 registros en cada una de las 21 tablas**: 2.100 registros por motor. Los IDs van del 1 al 100 y las claves foráneas relacionan los registros entre sí.

## Comandos WSL

Ejecuta el bloque del motor correspondiente desde WSL, después de crear las tablas y confirmar que estén vacías. Escribe la contraseña cuando el cliente la solicite.

### MySQL

```bash
cd "$HOME/ia-lab/services/motores-bd/mysql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mysql/seed_mysql_100.sql" mysql-server:/tmp/seed_mysql_100.sql
docker compose exec -it mysql sh -c 'mysql -u root -p Pedalibre-Terminal-Dbeaver < /tmp/seed_mysql_100.sql'
```

### Microsoft SQL Server

```bash
cd "$HOME/ia-lab/services/motores-bd/mssql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mssql/seed_mssql_100.sql" mssql-server:/tmp/seed_mssql_100.sql
docker compose exec -it mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U admin -C -d Pedalibre-Terminal-Dbeaver -b -i /tmp/seed_mssql_100.sql
```

### PostgreSQL

```bash
cd "$HOME/ia-lab/services/motores-bd/postgres"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Postgres/seed_postgres_100.sql" postgres-server:/tmp/seed_postgres_100.sql
docker compose exec -it postgres psql -h localhost -W -U postgres -d Pedalibre-Terminal-Dbeaver -v ON_ERROR_STOP=1 -f /tmp/seed_postgres_100.sql
```

### Oracle

```bash
cd "$HOME/ia-lab/services/motores-bd/oracle"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Oracle/seed_oracle_100.sql" oracle-server:/tmp/seed_oracle_100.sql
docker compose exec -it oracle sqlplus -L 'PEDALIBRETERMINALDBEAVER@//localhost:1521/Pedalibre' @/tmp/seed_oracle_100.sql
```

## Resultado

Cada script muestra el conteo de filas por tabla al terminar.

| Tabla | Datos insertados |
|---|---|
| `roles` | Roles de cliente, operador, mantenimiento, supervisor y soporte. |
| `users` | Usuarios con nombres, correos ficticios `@example.com`, estado activo y hash SHA-256 de demostración en `password_hash`; no incluye contraseñas en texto claro. |
| `clients` | Clientes con nombres, apellidos, documentos ficticios y teléfonos de prueba. |
| `stations` | Estaciones ubicadas en Bogotá, Medellín, Cali, Barranquilla y Cartagena, con direcciones, capacidad y estados variados. |
| `station_locations` | Coordenadas de ubicación para las estaciones. |
| `station_schedules` | Horarios de atención y algunos días marcados como cerrados. |
| `docking_points` | Anclajes con códigos y estados disponibles, ocupados o en mantenimiento. |
| `bicycles` | Bicicletas con seriales de prueba, tipos estándar, urbanos, de montaña o eléctricas, y distintos estados. |
| `bicycle_dockings` | Registros de bicicletas asignadas a anclajes, con fechas de anclaje y, en algunos casos, de retiro. |
| `rates` | Tarifas urbanas, diarias, estudiantiles y eléctricas, con precios, unidades de cobro y estado activo. |
| `reservations` | Reservas vinculadas con clientes, bicicletas y estaciones, en estados confirmados, cancelados o completados. |
| `rentals` | Alquileres con cliente, bicicleta, tarifa, estaciones de salida y llegada, fechas, estado y valor. |
| `rental_events` | Eventos de desbloqueo, inicio de recorrido, devolución y confirmación de pago. |
| `penalties` | Penalidades por retrasos, devoluciones fuera de zona, daños o limpieza, con valor y estado. |
| `maintenance` | Mantenimientos preventivos, revisiones de frenos, llantas, baterías y seguridad, con fechas, costos y estados. |
| `payments` | Pagos asociados a alquileres, con valores, métodos de pago, referencias y estados. |
| `incidents` | Reportes de bicicletas, frenos, anclajes y solicitudes de asistencia, con severidad y estado. |
| `notifications` | Notificaciones de alquiler, devolución, pago y novedades de estación, algunas marcadas como leídas. |
| `bicycle_history` | Historial de registro, mantenimiento, anclaje y cambios de estado de bicicletas. |
| `reviews` | Calificaciones de 1 a 5 y comentarios ficticios sobre el servicio. |
| `invoices` | Facturas asociadas a pagos, con número, subtotal, impuesto y total. |

Los nombres, documentos, teléfonos, correos, referencias de pago y demás valores son datos ficticios de prueba; no representan personas ni transacciones reales.

## Carga de datos de prueba en `rentals_audit`

<a id="pruebas-dml-triggers-auditoria"></a>

Después de cargar los registros base, ejecuta en WSL únicamente el comando del motor que vas a validar, y solo si la tabla `rentals_audit` y sus triggers ya fueron creados previamente. Cada seed inserta un alquiler aislado, lo actualiza y lo elimina; los triggers existentes guardan las tres acciones en `rentals_audit`. Los seeds no crean ni modifican objetos permanentes. En PostgreSQL, el SQL usa una tabla temporal para conservar el identificador generado durante la transacción. En SQL Server, si aparece `Invalid object name 'dbo.rentals_audit'`, crea primero la tabla con el script de preparación indicado abajo y luego vuelve a ejecutar el seed.

Los comandos copian el archivo de prueba al contenedor del motor y lo ejecutan en la base Pedalibre. Abre WSL y ejecuta el bloque correspondiente:

### MySQL

```bash
cd "$HOME/ia-lab/services/motores-bd/mysql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mysql/seed_rentals_audit_mysql.sql" mysql-server:/tmp/seed_rentals_audit_mysql.sql
docker compose exec -it mysql sh -c 'mysql -u root -p Pedalibre-Terminal-Dbeaver < /tmp/seed_rentals_audit_mysql.sql'
```

### PostgreSQL

```bash
cd "$HOME/ia-lab/services/motores-bd/postgres"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Postgres/seed_rentals_audit_postgres.sql" postgres-server:/tmp/seed_rentals_audit_postgres.sql
docker compose exec -it postgres psql -h localhost -W -U postgres -d Pedalibre-Terminal-Dbeaver -v ON_ERROR_STOP=1 -f /tmp/seed_rentals_audit_postgres.sql
```

### Microsoft SQL Server

Si todavía no existe `dbo.rentals_audit`, ejecuta primero este script idempotente para crearla; no reemplaza ni modifica los triggers existentes:

```bash
cd "$HOME/ia-lab/services/motores-bd/mssql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mssql/mssql-create-rentals-audit.sql" mssql-server:/tmp/mssql-create-rentals-audit.sql
docker compose exec -it mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U admin -C -d Pedalibre-Terminal-Dbeaver -b -i /tmp/mssql-create-rentals-audit.sql
```

Después ejecuta la prueba DML:

```bash
cd "$HOME/ia-lab/services/motores-bd/mssql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mssql/seed_rentals_audit_mssql.sql" mssql-server:/tmp/seed_rentals_audit_mssql.sql
docker compose exec -it mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U admin -C -d Pedalibre-Terminal-Dbeaver -b -i /tmp/seed_rentals_audit_mssql.sql
```

### Oracle

```bash
cd "$HOME/ia-lab/services/motores-bd/oracle"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Oracle/seed_rentals_audit_oracle.sql" oracle-server:/tmp/seed_rentals_audit_oracle.sql
docker compose exec -it oracle sqlplus -L 'PEDALIBRETERMINALDBEAVER@//localhost:1521/Pedalibre' @/tmp/seed_rentals_audit_oracle.sql
```

Al terminar, cada script muestra el identificador del alquiler de prueba. Guárdalo y ejecuta las consultas de verificación por motor en la sección de triggers de [informe.md](../informe.md). Si el DDL de auditoría no está instalado o sus triggers no están asociados a `rentals`, el seed no los crea: primero completa el procedimiento de creación ya documentado para ese motor.
