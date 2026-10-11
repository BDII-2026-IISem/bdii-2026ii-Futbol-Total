# Consultas SQL de PedalLibre en cuatro motores

## Introducción

En este informe documento las consultas que voy a ejecutar en DBeaver sobre las bases de datos de PedalLibre. Tomo como referencia los ejemplos de consulta de las guías docentes de [MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/), [PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/), [Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/) y [Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/), adaptándolos a las tablas reales del proyecto.

Me concentro en consultas de lectura que permiten revisar registros, filtrar resultados, relacionar tablas y resumir información. No vuelvo a crear ni modificar tablas o registros, y no incluyo triggers. Las consultas principales usan sintaxis común a los cuatro motores; las consultas para limitar resultados se muestran por separado cuando cambia la sintaxis.

## Base de datos y tablas

En la carpeta [Creacion de Tablas y Reguistros](./Creacion%20de%20Tablas%20y%20Reguistros/) consulté la guía del esquema y los scripts de datos de prueba. Estos describen 21 tablas del dominio PedalLibre: `roles`, `users`, `clients`, `stations`, `station_locations`, `station_schedules`, `docking_points`, `bicycles`, `bicycle_dockings`, `reservations`, `rates`, `rentals`, `rental_events`, `penalties`, `maintenance`, `payments`, `incidents`, `notifications`, `bicycle_history`, `reviews` e `invoices`. La guía de inserción y la semilla MySQL contemplan 100 registros por tabla; también confirmaste que ya cargaste los datos en los cuatro motores. En DBeaver voy a validar la base seleccionada y los conteos antes de empezar con las consultas.

Por tanto, las tablas que consultaré son las tablas adicionales del proyecto, creadas sobre cada motor; no son tablas que se creen automáticamente al instalar MySQL, PostgreSQL, SQL Server u Oracle. La verificación se basa en los archivos SQL del proyecto; no he abierto las conexiones locales para comprobar en vivo el estado actual de cada servidor.

### Conexiones que usaré

| Motor | Base de datos o esquema indicado |
|---|---|
| MySQL | `Pedalibre-Terminal-Dbeaver` |
| Microsoft SQL Server | `Pedalibre-Terminal-Dbeaver` |
| PostgreSQL | `Pedalibre-Terminal-Dbeaver` |
| Oracle | Esquema `PEDALIBRETERMINALDBEAVER` |

**MySQL:** la guía del esquema y el script de datos de prueba usan la base `Pedalibre-Terminal-Dbeaver`. Antes de ejecutar, confirmo con `SELECT DATABASE()` que esa sea la base seleccionada en DBeaver.

## Procedimiento en DBeaver

1. Abro DBeaver y localizo la conexión correspondiente al motor con el que voy a trabajar.
2. Confirmo que la conexión esté activa y selecciono la base de datos o el esquema de la tabla PedalLibre. Para Oracle uso el esquema `PEDALIBRETERMINALDBEAVER`.
3. Abro un editor SQL asociado a esa conexión y verifico el nombre de la conexión/base antes de ejecutar cualquier comando.
4. Compruebo que existen las tablas del proyecto con el comando de inspección indicado para el motor. Si no aparecen `bicycles`, `rentals`, `payments` y las demás tablas del esquema, detengo la ejecución y corrijo la conexión o el esquema seleccionado.
5. Ejecuto una consulta a la vez: selecciono el bloque completo y uso **Ejecutar sentencia** en DBeaver. Las consultas de este informe son de solo lectura.
6. Reviso las filas devueltas en la cuadrícula de resultados. Las filas exactas pueden variar según los datos cargados en la base.
7. Debajo de cada bloque SQL encuentro la ruta de su captura pendiente. Tomo la imagen en DBeaver mostrando conexion, sentencia y resultado; la guardo con ese nombre en `trazabilidad/`. Despues completo lo que observe y aprendi basandome en las filas reales. Para empezar por MySQL, abro [consultas_mysql.sql](./consultas_mysql.sql) y ejecuto cada sentencia individualmente.

## Consultas principales

Los siguientes bloques son SQL compatible con los cuatro motores. Los ejecuto después de seleccionar la base o esquema correcto en DBeaver.

### 1. Consultar bicicletas disponibles

Reviso las bicicletas que están disponibles y ordeno el resultado por identificador.

```sql
SELECT bicycle_id, serial_number, bicycle_type, status
FROM bicycles
WHERE status = 'available'
ORDER BY bicycle_id;
```

**Evidencia de ejecucion:**
![DBeaver MySQL: bicicletas disponibles](trazabilidad/mysql_bicicletas_disponibles.png)
![DBeaver PostgreSQL: bicicletas disponibles](trazabilidad/postgresql_bicicletas_disponibles.png)
![DBeaver SQL Server: bicicletas disponibles](trazabilidad/sqlserver_bicicletas_disponibles.png)
![DBeaver Oracle: bicicletas disponibles](trazabilidad/oracle_bicicletas_disponibles.png)

**Lo que observe:** En las cuatro capturas, DBeaver muestra 80 filas recuperadas y todas corresponden a bicicletas con estado `available`.

**Lo que aprendi:** Aprendi que `WHERE` permite seleccionar solo las bicicletas disponibles y `ORDER BY` organiza su identificador.

### 2. Consultar alquileres completados

Aplico un filtro por estado y ordeno los alquileres desde el más reciente. La consulta devuelve todos los alquileres completados; las variantes para limitar a 10 resultados aparecen en la sección de cada motor.

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

**Evidencia de ejecucion:**
![DBeaver MySQL: alquileres completados](trazabilidad/mysql_alquileres_completados.png)
![DBeaver PostgreSQL: alquileres completados](trazabilidad/postgresql_alquileres_completados.png)
![DBeaver SQL Server: alquileres completados](trazabilidad/sqlserver_alquileres_completados.png)
![DBeaver Oracle: alquileres completados](trazabilidad/oracle_alquileres_completados.png)

**Lo que observe:** En las cuatro capturas, DBeaver muestra 67 alquileres con estado `completed`; las filas aparecen ordenadas por fecha de inicio descendente.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### 3. Consultar detalle de alquileres relacionados

Relaciono alquileres, clientes, bicicletas, tarifa y estaciones. Uso `LEFT JOIN` para conservar el alquiler aunque no tenga estación de inicio o fin asociada.

```sql
SELECT
    r.rental_id,
    c.first_name,
    c.last_name,
    b.serial_number,
    rate.name AS rate_name,
    start_station.name AS start_station,
    end_station.name AS end_station,
    r.started_at,
    r.ended_at,
    r.status,
    r.total_amount
FROM rentals r
JOIN clients c ON c.client_id = r.client_id
JOIN bicycles b ON b.bicycle_id = r.bicycle_id
JOIN rates rate ON rate.rate_id = r.rate_id
LEFT JOIN stations start_station ON start_station.station_id = r.start_station_id
LEFT JOIN stations end_station ON end_station.station_id = r.end_station_id
ORDER BY r.started_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, detalle alquileres relacionados](trazabilidad/mysql_detalle_alquileres_relacionados.png)
![Evidencia pendiente: PostgreSQL, detalle alquileres relacionados](trazabilidad/postgresql_detalle_alquileres_relacionados.png)
![Evidencia pendiente: SQL Server, detalle alquileres relacionados](trazabilidad/sqlserver_detalle_alquileres_relacionados.png)
![Evidencia pendiente: Oracle, detalle alquileres relacionados](trazabilidad/oracle_detalle_alquileres_relacionados.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi que puedo reunir datos relacionados con `JOIN` y conservar estaciones opcionales con `LEFT JOIN`.

### 4. Resumir alquileres por estado

Uso `GROUP BY` y funciones de agregado para comparar cantidad e importe promedio por estado. `HAVING` conserva los grupos que contienen al menos un alquiler.

```sql
SELECT
    status,
    COUNT(*) AS rental_count,
    SUM(total_amount) AS total_amount,
    AVG(total_amount) AS average_amount
FROM rentals
GROUP BY status
HAVING SUM(total_amount) > 0
ORDER BY status;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, resumen alquileres por estado](trazabilidad/mysql_resumen_alquileres_por_estado.png)
![Evidencia pendiente: PostgreSQL, resumen alquileres por estado](trazabilidad/postgresql_resumen_alquileres_por_estado.png)
![Evidencia pendiente: SQL Server, resumen alquileres por estado](trazabilidad/sqlserver_resumen_alquileres_por_estado.png)
![Evidencia pendiente: Oracle, resumen alquileres por estado](trazabilidad/oracle_resumen_alquileres_por_estado.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar alquileres por estado y resumirlos con `COUNT`, `SUM` y `AVG`.

### 5. Resumir pagos por método y estado

Consulto el número de pagos y el importe total agrupados por método y estado.

```sql
SELECT
    payment_method,
    status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_paid
FROM payments
GROUP BY payment_method, status
ORDER BY payment_method, status;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, resumen pagos por metodo estado](trazabilidad/mysql_resumen_pagos_por_metodo_estado.png)
![Evidencia pendiente: PostgreSQL, resumen pagos por metodo estado](trazabilidad/postgresql_resumen_pagos_por_metodo_estado.png)
![Evidencia pendiente: SQL Server, resumen pagos por metodo estado](trazabilidad/sqlserver_resumen_pagos_por_metodo_estado.png)
![Evidencia pendiente: Oracle, resumen pagos por metodo estado](trazabilidad/oracle_resumen_pagos_por_metodo_estado.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar pagos por metodo y estado para comparar cantidades e importes.

## Comandos específicos de cada motor

### MySQL

Conecto a la base indicada y verifico el esquema. Si la lista está vacía o no corresponde a PedalLibre, no continúo hasta seleccionar la base correcta.

```sql
SELECT DATABASE() AS base_actual;
```

La respuesta debe ser `Pedalibre-Terminal-Dbeaver`. Si aparece otro nombre, cambio la conexión activa en DBeaver antes de continuar.

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, base seleccionada](trazabilidad/mysql_base_seleccionada.png)

**Lo que observe:** Pendiente de anotar el nombre real de la base devuelta por DBeaver.

**Lo que aprendi:** Aprendi a comprobar la base activa antes de consultar sus tablas.

```sql
SHOW TABLES;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, inventario tablas mysql](trazabilidad/mysql_inventario_tablas_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a comprobar que tablas estan visibles en la base seleccionada de MySQL.

Para confirmar que se cargaron los datos de prueba, cuento las filas de las 21 tablas. La guía de inserción espera 100 registros en cada una; comparo ese valor con el resultado que realmente muestre DBeaver.

```sql
SELECT 'roles' AS tabla, COUNT(*) AS registros FROM roles
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'stations', COUNT(*) FROM stations
UNION ALL SELECT 'station_locations', COUNT(*) FROM station_locations
UNION ALL SELECT 'station_schedules', COUNT(*) FROM station_schedules
UNION ALL SELECT 'docking_points', COUNT(*) FROM docking_points
UNION ALL SELECT 'bicycles', COUNT(*) FROM bicycles
UNION ALL SELECT 'bicycle_dockings', COUNT(*) FROM bicycle_dockings
UNION ALL SELECT 'rates', COUNT(*) FROM rates
UNION ALL SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL SELECT 'rentals', COUNT(*) FROM rentals
UNION ALL SELECT 'rental_events', COUNT(*) FROM rental_events
UNION ALL SELECT 'penalties', COUNT(*) FROM penalties
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'incidents', COUNT(*) FROM incidents
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'bicycle_history', COUNT(*) FROM bicycle_history
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'invoices', COUNT(*) FROM invoices
ORDER BY tabla;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, conteo de registros por tabla](trazabilidad/mysql_conteo_registros.png)

**Lo que observe:** Pendiente de registrar los conteos reales. La semilla documenta 100 registros por tabla, pero los confirmo con este resultado.

**Lo que aprendi:** Aprendi a validar con `COUNT(*)` la cantidad de registros cargados antes de analizar los datos.

Para limitar la consulta de alquileres completados a 10 filas, agrego `LIMIT 10` al final:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, alquileres completados top10 mysql](trazabilidad/mysql_alquileres_completados_top10_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### PostgreSQL

Verifico las tablas visibles en el esquema `public`:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, inventario tablas postgresql](trazabilidad/postgresql_inventario_tablas_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a consultar el catalogo de PostgreSQL para verificar las tablas del esquema `public`.

Para limitar la consulta de alquileres completados a 10 filas, uso `LIMIT 10`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, alquileres completados top10 postgresql](trazabilidad/postgresql_alquileres_completados_top10_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Microsoft SQL Server

Verifico las tablas del esquema actual:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, inventario tablas postgresql](trazabilidad/sqlserver_inventario_tablas_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a consultar `INFORMATION_SCHEMA` para identificar las tablas del esquema de SQL Server.

Para limitar la consulta de alquileres completados a 10 filas, uso `TOP (10)`:

```sql
SELECT TOP (10)
    rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, alquileres completados top10 sqlserver](trazabilidad/sqlserver_alquileres_completados_top10_sqlserver.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Oracle

Verifico las tablas accesibles para el usuario conectado. Si el usuario tiene seleccionado el esquema `PEDALIBRETERMINALDBEAVER`, sus tablas aparecen en `USER_TABLES`.

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, inventario tablas oracle](trazabilidad/oracle_inventario_tablas_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a revisar las tablas que pertenecen al usuario/esquema Oracle conectado.

Para limitar la consulta de alquileres completados a 10 filas, uso `FETCH FIRST 10 ROWS ONLY`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
FETCH FIRST 10 ROWS ONLY;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, alquileres completados top10 oracle](trazabilidad/oracle_alquileres_completados_top10_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

## Consultas adicionales por motor

En esta sección agrego cuatro consultas para cada motor. Cubren clientes con más alquileres, disponibilidad de puntos por estación, incidentes abiertos e ingresos pagados por mes. Las consultas de cada sección pueden ejecutarse por separado en la conexión correspondiente.

### MySQL

#### Clientes con más alquileres

```sql
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS rental_count
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY rental_count DESC, c.client_id
LIMIT 5;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, clientes mas alquileres mysql](trazabilidad/mysql_clientes_mas_alquileres_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a combinar `LEFT JOIN`, `COUNT` y orden descendente para encontrar los clientes con mas alquileres, incluidos quienes aun no tienen uno.

#### Puntos de anclaje disponibles por estación

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    COUNT(dp.docking_point_id) AS docking_point_count,
    SUM(CASE WHEN dp.status = 'available' THEN 1 ELSE 0 END) AS available_points
FROM stations s
LEFT JOIN docking_points dp ON dp.station_id = s.station_id
GROUP BY s.station_id, s.name
ORDER BY s.station_id;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, puntos disponibles por estacion mysql](trazabilidad/mysql_puntos_disponibles_por_estacion_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a contar los puntos de anclaje de cada estacion y a usar `CASE` para contar los disponibles.

#### Incidentes abiertos

```sql
SELECT
    i.incident_id,
    i.severity,
    i.description,
    i.reported_at,
    b.serial_number,
    c.first_name,
    c.last_name
FROM incidents i
LEFT JOIN bicycles b ON b.bicycle_id = i.bicycle_id
LEFT JOIN clients c ON c.client_id = i.client_id
WHERE i.status = 'open'
ORDER BY i.reported_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, incidentes abiertos mysql](trazabilidad/mysql_incidentes_abiertos_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar incidentes abiertos y anadir datos opcionales de la bicicleta y del cliente con `LEFT JOIN`.

#### Ingresos pagados por mes

```sql
SELECT
    DATE_FORMAT(paid_at, '%Y-%m') AS payment_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_total
FROM payments
WHERE status = 'paid'
  AND paid_at IS NOT NULL
GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
ORDER BY payment_month;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: MySQL, ingresos pagados por mes mysql](trazabilidad/mysql_ingresos_pagados_por_mes_mysql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

### PostgreSQL

#### Clientes con más alquileres

```sql
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS rental_count
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY rental_count DESC, c.client_id
LIMIT 5;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, clientes mas alquileres postgresql](trazabilidad/postgresql_clientes_mas_alquileres_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a combinar `LEFT JOIN`, `COUNT` y orden descendente para encontrar los clientes con mas alquileres, incluidos quienes aun no tienen uno.

#### Puntos de anclaje disponibles por estación

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    COUNT(dp.docking_point_id) AS docking_point_count,
    SUM(CASE WHEN dp.status = 'available' THEN 1 ELSE 0 END) AS available_points
FROM stations s
LEFT JOIN docking_points dp ON dp.station_id = s.station_id
GROUP BY s.station_id, s.name
ORDER BY s.station_id;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, puntos disponibles por estacion postgresql](trazabilidad/postgresql_puntos_disponibles_por_estacion_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a contar los puntos de anclaje de cada estacion y a usar `CASE` para contar los disponibles.

#### Incidentes abiertos

```sql
SELECT
    i.incident_id,
    i.severity,
    i.description,
    i.reported_at,
    b.serial_number,
    c.first_name,
    c.last_name
FROM incidents i
LEFT JOIN bicycles b ON b.bicycle_id = i.bicycle_id
LEFT JOIN clients c ON c.client_id = i.client_id
WHERE i.status = 'open'
ORDER BY i.reported_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, incidentes abiertos postgresql](trazabilidad/postgresql_incidentes_abiertos_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar incidentes abiertos y anadir datos opcionales de la bicicleta y del cliente con `LEFT JOIN`.

#### Ingresos pagados por mes

```sql
SELECT
    TO_CHAR(paid_at, 'YYYY-MM') AS payment_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_total
FROM payments
WHERE status = 'paid'
  AND paid_at IS NOT NULL
GROUP BY TO_CHAR(paid_at, 'YYYY-MM')
ORDER BY payment_month;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: PostgreSQL, ingresos pagados por mes postgresql](trazabilidad/postgresql_ingresos_pagados_por_mes_postgresql.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

### Microsoft SQL Server

#### Clientes con más alquileres

```sql
SELECT TOP (5)
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS rental_count
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY rental_count DESC, c.client_id;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, clientes mas alquileres sqlserver](trazabilidad/sqlserver_clientes_mas_alquileres_sqlserver.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a combinar `LEFT JOIN`, `COUNT` y orden descendente para encontrar los clientes con mas alquileres, incluidos quienes aun no tienen uno.

#### Puntos de anclaje disponibles por estación

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    COUNT(dp.docking_point_id) AS docking_point_count,
    SUM(CASE WHEN dp.status = 'available' THEN 1 ELSE 0 END) AS available_points
FROM stations s
LEFT JOIN docking_points dp ON dp.station_id = s.station_id
GROUP BY s.station_id, s.name
ORDER BY s.station_id;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, puntos disponibles por estacion sqlserver](trazabilidad/sqlserver_puntos_disponibles_por_estacion_sqlserver.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a contar los puntos de anclaje de cada estacion y a usar `CASE` para contar los disponibles.

#### Incidentes abiertos

```sql
SELECT
    i.incident_id,
    i.severity,
    i.description,
    i.reported_at,
    b.serial_number,
    c.first_name,
    c.last_name
FROM incidents i
LEFT JOIN bicycles b ON b.bicycle_id = i.bicycle_id
LEFT JOIN clients c ON c.client_id = i.client_id
WHERE i.status = 'open'
ORDER BY i.reported_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, incidentes abiertos sqlserver](trazabilidad/sqlserver_incidentes_abiertos_sqlserver.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar incidentes abiertos y anadir datos opcionales de la bicicleta y del cliente con `LEFT JOIN`.

#### Ingresos pagados por mes

```sql
SELECT
    YEAR(paid_at) AS payment_year,
    MONTH(paid_at) AS payment_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_total
FROM payments
WHERE status = 'paid'
  AND paid_at IS NOT NULL
GROUP BY YEAR(paid_at), MONTH(paid_at)
ORDER BY payment_year, payment_month;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: SQL Server, ingresos pagados por mes sqlserver](trazabilidad/sqlserver_ingresos_pagados_por_mes_sqlserver.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

### Oracle

#### Clientes con más alquileres

```sql
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS rental_count
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY rental_count DESC, c.client_id
FETCH FIRST 5 ROWS ONLY;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, clientes mas alquileres oracle](trazabilidad/oracle_clientes_mas_alquileres_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a combinar `LEFT JOIN`, `COUNT` y orden descendente para encontrar los clientes con mas alquileres, incluidos quienes aun no tienen uno.

#### Puntos de anclaje disponibles por estación

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    COUNT(dp.docking_point_id) AS docking_point_count,
    SUM(CASE WHEN dp.status = 'available' THEN 1 ELSE 0 END) AS available_points
FROM stations s
LEFT JOIN docking_points dp ON dp.station_id = s.station_id
GROUP BY s.station_id, s.name
ORDER BY s.station_id;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, puntos disponibles por estacion oracle](trazabilidad/oracle_puntos_disponibles_por_estacion_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a contar los puntos de anclaje de cada estacion y a usar `CASE` para contar los disponibles.

#### Incidentes abiertos

```sql
SELECT
    i.incident_id,
    i.severity,
    i.description,
    i.reported_at,
    b.serial_number,
    c.first_name,
    c.last_name
FROM incidents i
LEFT JOIN bicycles b ON b.bicycle_id = i.bicycle_id
LEFT JOIN clients c ON c.client_id = i.client_id
WHERE i.status = 'open'
ORDER BY i.reported_at DESC;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, incidentes abiertos oracle](trazabilidad/oracle_incidentes_abiertos_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a filtrar incidentes abiertos y anadir datos opcionales de la bicicleta y del cliente con `LEFT JOIN`.

#### Ingresos pagados por mes

```sql
SELECT
    TO_CHAR(paid_at, 'YYYY-MM') AS payment_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_total
FROM payments
WHERE status = 'paid'
  AND paid_at IS NOT NULL
GROUP BY TO_CHAR(paid_at, 'YYYY-MM')
ORDER BY payment_month;
```

**Evidencia de ejecucion (captura pendiente):**
![Evidencia pendiente: Oracle, ingresos pagados por mes oracle](trazabilidad/oracle_ingresos_pagados_por_mes_oracle.png)

**Lo que observe:** Pendiente de completar despues de ejecutar la consulta: anotar las filas y valores que aparecen en DBeaver. No registrar datos antes de ver el resultado real.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

## Evidencia de trazabilidad

Debajo de cada consulta de este informe dejé su espacio de captura, seguido por los apartados **Lo que observé** y **Lo que aprendí**. Ya incorporé las capturas de bicicletas disponibles (80 filas) y alquileres completados (67 filas) para MySQL, PostgreSQL, SQL Server y Oracle. Las evidencias que todavía no se han ejecutado permanecen marcadas como pendientes. Cada captura muestra la conexión, el comando ejecutado y las filas devueltas; registro las observaciones a partir de esos resultados visibles.

Capturas agregadas a [trazabilidad/](./trazabilidad/):

- Bicicletas disponibles: `mysql_bicicletas_disponibles.png`, `postgresql_bicicletas_disponibles.png`, `sqlserver_bicicletas_disponibles.png` y `oracle_bicicletas_disponibles.png`.
- Alquileres completados: `mysql_alquileres_completados.png`, `postgresql_alquileres_completados.png`, `sqlserver_alquileres_completados.png` y `oracle_alquileres_completados.png`.

## Referencias

- [Guía docente de consultas MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/)
- [Guía docente de consultas PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/)
- [Guía docente de consultas Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/)
- [Guía docente de consultas Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/)
- [Guía del esquema PedalLibre](./Creacion%20de%20Tablas%20y%20Reguistros/guia.md)
- [Guia de insercion de datos](./Creacion%20de%20Tablas%20y%20Reguistros/guia_insert_datos.md)
- [Consultas MySQL para ejecutar en DBeaver](./consultas_mysql.sql)
