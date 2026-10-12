# Consultas SQL de PedalLibre en cuatro motores

## Introducción

En este informe documento las consultas que voy a ejecutar en DBeaver sobre las bases de datos de PedalLibre. Tomo como referencia los ejemplos de consulta de las guías docentes de [MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/), [PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/), [Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/) y [Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/), y adapto esos ejemplos a las tablas reales del proyecto.

Me concentro en consultas de lectura para revisar registros, filtrar resultados, relacionar tablas y resumir información. No vuelvo a crear ni modificar tablas o registros, y no incluyo triggers. Presento las consultas principales con sintaxis común a los cuatro motores y separo los límites de resultados cuando cambia la sintaxis.

## Base de datos y tablas

En la carpeta [Creacion de Tablas y Reguistros](./Creacion%20de%20Tablas%20y%20Reguistros/) consulté la guía del esquema y los scripts de datos de prueba. Identifiqué 21 tablas del dominio PedalLibre: `roles`, `users`, `clients`, `stations`, `station_locations`, `station_schedules`, `docking_points`, `bicycles`, `bicycle_dockings`, `reservations`, `rates`, `rentals`, `rental_events`, `penalties`, `maintenance`, `payments`, `incidents`, `notifications`, `bicycle_history`, `reviews` e `invoices`. Verifiqué en la guía de inserción y en la semilla MySQL la expectativa de 100 registros por tabla; tomo como base que los datos ya están cargados en los cuatro motores. En DBeaver validaré la base seleccionada y los conteos antes de empezar con las consultas.

Por tanto, consultaré las tablas adicionales del proyecto que identifiqué en sus archivos SQL, creadas sobre cada motor y no automáticamente al instalar MySQL, PostgreSQL, SQL Server u Oracle. Todavía no he abierto las conexiones locales para comprobar en vivo el estado actual de cada servidor.

### Conexiones que usaré

| Motor | Base de datos o esquema indicado |
|---|---|
| MySQL | `Pedalibre-Terminal-Dbeaver` |
| Microsoft SQL Server | `Pedalibre-Terminal-Dbeaver` |
| PostgreSQL | `Pedalibre-Terminal-Dbeaver` |
| Oracle | Esquema `PEDALIBRETERMINALDBEAVER` |

**MySQL:** Tomo de la guía del esquema y del script de datos de prueba el nombre de la base `Pedalibre-Terminal-Dbeaver`. Antes de ejecutar, confirmo con `SELECT DATABASE()` que esa sea la base seleccionada en DBeaver.

## Procedimiento en DBeaver

1. Abro DBeaver y localizo la conexión correspondiente al motor con el que voy a trabajar.
2. Confirmo que la conexión esté activa y selecciono la base de datos o el esquema de la tabla PedalLibre. Para Oracle uso el esquema `PEDALIBRETERMINALDBEAVER`.
3. Abro un editor SQL asociado a esa conexión y verifico el nombre de la conexión/base antes de ejecutar cualquier comando.
4. Compruebo que existen las tablas del proyecto con el comando de inspección indicado para el motor. Si no aparecen `bicycles`, `rentals`, `payments` y las demás tablas del esquema, detengo la ejecución y corrijo la conexión o el esquema seleccionado.
5. Ejecuto una consulta a la vez: selecciono el bloque completo y uso **Ejecutar sentencia** en DBeaver. Mantengo todas las consultas de este informe en modo de solo lectura.
6. Reviso las filas devueltas en la cuadrícula de resultados y tengo presente que pueden variar según los datos cargados en la base.
7. Debajo de cada bloque SQL identifico la ruta de la captura pendiente. Tomo en DBeaver una imagen que muestre conexión, sentencia y resultado, y la guardo con ese nombre en `trazabilidad/`. Después completo lo que observo y aprendo basándome en las filas reales. Para MySQL, ejecuto cada consulta de esta sección individualmente en DBeaver.

## Consultas principales

En los siguientes bloques presento SQL compatible con los cuatro motores. Los ejecuto después de seleccionar la base o esquema correcto en DBeaver.

### 1. Consultar bicicletas disponibles

Reviso las bicicletas que están disponibles y ordeno el resultado por identificador.

```sql
SELECT bicycle_id, serial_number, bicycle_type, status
FROM bicycles
WHERE status = 'available'
ORDER BY bicycle_id;
```

**Evidencia de ejecucion:**
**MySQL: Consultar bicicletas disponibles**
![MySQL: Consultar bicicletas disponibles](trazabilidad/mysql_bicicletas_disponibles.png)

**Retroalimentacion:** Con esta sentencia filtro `bicycles` por `status = 'available'` y ordeno por identificador. En la captura observo 80 filas recuperadas y todas tienen estado `available`.

**PostgreSQL: Consultar bicicletas disponibles**
![PostgreSQL: Consultar bicicletas disponibles](trazabilidad/postgresql_bicicletas_disponibles.png)

**Retroalimentacion:** Con esta sentencia filtro `bicycles` por `status = 'available'` y ordeno por identificador. En la captura observo 80 filas recuperadas y todas tienen estado `available`.

**SQL Server: Consultar bicicletas disponibles**
![SQL Server: Consultar bicicletas disponibles](trazabilidad/sqlserver_bicicletas_disponibles.png)

**Retroalimentacion:** Con esta sentencia filtro `bicycles` por `status = 'available'` y ordeno por identificador. En la captura observo 80 filas recuperadas y todas tienen estado `available`.

**Oracle: Consultar bicicletas disponibles**
![Oracle: Consultar bicicletas disponibles](trazabilidad/oracle_bicicletas_disponibles.png)

**Retroalimentacion:** Con esta sentencia filtro `bicycles` por `status = 'available'` y ordeno por identificador. En la captura observo 80 filas recuperadas y todas tienen estado `available`.

**Lo que aprendi:** Aprendi que `WHERE` permite seleccionar solo las bicicletas disponibles y `ORDER BY` organiza su identificador.

### 2. Consultar alquileres completados

Aplico un filtro por estado y ordeno los alquileres desde el más reciente. Con esta consulta obtengo todos los alquileres completados; en la sección de cada motor limito el resultado a 10 filas con la sintaxis correspondiente.

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

**Evidencia de ejecucion:**
**MySQL: Consultar alquileres completados**
![MySQL: Consultar alquileres completados](trazabilidad/mysql_alquileres_completados.png)

**Retroalimentacion:** Con esta sentencia filtro `rentals` por estado `completed` y ordeno los inicios en forma descendente. En la captura observo 67 alquileres completados, del más reciente al más antiguo.

**PostgreSQL: Consultar alquileres completados**
![PostgreSQL: Consultar alquileres completados](trazabilidad/postgresql_alquileres_completados.png)

**Retroalimentacion:** Con esta sentencia filtro `rentals` por estado `completed` y ordeno los inicios en forma descendente. En la captura observo 67 alquileres completados, del más reciente al más antiguo.

**SQL Server: Consultar alquileres completados**
![SQL Server: Consultar alquileres completados](trazabilidad/sqlserver_alquileres_completados.png)

**Retroalimentacion:** Con esta sentencia filtro `rentals` por estado `completed` y ordeno los inicios en forma descendente. En la captura observo 67 alquileres completados, del más reciente al más antiguo.

**Oracle: Consultar alquileres completados**
![Oracle: Consultar alquileres completados](trazabilidad/oracle_alquileres_completados.png)

**Retroalimentacion:** Con esta sentencia filtro `rentals` por estado `completed` y ordeno los inicios en forma descendente. En la captura observo 67 alquileres completados, del más reciente al más antiguo.

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

**Evidencia de ejecucion:**
**MySQL: Consultar detalle de alquileres relacionados**
![MySQL: Consultar detalle de alquileres relacionados](trazabilidad/mysql_detalle_alquileres_relacionados.png)

**Retroalimentacion:** En el resultado identifico el alquiler junto con el nombre del cliente, el serial de la bicicleta, la tarifa y las estaciones de inicio y fin. Observo 100 filas recuperadas; uso `JOIN` para combinar las entidades relacionadas y `LEFT JOIN` para conservar cada alquiler aunque alguna estación no esté asociada.

**PostgreSQL: Consultar detalle de alquileres relacionados**
![PostgreSQL: Consultar detalle de alquileres relacionados](trazabilidad/postgresql_detalle_alquileres_relacionados.png)

**Retroalimentacion:** En el resultado identifico el alquiler junto con el nombre del cliente, el serial de la bicicleta, la tarifa y las estaciones de inicio y fin. Observo 100 filas recuperadas; uso `JOIN` para combinar las entidades relacionadas y `LEFT JOIN` para conservar cada alquiler aunque alguna estación no esté asociada.

**SQL Server: Consultar detalle de alquileres relacionados**
![SQL Server: Consultar detalle de alquileres relacionados](trazabilidad/sqlserver_detalle_alquileres_relacionados.png)

**Retroalimentacion:** En el resultado identifico el alquiler junto con el nombre del cliente, el serial de la bicicleta, la tarifa y las estaciones de inicio y fin. Observo 100 filas recuperadas; uso `JOIN` para combinar las entidades relacionadas y `LEFT JOIN` para conservar cada alquiler aunque alguna estación no esté asociada.

**Oracle: Consultar detalle de alquileres relacionados**
![Oracle: Consultar detalle de alquileres relacionados](trazabilidad/oracle_detalle_alquileres_relacionados.png)

**Retroalimentacion:** En el resultado identifico el alquiler junto con el nombre del cliente, el serial de la bicicleta, la tarifa y las estaciones de inicio y fin. Observo 100 filas recuperadas; uso `JOIN` para combinar las entidades relacionadas y `LEFT JOIN` para conservar cada alquiler aunque alguna estación no esté asociada.

**Lo que aprendi:** Aprendi que puedo reunir datos relacionados con `JOIN` y conservar estaciones opcionales con `LEFT JOIN`.

### 4. Resumir alquileres por estado

Uso `GROUP BY` y funciones de agregado para comparar la cantidad y el importe promedio por estado. Con `HAVING` conservo los grupos cuyo importe total es mayor que cero.

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

**Evidencia de ejecucion:**
**MySQL: Resumir alquileres por estado**
![MySQL: Resumir alquileres por estado](trazabilidad/mysql_resumen_alquileres_por_estado.png)

**Retroalimentacion:** Agrupo los alquileres por estado y calculo la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**PostgreSQL: Resumir alquileres por estado**
![PostgreSQL: Resumir alquileres por estado](trazabilidad/postgresql_resumen_alquileres_por_estado.png)

**Retroalimentacion:** Agrupo los alquileres por estado y calculo la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**SQL Server: Resumir alquileres por estado**
![SQL Server: Resumir alquileres por estado](trazabilidad/sqlserver_resumen_alquileres_por_estado.png)

**Retroalimentacion:** Agrupo los alquileres por estado y calculo la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**Oracle: Resumir alquileres por estado**
![Oracle: Resumir alquileres por estado](trazabilidad/oracle_resumen_alquileres_por_estado.png)

**Retroalimentacion:** Agrupo los alquileres por estado y calculo la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

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

**Evidencia de ejecucion:**
**MySQL: Resumir pagos por metodo y estado**
![MySQL: Resumir pagos por metodo y estado](trazabilidad/mysql_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** Agrupo los pagos por método y estado y consulto la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**PostgreSQL: Resumir pagos por metodo y estado**
![PostgreSQL: Resumir pagos por metodo y estado](trazabilidad/postgresql_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** Agrupo los pagos por método y estado y consulto la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**SQL Server: Resumir pagos por metodo y estado**
![SQL Server: Resumir pagos por metodo y estado](trazabilidad/sqlserver_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** Agrupo los pagos por método y estado y consulto la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**Oracle: Resumir pagos por metodo y estado**
![Oracle: Resumir pagos por metodo y estado](trazabilidad/oracle_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** Agrupo los pagos por método y estado y consulto la cantidad y la suma de los importes. Observo 12 filas. Identifico `digital_wallet` en una fila y `digital_Wallet` en otra; al distinguir la capitalización, Oracle separa esas variantes en grupos distintos.

**Lo que aprendi:** Aprendi a agrupar pagos por metodo y estado para comparar cantidades e importes.

## Comandos específicos de cada motor

### MySQL

Me conecto a la base indicada y verifico el esquema. Si la lista está vacía o no corresponde a PedalLibre, no continúo hasta seleccionar la base correcta.

```sql
SELECT DATABASE() AS base_actual;
```

Compruebo que la respuesta sea `Pedalibre-Terminal-Dbeaver`. Si observo otro nombre, cambio la conexión activa en DBeaver antes de continuar.

**Evidencia de ejecucion:**
**MySQL: Verificar la base de datos activa**
![MySQL: Verificar la base de datos activa](trazabilidad/mysql_base_seleccionada.png)

**Retroalimentacion:** Con `SELECT DATABASE()` identifico la base MySQL activa en esta conexión. Observo `Pedalibre-Terminal-Dbeaver` y confirmo que ejecuto la consulta en la base indicada.

**Lo que aprendi:** Aprendi a comprobar la base activa antes de consultar sus tablas.

```sql
SHOW TABLES;
```

**Evidencia de ejecucion:**
**MySQL: Verificar las tablas de la base**
![MySQL: Verificar las tablas de la base](trazabilidad/mysql_inventario_tablas_mysql.png)

**Retroalimentacion:** Uso `SHOW TABLES` para listar las tablas visibles en la base MySQL seleccionada, sin consultar sus registros. Observo 21 tablas del proyecto, entre ellas `bicycles`, `clients`, `payments` y `rentals`, y confirmo que el esquema esperado está visible en DBeaver.

**Lo que aprendi:** Aprendi a comprobar que tablas estan visibles en la base seleccionada de MySQL.

Para confirmar la carga de los datos de prueba, cuento las filas de las 21 tablas. Tomo como referencia los 100 registros por tabla indicados en la guía de inserción y comparo ese valor con el resultado que me muestra DBeaver.

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

**Evidencia de ejecucion:**
**MySQL: Contar registros por tabla**
![MySQL: Contar registros por tabla](trazabilidad/mysql_conteo_registros.png)

**Retroalimentacion:** Cuento las filas de cada una de las 21 tablas. Observo que cada tabla muestra 100 registros, coincidiendo con la cantidad esperada en la guía de inserción.

**Lo que aprendi:** Aprendi a validar con `COUNT(*)` la cantidad de registros cargados antes de analizar los datos.

Para limitar los alquileres completados a 10 filas, agrego `LIMIT 10` al final de la consulta:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

**Evidencia de ejecucion:**
**MySQL: Mostrar los 10 alquileres completados mas recientes**
![MySQL: Mostrar los 10 alquileres completados mas recientes](trazabilidad/mysql_alquileres_completados_top10_mysql.png)

**Retroalimentacion:** Con `LIMIT 10` restrinjo la salida a los 10 alquileres completados más recientes, ordenados por fecha de inicio descendente. Observo diez filas con estado `completed`; identifico la primera como el registro más reciente mostrado.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### PostgreSQL

Verifico qué tablas están visibles en el esquema `public`:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Evidencia de ejecucion:**
**PostgreSQL: Verificar las tablas de la base**
![PostgreSQL: Verificar las tablas de la base](trazabilidad/postgresql_inventario_tablas_postgresql.png)

**Retroalimentacion:** Consulto el catálogo `information_schema.tables` y filtro el esquema `public` para mostrar solo tablas base. Observo las 21 tablas del proyecto PedalLibre.

**Lo que aprendi:** Aprendi a consultar el catalogo de PostgreSQL para verificar las tablas del esquema `public`.

Para limitar la consulta de alquileres completados a 10 filas, uso `LIMIT 10`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

**Evidencia de ejecucion:**
**PostgreSQL: Mostrar los 10 alquileres completados mas recientes**
![PostgreSQL: Mostrar los 10 alquileres completados mas recientes](trazabilidad/postgresql_alquileres_completados_top10_postgresql.png)

**Retroalimentacion:** Con `LIMIT 10` limito la salida a los 10 alquileres completados con fecha de inicio más reciente. Observo diez filas, todas con estado `completed`, ordenadas por `started_at` descendente.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Microsoft SQL Server

Verifico qué tablas pertenecen al esquema actual:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

**Evidencia de ejecucion:**
**SQL Server: Verificar las tablas de la base**
![SQL Server: Verificar las tablas de la base](trazabilidad/sqlserver_inventario_tablas_sqlserver.png)

**Retroalimentacion:** Consulto `INFORMATION_SCHEMA.TABLES` para ver el esquema y el nombre de cada tabla base. Observo las 21 tablas del proyecto bajo el esquema `dbo`.

**Lo que aprendi:** Aprendi a consultar `INFORMATION_SCHEMA` para identificar las tablas del esquema de SQL Server.

Para limitar la consulta de alquileres completados a 10 filas, uso `TOP (10)`:

```sql
SELECT TOP (10)
    rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

**Evidencia de ejecucion:**
**SQL Server: Mostrar los 10 alquileres completados mas recientes**
![SQL Server: Mostrar los 10 alquileres completados mas recientes](trazabilidad/sqlserver_alquileres_completados_top10_sqlserver.png)

**Retroalimentacion:** Con `TOP (10)` limito la salida a diez alquileres completados, ordenados por fecha de inicio descendente. Observo diez filas y confirmo que todos muestran el estado `completed`.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Oracle

Verifico las tablas accesibles con mi usuario conectado. Al conectarme al esquema `PEDALIBRETERMINALDBEAVER`, consulto sus tablas en `USER_TABLES`.

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

**Evidencia de ejecucion:**
**Oracle: Verificar las tablas de la base**
![Oracle: Verificar las tablas de la base](trazabilidad/oracle_inventario_tablas_oracle.png)

**Retroalimentacion:** Consulto `USER_TABLES` para listar las tablas que pertenecen al usuario conectado. Observo las 21 tablas de PedalLibre en el esquema `PEDALIBRETERMINALDBEAVER`.

**Lo que aprendi:** Aprendi a revisar las tablas que pertenecen al usuario/esquema Oracle conectado.

Para limitar la consulta de alquileres completados a 10 filas, uso `FETCH FIRST 10 ROWS ONLY`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
FETCH FIRST 10 ROWS ONLY;
```

**Evidencia de ejecucion:**
**Oracle: Mostrar los 10 alquileres completados mas recientes**
![Oracle: Mostrar los 10 alquileres completados mas recientes](trazabilidad/oracle_alquileres_completados_top10_oracle.png)

**Retroalimentacion:** Con `FETCH FIRST 10 ROWS ONLY` limito la salida a diez alquileres completados, ordenados por fecha de inicio descendente. Observo diez filas y confirmo que todas tienen estado `completed`.

**Lo que aprendi:** Aprendi que Oracle puede limitar filas con `FETCH FIRST`, mientras que PostgreSQL usa `LIMIT` y SQL Server usa `TOP`.

**Retroalimentacion:** Con `LIMIT 10` restrinjo la salida a los 10 alquileres completados más recientes. Dejo pendiente la captura de la ejecución y el resultado de esta variante.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

## Consultas adicionales por motor

En esta sección presento análisis propios de cada motor. Ya ejecuté las consultas adicionales de MySQL; para PostgreSQL, SQL Server y Oracle seleccioné temas y funciones diferentes, sin repetir los análisis de las otras secciones. Ejecuto cada grupo solo en la conexión indicada.

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

**Evidencia de ejecucion:**
**MySQL: Identificar clientes con mas alquileres**
![MySQL: Identificar clientes con mas alquileres](trazabilidad/mysql_clientes_mas_alquileres_mysql.png)

**Retroalimentacion:** Cuento los alquileres por cliente y consulto los cinco valores más altos; con `LEFT JOIN` también conservo a los clientes sin alquileres. En el resultado observo cinco clientes con un alquiler cada uno; el desempate por `client_id` los ordena de forma ascendente.

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

**Evidencia de ejecucion:**
**MySQL: Contar anclajes disponibles por estacion**
![MySQL: Contar anclajes disponibles por estacion](trazabilidad/mysql_puntos_disponibles_por_estacion_mysql.png)

**Retroalimentacion:** Agrupo los puntos de anclaje por estación, cuento los puntos asociados y sumo los disponibles con `CASE`. En la captura observo 100 filas; en las estaciones visibles identifico un punto asociado por estación y `available_points` vale 0 o 1 según su estado.

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

**Evidencia de ejecucion:**
**MySQL: Consultar incidentes abiertos**
![MySQL: Consultar incidentes abiertos](trazabilidad/mysql_incidentes_abiertos_mysql.png)

**Retroalimentacion:** Filtro los incidentes `open` y uso `LEFT JOIN` para añadir los datos de bicicleta y cliente cuando están asociados. En la cuadrícula observo 25 filas con distintos niveles de severidad y las descripciones de los incidentes.

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

**Evidencia de ejecucion:**
**MySQL: Resumir pagos realizados por mes**
![MySQL: Resumir pagos realizados por mes](trazabilidad/mysql_ingresos_pagados_por_mes_mysql.png)

**Retroalimentacion:** Selecciono los pagos con estado `paid` y fecha registrada, los agrupo por mes con `DATE_FORMAT` y sumo sus importes. Observo 71 pagos de octubre de 2026 y un total mensual de 568.145.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

### PostgreSQL

#### Volumen semanal de alquileres

```sql
SELECT
    date_trunc('week', started_at)::date AS week_start,
    COUNT(*) AS rental_count,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed_count,
    COALESCE(SUM(total_amount) FILTER (WHERE status = 'completed'), 0) AS completed_amount
FROM rentals
GROUP BY date_trunc('week', started_at)::date
ORDER BY week_start;
```

**Evidencia de ejecucion:**
**PostgreSQL: Resumir alquileres por semana**
![PostgreSQL: Resumir alquileres por semana](trazabilidad/postgresql_alquileres_por_semana.png)

**Retroalimentacion:** Uso `date_trunc('week', ...)` para agrupar las fechas por semana y agregados con `FILTER` para separar el total de alquileres de los completados y sumar el importe completado. Observo una semana que inicia el 5 de octubre de 2026, con 100 alquileres, 67 completados y un importe de 528.213.

**Lo que aprendi:** Aprendere a usar `date_trunc` y agregados filtrados para analizar la actividad semanal en PostgreSQL.

#### Tiempo promedio de uso de anclajes por estación

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    COUNT(bd.bicycle_docking_id) AS completed_dockings,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (bd.undocked_at - bd.docked_at)) / 60)::numeric,
        2
    ) AS average_docking_minutes
FROM stations s
JOIN docking_points dp ON dp.station_id = s.station_id
JOIN bicycle_dockings bd ON bd.docking_point_id = dp.docking_point_id
WHERE bd.undocked_at IS NOT NULL
GROUP BY s.station_id, s.name
ORDER BY average_docking_minutes DESC, s.station_id;
```

**Evidencia de ejecucion:**
**PostgreSQL: Calcular tiempo de uso de anclajes**
![PostgreSQL: Calcular tiempo de uso de anclajes](trazabilidad/postgresql_tiempo_uso_anclajes.png)

**Retroalimentacion:** Selecciono los acoplamientos que ya tienen hora de retiro, calculo su duración en minutos con `EXTRACT(EPOCH ...)` y obtengo el promedio por estación. Observo 33 estaciones con acoplamientos completados; en el resultado visible cada una tiene un acoplamiento de 25 minutos.

**Lo que aprendi:** Aprendere a restar marcas de tiempo en PostgreSQL y convertir el intervalo a minutos para comparar el uso de estaciones.

#### Buscar reportes de revisión con `ILIKE`

```sql
SELECT
    i.incident_id,
    i.severity,
    i.description,
    i.reported_at
FROM incidents i
WHERE i.description ILIKE '%revision%'
ORDER BY i.reported_at DESC;
```

**Evidencia de ejecucion:**
**PostgreSQL: Buscar reportes de revisión**
![PostgreSQL: Buscar reportes de revisión](trazabilidad/postgresql_incidentes_revision_ilike.png)

**Retroalimentacion:** Uso `ILIKE` para buscar el texto `revision` sin distinguir entre mayúsculas y minúsculas. Observo 25 incidentes en la cuadrícula, con severidades `low`, `medium` y `high`, y descripciones que mencionan revisiones de bicicletas.

**Lo que aprendi:** Aprendere a usar `ILIKE` de PostgreSQL para realizar una busqueda de texto sin sensibilidad a mayusculas.

#### Evolución mensual de las calificaciones

```sql
SELECT
    date_trunc('month', created_at)::date AS review_month,
    COUNT(*) AS review_count,
    ROUND(AVG(rating)::numeric, 2) AS average_rating,
    MIN(rating) AS lowest_rating,
    MAX(rating) AS highest_rating
FROM reviews
GROUP BY date_trunc('month', created_at)::date
ORDER BY review_month;
```

**Evidencia de ejecucion:**
**PostgreSQL: Resumir calificaciones por mes**
![PostgreSQL: Resumir calificaciones por mes](trazabilidad/postgresql_calificaciones_por_mes.png)

**Retroalimentacion:** Agrupo las reseñas por mes con `date_trunc` y calculo su cantidad, promedio, calificación mínima y máxima. Observo 100 reseñas para octubre de 2026, promedio de 3, calificación mínima de 1 y máxima de 5.

**Lo que aprendi:** Aprendere a resumir la evolucion de las calificaciones usando agrupacion temporal nativa de PostgreSQL.

### Microsoft SQL Server

#### Distribución de bicicletas con `PIVOT`

```sql
SELECT bicycle_type, [available], [reserved], [maintenance]
FROM (
    SELECT bicycle_type, status, bicycle_id
    FROM dbo.bicycles
) AS bicycle_statuses
PIVOT (
    COUNT(bicycle_id)
    FOR status IN ([available], [reserved], [maintenance])
) AS bicycle_summary
ORDER BY bicycle_type;
```

**Evidencia de ejecucion:**
**SQL Server: Comparar estados de bicicletas con PIVOT**
![SQL Server: Comparar estados de bicicletas con PIVOT](trazabilidad/sqlserver_bicicletas_por_estado_pivot.png)

**Retroalimentacion:** Uso `PIVOT` para convertir los estados seleccionados en columnas y contar las bicicletas de cada tipo en cada estado. Observo 20 bicicletas disponibles por cada tipo; `electric` y `mountain` tienen 5 en mantenimiento, mientras `standard` y `urban` tienen 5 reservadas.

**Lo que aprendi:** Aprendere a usar `PIVOT` en SQL Server para convertir valores de filas en columnas de resumen.

#### Inventario de estaciones en JSON

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    JSON_QUERY((
        SELECT dp.docking_point_id, dp.code, dp.status
        FROM dbo.docking_points AS dp
        WHERE dp.station_id = s.station_id
        ORDER BY dp.docking_point_id
        FOR JSON PATH
    )) AS docking_points_json
FROM dbo.stations AS s
ORDER BY s.station_id
FOR JSON PATH;
```

**Evidencia de ejecucion:**
**SQL Server: Exportar inventario de estaciones a JSON**
![SQL Server: Exportar inventario de estaciones a JSON](trazabilidad/sqlserver_estaciones_json.png)

**Retroalimentacion:** Uso `FOR JSON PATH` para obtener las estaciones con sus anclajes en un arreglo JSON anidado, y `JSON_QUERY` para conservar ese arreglo como JSON en vez de escaparlo como texto. Observo ocho filas JSON en la cuadrícula, cada una con la estación y el detalle de sus puntos de anclaje.

**Lo que aprendi:** Aprendere a usar `FOR JSON PATH` de SQL Server para representar registros relacionados como JSON anidado.

#### Clasificar facturas y validar el impuesto

```sql
SELECT
    invoice_id,
    invoice_number,
    subtotal,
    tax,
    total,
    CAST(100.0 * tax / NULLIF(subtotal, 0) AS DECIMAL(6, 2)) AS tax_percent,
    total - subtotal - tax AS difference
FROM dbo.invoices
ORDER BY invoice_id;
```

**Evidencia de ejecucion:**
**SQL Server: Revisar importes e impuesto de facturas**
![SQL Server: Revisar importes e impuesto de facturas](trazabilidad/sqlserver_validar_impuestos_facturas.png)

**Retroalimentacion:** Calculo el porcentaje de impuesto y compruebo la diferencia entre total, subtotal e impuesto. En las 100 facturas observo un impuesto de 19 % y un valor de 0 en `difference`, por lo que confirmo que los importes coinciden con la suma de subtotal e impuesto.

**Lo que aprendi:** Aprendere a validar importes calculados y a evitar division entre cero con `NULLIF` en SQL Server.

#### Comparar el importe de alquileres consecutivos

```sql
WITH rental_comparison AS (
    SELECT
        rental_id,
        client_id,
        started_at,
        total_amount,
        LAG(total_amount) OVER (
            PARTITION BY client_id
            ORDER BY started_at, rental_id
        ) AS previous_amount
    FROM dbo.rentals
    WHERE status = 'completed'
)
SELECT TOP (20)
    client_id,
    rental_id,
    started_at,
    previous_amount,
    total_amount,
    total_amount - previous_amount AS amount_difference
FROM rental_comparison
WHERE previous_amount IS NOT NULL
ORDER BY client_id, started_at, rental_id;
```

**Evidencia de ejecucion:**
**SQL Server: Comparar importes consecutivos por cliente**
![SQL Server: Comparar importes consecutivos por cliente](trazabilidad/sqlserver_comparar_importes_alquileres_lag.png)

**Retroalimentacion:** Uso `LAG` para buscar el importe del alquiler completado anterior de cada cliente. En la captura observo una cuadrícula sin filas (`No data`), así que concluyo que estos datos no contienen pares de alquileres completados del mismo cliente para calcular esa diferencia.

**Lo que aprendi:** Aprendere a comparar registros consecutivos por cliente con la funcion de ventana `LAG`.

### Oracle

#### Rendimiento de las tarifas utilizadas

```sql
SELECT
    rt.rate_id,
    rt.name AS rate_name,
    rt.billing_unit,
    COUNT(r.rental_id) AS rental_count,
    COUNT(CASE WHEN r.status = 'completed' THEN 1 END) AS completed_count,
    NVL(SUM(CASE WHEN r.status = 'completed' THEN r.total_amount END), 0) AS completed_revenue
FROM rates rt
LEFT JOIN rentals r ON r.rate_id = rt.rate_id
GROUP BY rt.rate_id, rt.name, rt.billing_unit
ORDER BY completed_revenue DESC, rt.rate_id;
```

**Evidencia de ejecucion:**
**Oracle: Resumir uso e ingresos por tarifa**
![Oracle: Resumir uso e ingresos por tarifa](trazabilidad/oracle_rendimiento_tarifas.png)

**Retroalimentacion:** Relaciono cada tarifa con sus alquileres, cuento los completados y sumo sus importes. Observo 100 tarifas; en las filas visibles cada tarifa tiene un alquiler completado, y los ingresos varían según el plan.

**Lo que aprendi:** Aprendere a usar `NVL` y agregados condicionales de Oracle para comparar el uso y los ingresos de cada tarifa.

#### Generar calendario diario de alquileres con `CONNECT BY`

```sql
WITH date_bounds AS (
    SELECT TRUNC(MIN(started_at)) AS first_day,
           TRUNC(MAX(started_at)) AS last_day
    FROM rentals
),
calendar AS (
    SELECT first_day + LEVEL - 1 AS rental_day
    FROM date_bounds
    CONNECT BY LEVEL <= last_day - first_day + 1
)
SELECT
    c.rental_day,
    COUNT(r.rental_id) AS rental_count
FROM calendar c
LEFT JOIN rentals r ON TRUNC(r.started_at) = c.rental_day
GROUP BY c.rental_day
ORDER BY c.rental_day;
```

**Evidencia de ejecucion:**
**Oracle: Generar calendario de alquileres por día**
![Oracle: Generar calendario de alquileres por día](trazabilidad/oracle_calendario_diario_connect_by.png)

**Retroalimentacion:** Uso `CONNECT BY LEVEL` para generar una fila por fecha entre el primer y el último alquiler. Observo tres días: 9 de octubre de 2026 con 2 alquileres, 10 de octubre con 54 y 11 de octubre con 44.

**Lo que aprendi:** Aprendere a generar una secuencia de fechas en Oracle mediante la jerarquia `CONNECT BY`.

#### Resumen de incidentes por severidad con `ROLLUP`

```sql
SELECT
    CASE
        WHEN GROUPING(severity) = 1 THEN 'TOTAL'
        ELSE severity
    END AS severity_group,
    COUNT(*) AS incident_count
FROM incidents
GROUP BY ROLLUP(severity)
ORDER BY GROUPING(severity), severity_group;
```

**Evidencia de ejecucion:**
**Oracle: Resumir incidentes por severidad**
![Oracle: Resumir incidentes por severidad](trazabilidad/oracle_incidentes_rollup_severidad.png)

**Retroalimentacion:** Uso `ROLLUP` para calcular el conteo por severidad y añadir el total general; con `GROUPING` identifico esa última fila como `TOTAL`. Observo 33 incidentes `high`, 33 `low`, 34 `medium` y 100 en total.

**Lo que aprendi:** Aprendere a usar `ROLLUP` y `GROUPING` en Oracle para obtener subtotales y un total general.

#### Participación de ingresos por tipo de bicicleta con `RATIO_TO_REPORT`

```sql
SELECT
    b.bicycle_type,
    COUNT(*) AS completed_rentals,
    SUM(r.total_amount) AS total_revenue,
    ROUND(RATIO_TO_REPORT(SUM(r.total_amount)) OVER () * 100, 2) AS revenue_percentage
FROM rentals r
JOIN bicycles b ON b.bicycle_id = r.bicycle_id
WHERE r.status = 'completed'
GROUP BY b.bicycle_type
ORDER BY total_revenue DESC, b.bicycle_type;
```

**Evidencia de ejecucion:**
**Oracle: Calcular participación de ingresos por bicicleta**
![Oracle: Calcular participación de ingresos por bicicleta](trazabilidad/oracle_participacion_ingresos_bicicletas.png)

**Retroalimentacion:** Uso `RATIO_TO_REPORT` para calcular la participación de cada tipo en los ingresos de alquileres completados. Observo 17 alquileres `standard` con 145.779 (27,60 %), 17 `mountain` con 138.758 (26,27 %), 17 `electric` con 124.084 (23,49 %) y 16 `urban` con 119.592 (22,64 %).

**Lo que aprendi:** Aprendere a calcular participaciones porcentuales de grupos con la funcion analitica `RATIO_TO_REPORT` de Oracle.

## Consultas avanzadas por motor

Además de las consultas comunes, presento ejemplos avanzados que aprovechan funciones propias de cada motor, como agregados filtrados, funciones analíticas, CTE, `PIVOT`, JSON y generación de series. Ejecuto cada consulta solo en el motor indicado; debajo registro la captura y lo que observo, y dejo pendiente la evidencia de las consultas que todavía no ejecuto.

### MySQL: agrupar alquileres con `GROUP_CONCAT`

Con esta consulta resumo los alquileres de cada cliente y concateno sus identificadores, ordenados del más reciente al más antiguo.

```sql
SELECT
    c.client_id,
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    COUNT(r.rental_id) AS rental_count,
    GROUP_CONCAT(r.rental_id ORDER BY r.started_at DESC SEPARATOR ', ') AS rental_ids
FROM clients c
JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY rental_count DESC, c.client_id
LIMIT 10;
```

**Evidencia de ejecucion:**
**MySQL: Listar alquileres por cliente con GROUP_CONCAT**
![MySQL: Listar alquileres por cliente con GROUP_CONCAT](trazabilidad/mysql_alquileres_por_cliente_group_concat.png)

**Retroalimentacion:** Uso `GROUP_CONCAT` para combinar los identificadores de alquiler en una cadena por cliente. Observo diez clientes en el resultado; cada uno tiene un alquiler y la columna `rental_ids` contiene su identificador.

**Lo que aprendi:** Aprendere a usar `GROUP_CONCAT` de MySQL para resumir varios registros relacionados en una sola fila.

### PostgreSQL: comparar estados de pago con `FILTER`

Con esta consulta comparo, en una fila por método, el número de pagos pagados, pendientes y reembolsados, y sumo el importe pagado.

```sql
SELECT
    payment_method,
    COUNT(*) FILTER (WHERE status = 'paid') AS paid_count,
    COUNT(*) FILTER (WHERE status = 'pending') AS pending_count,
    COUNT(*) FILTER (WHERE status = 'refunded') AS refunded_count,
    COALESCE(SUM(amount) FILTER (WHERE status = 'paid'), 0) AS paid_total
FROM payments
GROUP BY payment_method
ORDER BY payment_method;
```

**Evidencia de ejecucion:**
**PostgreSQL: Comparar estados de pago con FILTER**
![PostgreSQL: Comparar estados de pago con FILTER](trazabilidad/postgresql_pagos_por_estado_filter.png)

**Retroalimentacion:** Uso `FILTER` para calcular conteos e importes por estado en una sola agrupación. Observo cuatro métodos: tarjeta de crédito con 18 pagos, 3 pendientes, 4 reembolsados y total pagado 135.816; débito con 18, 3, 4 y 156.078; billetera digital con 17, 4, 4 y 132.563; PSE con 18, 4, 3 y 143.688.

**Lo que aprendi:** Aprendere a filtrar cada agregado de PostgreSQL sin separar el resultado en varias consultas.

### PostgreSQL: obtener el último alquiler de cada cliente

Con esta consulta obtengo la fecha del alquiler más reciente y uso una subconsulta correlacionada para recuperar su importe; al final limito la salida a diez clientes.

```sql
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    MAX(r.started_at) AS latest_rental_at,
    (
        SELECT r2.total_amount
        FROM rentals r2
        WHERE r2.client_id = c.client_id
        ORDER BY r2.started_at DESC NULLS LAST
        LIMIT 1
    ) AS latest_rental_amount
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY latest_rental_at DESC NULLS LAST, c.client_id
FETCH FIRST 10 ROWS ONLY;
```

**Evidencia de ejecucion:**
**PostgreSQL: Consultar el último alquiler de cada cliente**
![PostgreSQL: Consultar el último alquiler de cada cliente](trazabilidad/postgresql_ultimo_alquiler_por_cliente.png)

**Retroalimentacion:** Ordeno los clientes por la fecha de su alquiler más reciente y uso la subconsulta para buscar el importe de ese alquiler. Observo diez clientes; identifico en la primera fila al cliente 40, Samuel Lopez, con fecha 11 de octubre de 2026 a las 14:25 y un importe de 1.820.

**Lo que aprendi:** Aprendi a combinar una agregacion por cliente con una subconsulta correlacionada y `LIMIT 1` para recuperar un valor de su registro mas reciente.

### SQL Server: duración media de alquiler por tipo de bicicleta

Con esta consulta uso `DATEDIFF` para calcular la duración en minutos de los alquileres completados y promedio el resultado por tipo de bicicleta.

```sql
SELECT
    b.bicycle_type,
    COUNT(*) AS rental_count,
    AVG(CAST(DATEDIFF(MINUTE, r.started_at, r.ended_at) AS decimal(10, 2))) AS average_duration_minutes
FROM rentals r
JOIN bicycles b ON b.bicycle_id = r.bicycle_id
WHERE r.status = 'completed'
  AND r.ended_at IS NOT NULL
GROUP BY b.bicycle_type
ORDER BY average_duration_minutes DESC, b.bicycle_type;
```

**Evidencia de ejecucion:**
**SQL Server: Calcular duracion promedio con DATEDIFF**
![SQL Server: Calcular duracion promedio con DATEDIFF](trazabilidad/sqlserver_duracion_alquiler_por_tipo_datediff.png)

**Retroalimentacion:** Uso `DATEDIFF(MINUTE, ...)` para medir los minutos entre el inicio y el fin. Observo 17 alquileres completados para `electric`, `mountain` y `standard`, y 16 para `urban`; calculo un promedio de duración de 60 minutos para cada tipo.

**Lo que aprendi:** Aprendere a calcular intervalos de tiempo con `DATEDIFF` de SQL Server y a resumirlos por categoria.

### Oracle: obtener el importe del alquiler más reciente con `KEEP`

Con esta consulta conservo a todos los clientes y recupero la fecha y el importe de su alquiler más reciente. Si hay empate de fechas, `MAX` me devuelve el importe mayor entre los alquileres empatados.

```sql
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    MAX(r.started_at) AS latest_rental_at,
    MAX(r.total_amount) KEEP (DENSE_RANK LAST ORDER BY r.started_at) AS latest_rental_amount
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY latest_rental_at DESC NULLS LAST, c.client_id
FETCH FIRST 10 ROWS ONLY;
```

**Evidencia de ejecucion:**
**Oracle: Recuperar el alquiler mas reciente con KEEP**
*Captura pendiente: `oracle_alquiler_mas_reciente_keep.png`.*

**Retroalimentacion:** Uso la función de agregado `KEEP (DENSE_RANK LAST ...)` para obtener el importe asociado a la fecha máxima de alquiler por cliente. Con `LEFT JOIN` conservo a los clientes sin alquileres, que aparecerán con fecha e importe nulos. Anotaré las filas reales después de ejecutar la consulta.

**Lo que aprendi:** Aprendere a usar `KEEP` y `DENSE_RANK` en Oracle para recuperar una medida de la fila que ocupa la posicion mas reciente dentro de cada grupo.

## Procedimientos parametrizados de las consultas avanzadas

### MySQL: `GROUP_CONCAT`

<a id="sp-avanzada-mysql-group-concat"></a>

Parametrizo cuántos clientes muestro y mantengo el orden descendente de sus alquileres concatenados. En DBeaver ejecuto la consulta avanzada original, creo el procedimiento desde el editor de procedimientos y comparo la llamada con diez clientes.

**Paso a paso:** 1. Selecciono MySQL y ejecuto la consulta `GROUP_CONCAT`; 2. abro el editor de procedimientos de DBeaver y creo `sp_alquileres_por_cliente`; 3. agrego el parámetro `p_cantidad_clientes` de tipo `INT`; 4. pego el cuerpo de la consulta en el editor y guardo el procedimiento; 5. ejecuto `CALL sp_alquileres_por_cliente(10);` desde el editor SQL y comparo los clientes, conteos e identificadores concatenados.

```sql
CREATE PROCEDURE sp_alquileres_por_cliente(
    IN p_cantidad_clientes INT
)
SELECT
    c.client_id,
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    COUNT(r.rental_id) AS rental_count,
    GROUP_CONCAT(
        r.rental_id
        ORDER BY r.started_at DESC
        SEPARATOR ', '
    ) AS rental_ids
    FROM clients c
    INNER JOIN rentals r
        ON r.client_id = c.client_id
GROUP BY
    c.client_id,
    c.first_name,
    c.last_name
ORDER BY
    rental_count DESC,
    c.client_id
LIMIT p_cantidad_clientes;
```

Después de guardar el procedimiento en el editor de procedimientos, ejecuto la llamada en el editor SQL:

```sql
CALL sp_alquileres_por_cliente(10);
```

**Evidencia de creación:**
**MySQL: Crear `sp_alquileres_por_cliente` en el editor de procedimientos de DBeaver**
![MySQL: Crear sp_alquileres_por_cliente en el editor de procedimientos de DBeaver](trazabilidad/mysql_sp_alquileres_por_cliente_creacion.png)

**Evidencia de ejecución:**
**MySQL: Ejecutar `sp_alquileres_por_cliente` con límite de diez clientes**
![MySQL: Ejecutar sp_alquileres_por_cliente con límite de diez clientes](trazabilidad/mysql_sp_alquileres_por_cliente_ejecucion.png)

**Retroalimentación:** En el editor de procedimientos de DBeaver definí el parámetro `p_cantidad_clientes` y guardé el procedimiento. Luego ejecuté el `CALL` desde el editor SQL y observé diez filas. Cada cliente aparece con un alquiler y la lista `rental_ids` muestra los identificadores del 1 al 10.

**Lo que aprendí:** Aprendí que en DBeaver debo declarar el parámetro en el editor de procedimientos y guardar allí el procedimiento; luego puedo invocarlo desde el editor SQL con `CALL`.

### PostgreSQL: agregados `FILTER` para pagos

<a id="sp-avanzada-postgresql-filter-pagos"></a>

Parametrizo el método de pago, que puede quedar sin filtrar. Ejecuto la consulta original, creo el procedimiento y recupero el cursor dentro de la misma transacción; comparo los estados e importes agregados.

**Paso a paso:** 1. Selecciono PostgreSQL y ejecuto la consulta con agregados `FILTER`; 2. ejecuto por separado la definición del procedimiento; 3. selecciono el bloque entero desde `BEGIN` hasta `COMMIT` y lo ejecuto con **Alt+X**; 4. comparo los conteos e importes. Mantengo `CALL` y `FETCH` dentro de la misma transacción.

```sql
CREATE OR REPLACE PROCEDURE public.sp_resumen_pagos_por_metodo(
    IN p_metodo VARCHAR,
    INOUT p_resultado REFCURSOR
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN p_resultado FOR
        SELECT payment_method,
               COUNT(*) FILTER (WHERE status = 'paid') AS paid_count,
               COUNT(*) FILTER (WHERE status = 'pending') AS pending_count,
               COUNT(*) FILTER (WHERE status = 'refunded') AS refunded_count,
               COALESCE(SUM(amount) FILTER (WHERE status = 'paid'), 0) AS paid_total
        FROM payments
        WHERE p_metodo IS NULL OR payment_method = p_metodo
        GROUP BY payment_method
        ORDER BY payment_method;
END;
$$;
```

```sql
BEGIN;
CALL public.sp_resumen_pagos_por_metodo(NULL, 'r_pagos');
FETCH ALL FROM r_pagos;
COMMIT;
```

**Evidencia de creación:**

**PostgreSQL: Crear `sp_resumen_pagos_por_metodo`**

![PostgreSQL: Crear sp_resumen_pagos_por_metodo](trazabilidad/postgresql_sp_resumen_pagos_creacion.png)

**Evidencia de ejecución:**

**PostgreSQL: Resumir pagos por método y estado**

![PostgreSQL: Ejecutar sp_resumen_pagos_por_metodo](trazabilidad/postgresql_sp_resumen_pagos_ejecucion.png)

**Retroalimentación:** Observé que el procedimiento quedó creado en el esquema `public` y que la llamada con `p_metodo = NULL` devolvió cuatro filas, una por método de pago. En la cuadrícula aparecen los conteos de pagos pagados, pendientes y reembolsados, junto con el total pagado para cada método.

**Lo que aprendí:** Aprendí que un parámetro nulo permite resumir todos los métodos y que los agregados `FILTER` calculan cada estado en columnas separadas dentro de una misma fila por método.

### PostgreSQL: último alquiler por cliente

<a id="sp-avanzada-postgresql-ultimo-alquiler"></a>

Parametrizo la cantidad máxima de clientes y conservo la subconsulta correlacionada que recupera el importe del alquiler más reciente. Ejecuto la consulta original, creo el procedimiento y comparo las diez filas recuperadas.

**Paso a paso:** 1. Selecciono la conexión PostgreSQL y ejecuto la consulta original; 2. creo `sp_ultimo_alquiler_por_cliente` ejecutando completa su definición; 3. en una transacción, ejecuto con **Alt+X** el bloque completo desde `BEGIN` hasta `COMMIT`, manteniendo juntos `CALL` y `FETCH`; 4. reviso las diez filas y comparo las fechas e importes devueltos.

```sql
CREATE OR REPLACE PROCEDURE public.sp_ultimo_alquiler_por_cliente(
    IN p_cantidad INTEGER,
    INOUT p_resultado REFCURSOR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_cantidad IS NULL OR p_cantidad < 1 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor que cero.';
    END IF;
    OPEN p_resultado FOR
        SELECT c.client_id, c.first_name, c.last_name,
               MAX(r.started_at) AS latest_rental_at,
               (SELECT r2.total_amount
                FROM rentals r2
                WHERE r2.client_id = c.client_id
                ORDER BY r2.started_at DESC NULLS LAST
                LIMIT 1) AS latest_rental_amount
        FROM clients c
        LEFT JOIN rentals r ON r.client_id = c.client_id
        GROUP BY c.client_id, c.first_name, c.last_name
        ORDER BY latest_rental_at DESC NULLS LAST, c.client_id
        LIMIT p_cantidad;
END;
$$;
```

```sql
BEGIN;
CALL public.sp_ultimo_alquiler_por_cliente(10, 'cursor_alquileres');
FETCH ALL FROM cursor_alquileres;
COMMIT;
```

**Evidencia de creación:**

**PostgreSQL: Crear `sp_ultimo_alquiler_por_cliente`**

![PostgreSQL: Crear sp_ultimo_alquiler_por_cliente](trazabilidad/postgresql_sp_ultimo_alquiler_creacion.png)

**Evidencia de ejecución:**

**PostgreSQL: Consultar los diez alquileres más recientes por cliente**

![PostgreSQL: Ejecutar sp_ultimo_alquiler_por_cliente y recuperar diez filas](trazabilidad/postgresql_sp_ultimo_alquiler_ejecucion.png)

**Retroalimentación:** En DBeaver observé que la definición del procedimiento se ejecutó y quedó visible bajo las funciones del esquema `public`. Al llamar el procedimiento y recuperar el cursor, obtuve diez filas con cliente, fecha e importe del alquiler más reciente. Sin embargo, el panel de salida también muestra `there is no transaction in progress` al finalizar el bloque. Por ello, la evidencia confirma la recuperación de las filas, pero no una finalización completamente limpia de la transacción.

**Lo que aprendí:** Aprendí que el cursor `REFCURSOR` debe permanecer dentro de la misma transacción hasta ejecutar `FETCH`; también debo revisar el mensaje final de DBeaver y no considerar la ejecución libre de errores mientras aparezca un aviso de transacción.

### SQL Server: duración de alquiler por tipo

<a id="sp-avanzada-sqlserver-datediff"></a>

Parametrizo el tipo de bicicleta, manteniendo la duración promedio de alquileres completados. Ejecuto la consulta original, creo el procedimiento y comparo todos los tipos y la llamada filtrada.

**Paso a paso:** 1. Selecciono la conexión de SQL Server y ejecuto la consulta con `DATEDIFF`; 2. selecciono la definición completa del procedimiento, desde `CREATE OR ALTER` hasta `END;`, y la ejecuto con **Alt+X**; 3. ejecuto por separado cada llamada de prueba; 4. comparo conteos y promedios.

```sql
CREATE OR ALTER PROCEDURE dbo.sp_duracion_alquiler_por_tipo
    @p_tipo_bicicleta VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.bicycle_type, COUNT(*) AS rental_count,
           AVG(CAST(DATEDIFF(MINUTE, r.started_at, r.ended_at) AS DECIMAL(10,2)))
               AS average_duration_minutes
    FROM dbo.rentals AS r
    INNER JOIN dbo.bicycles AS b
        ON b.bicycle_id = r.bicycle_id
    WHERE r.status = 'completed'
      AND r.ended_at IS NOT NULL
      AND (@p_tipo_bicicleta IS NULL
           OR b.bicycle_type = @p_tipo_bicicleta)
    GROUP BY b.bicycle_type
    ORDER BY average_duration_minutes DESC, b.bicycle_type;
END;
```

```sql
EXEC dbo.sp_duracion_alquiler_por_tipo @p_tipo_bicicleta = NULL;
```

```sql
EXEC dbo.sp_duracion_alquiler_por_tipo @p_tipo_bicicleta = 'electric';
```

**Evidencia de creación:**

**SQL Server: Crear `dbo.sp_duracion_alquiler_por_tipo`**

![SQL Server: Crear sp_duracion_alquiler_por_tipo](trazabilidad/sqlserver_sp_duracion_alquiler_tipo_creacion.png)

**Evidencia de ejecución sin filtro:**

**SQL Server: Consultar la duración por todos los tipos de bicicleta**

![SQL Server: Ejecutar sp_duracion_alquiler_por_tipo sin filtro](trazabilidad/sqlserver_sp_duracion_alquiler_tipo_todos_tipos.png)

**Evidencia de ejecución filtrada:**

**SQL Server: Consultar la duración de bicicletas electric**

![SQL Server: Ejecutar sp_duracion_alquiler_por_tipo para electric](trazabilidad/sqlserver_sp_duracion_alquiler_tipo_electric.png)

**Retroalimentación:** Observé que el procedimiento quedó creado en el esquema `dbo`. La llamada con el parámetro `NULL` devolvió cuatro tipos de bicicleta; la llamada con `electric` devolvió solo ese tipo. En ambas capturas el resultado muestra 17 alquileres completados y un promedio de 60 minutos para los tipos incluidos.

**Lo que aprendí:** Aprendí a usar un parámetro opcional para alternar entre el resumen general y un tipo específico, y a calcular promedios de duración en minutos con `DATEDIFF` y una conversión decimal.

### Oracle: último alquiler con `KEEP`

<a id="sp-avanzada-oracle-keep"></a>

Parametrizo el número de clientes y mantengo `KEEP (DENSE_RANK LAST ...)` para recuperar el importe de la última fecha de alquiler. Ejecuto la consulta original, creo el procedimiento y comparo la salida del cursor con las diez filas de la consulta.

**Paso a paso:** 1. Selecciono la conexión Oracle y ejecuto la consulta con `KEEP`; 2. selecciono el bloque de creación completo y lo ejecuto con **Alt+X**; 3. ejecuto el bloque `DECLARE` de llamada para solicitar diez clientes y mostrar el `SYS_REFCURSOR`; 4. comparo las fechas e importes.

```sql
CREATE OR REPLACE PROCEDURE sp_ultimo_alquiler_keep(
    p_cantidad IN PLS_INTEGER,
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN
    IF p_cantidad IS NULL OR p_cantidad < 1 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'La cantidad debe ser mayor que cero.'
        );
    END IF;

    OPEN p_resultado FOR
        SELECT client_id,
               first_name,
               last_name,
               latest_rental_at,
               latest_rental_amount
        FROM (
            SELECT c.client_id,
                   c.first_name,
                   c.last_name,
                   MAX(r.started_at) AS latest_rental_at,
                   MAX(r.total_amount)
                       KEEP (DENSE_RANK LAST ORDER BY r.started_at)
                       AS latest_rental_amount,
                   ROW_NUMBER() OVER (
                       ORDER BY MAX(r.started_at) DESC NULLS LAST,
                                c.client_id
                   ) AS row_num
            FROM clients c
            LEFT JOIN rentals r
                ON r.client_id = c.client_id
            GROUP BY c.client_id, c.first_name, c.last_name
        )
        WHERE row_num <= p_cantidad
        ORDER BY latest_rental_at DESC NULLS LAST, client_id;
END;
/
```

El bloque de creación termina con `/` para que DBeaver lo ejecute como script con **Alt+X**. Después ejecuto por separado este bloque PL/SQL para invocar el procedimiento y mostrar el resultado:

```sql
DECLARE
    v_resultado SYS_REFCURSOR;
BEGIN
    sp_ultimo_alquiler_keep(10, v_resultado);
    DBMS_SQL.RETURN_RESULT(v_resultado);
END;
```

**Evidencia de creación:**

**Oracle: Crear `sp_ultimo_alquiler_keep`**

![Oracle: Crear sp_ultimo_alquiler_keep](trazabilidad/oracle_sp_ultimo_alquiler_keep_creacion.png)

**Evidencia de ejecución:**

**Oracle: Recuperar los diez alquileres más recientes**

![Oracle: Ejecutar sp_ultimo_alquiler_keep y recuperar diez filas](trazabilidad/oracle_sp_ultimo_alquiler_keep_ejecucion.png)

**Retroalimentación:** Observé que `sp_ultimo_alquiler_keep` quedó creado bajo los procedimientos de la conexión Oracle. Al ejecutar el bloque `DECLARE`, el cursor devolvió diez filas con el identificador y nombre del cliente, la fecha del último alquiler y su importe. La cuadrícula muestra los resultados sin un mensaje de error visible.

**Lo que aprendí:** Aprendí que puedo combinar `KEEP (DENSE_RANK LAST ...)` con `ROW_NUMBER()` para asociar al último alquiler su importe y limitar los clientes devueltos; el `SYS_REFCURSOR` me permite mostrar ese resultado desde un bloque PL/SQL.

## Procedimientos almacenados

En esta sección creo un procedimiento de solo lectura para listar los alquileres completados dentro de un intervalo de fechas. Uso un límite final exclusivo (`started_at < fecha_fin`) para que pueda consultar periodos consecutivos sin contar dos veces los registros ubicados justo en el límite. Cada bloque es específico para un motor; creo y ejecuto únicamente el que corresponde a mi conexión. Las capturas de creación y ejecución quedan pendientes hasta que las tome en DBeaver.

### MySQL

```sql
DELIMITER //
CREATE PROCEDURE sp_listar_alquileres_completados(
    IN p_inicio DATETIME,
    IN p_fin DATETIME
)
BEGIN
    SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount
    FROM rentals
    WHERE status = 'completed'
      AND started_at >= p_inicio
      AND started_at < p_fin
    ORDER BY started_at;
END//
DELIMITER ;

CALL sp_listar_alquileres_completados(
    '2026-10-01 00:00:00',
    '2026-11-01 00:00:00'
);
```

**Evidencia de ejecucion:**

**MySQL: Crear y ejecutar el procedimiento de alquileres completados**

*Captura pendiente: `mysql_procedimiento_alquileres_completados.png`.*

**Retroalimentacion:** Con el procedimiento filtro los alquileres completados por fecha de inicio y obtengo sus datos ordenados cronológicamente. Registraré las filas reales cuando lo ejecute.

**Lo que aprendi:** Aprenderé a encapsular una consulta parametrizada en un procedimiento MySQL y a invocarlo con `CALL`.

### PostgreSQL

Mantengo abierta la transacción para recuperar el cursor que devuelve el procedimiento y ejecuto el bloque completo como script en DBeaver:

```sql
CREATE OR REPLACE PROCEDURE sp_listar_alquileres_completados(
    IN p_inicio TIMESTAMP,
    IN p_fin TIMESTAMP,
    INOUT p_resultado REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_resultado FOR
        SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount
        FROM rentals
        WHERE status = 'completed'
          AND started_at >= p_inicio
          AND started_at < p_fin
        ORDER BY started_at;
END;
$$;

BEGIN;
CALL sp_listar_alquileres_completados(
    TIMESTAMP '2026-10-01 00:00:00',
    TIMESTAMP '2026-11-01 00:00:00',
    'r_alquileres'
);
FETCH ALL FROM r_alquileres;
COMMIT;
```

**Evidencia de ejecucion:**

**PostgreSQL: Crear y ejecutar el procedimiento de alquileres completados**

*Captura pendiente: `postgresql_procedimiento_alquileres_completados.png`.*

**Retroalimentacion:** Con el procedimiento abro un cursor con los alquileres completados del intervalo y recupero las filas con `FETCH ALL`. Anotaré el resultado observado al ejecutarlo en DBeaver.

**Lo que aprendi:** Aprenderé a devolver resultados desde un procedimiento PostgreSQL mediante un cursor y una transacción.

### Microsoft SQL Server

```sql
CREATE OR ALTER PROCEDURE dbo.sp_listar_alquileres_completados
    @p_inicio DATETIME2,
    @p_fin DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount
    FROM dbo.rentals
    WHERE status = 'completed'
      AND started_at >= @p_inicio
      AND started_at < @p_fin
    ORDER BY started_at;
END;
GO

EXEC dbo.sp_listar_alquileres_completados
    @p_inicio = '2026-10-01T00:00:00',
    @p_fin = '2026-11-01T00:00:00';
```

**Evidencia de ejecucion:**

**SQL Server: Crear y ejecutar el procedimiento de alquileres completados**

*Captura pendiente: `sqlserver_procedimiento_alquileres_completados.png`.*

**Retroalimentacion:** Con el procedimiento recibo dos parámetros de fecha y consulto los alquileres completados dentro del intervalo. Completaré la observación con las filas que devuelva SQL Server.

**Lo que aprendi:** Aprenderé a definir y ejecutar un procedimiento parametrizado de SQL Server con `CREATE OR ALTER PROCEDURE` y `EXEC`.

### Oracle

```sql
CREATE OR REPLACE PROCEDURE sp_listar_alquileres_completados(
    p_inicio IN TIMESTAMP,
    p_fin IN TIMESTAMP,
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_resultado FOR
        SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount
        FROM rentals
        WHERE status = 'completed'
          AND started_at >= p_inicio
          AND started_at < p_fin
        ORDER BY started_at;
END;
/

DECLARE
    v_resultado SYS_REFCURSOR;
BEGIN
    sp_listar_alquileres_completados(
        TIMESTAMP '2026-10-01 00:00:00',
        TIMESTAMP '2026-11-01 00:00:00',
        v_resultado
    );
    DBMS_SQL.RETURN_RESULT(v_resultado);
END;
/
```

Ejecuto este bloque como script en una versión de Oracle que admita `DBMS_SQL.RETURN_RESULT` (12c o posterior), para mostrar el cursor devuelto en el cliente.

**Evidencia de ejecucion:**

**Oracle: Crear y ejecutar el procedimiento de alquileres completados**

*Captura pendiente: `oracle_procedimiento_alquileres_completados.png`.*

**Retroalimentacion:** Con el procedimiento abro un `SYS_REFCURSOR` con las filas completadas del intervalo y devuelvo ese resultado al cliente. Anotaré las filas reales después de ejecutarlo.

**Lo que aprendi:** Aprenderé a definir un procedimiento PL/SQL con parámetros de entrada y a devolver una consulta mediante `SYS_REFCURSOR`.

## Triggers

En esta sección automatizo el registro de cambios de estado de un alquiler en la tabla existente `rental_events`. Así aprovecho el historial operativo del esquema y no creo otra tabla. El trigger añade una fila solo cuando cambia `rentals.status`; no altera el alquiler, no modifica ni elimina los eventos anteriores y no requiere que ejecute un `INSERT` manual en el historial.

Creo el trigger correspondiente una sola vez en la conexión indicada. Para verificarlo, selecciono un alquiler activo de prueba, desactivo el autocommit, cambio su estado a `cancelled` y consulto el evento nuevo; después revierto la transacción desde DBeaver para que no queden modificados ni el alquiler ni el historial. Sustituyo el identificador de ejemplo por el de un alquiler activo real. Las capturas quedan pendientes hasta que complete la ejecución.

### MySQL

```sql
DROP TRIGGER IF EXISTS trg_rentals_status_event;

DELIMITER //
CREATE TRIGGER trg_rentals_status_event
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO rental_events (rental_id, event_type, description, event_at)
        VALUES (
            NEW.rental_id,
            'STATUS_CHANGE',
            CONCAT('Estado: ', OLD.status, ' -> ', NEW.status),
            CURRENT_TIMESTAMP
        );
    END IF;
END//
DELIMITER ;
```

**Evidencia de ejecucion:**

**MySQL: Registrar cambios de estado de alquiler con un trigger**

*Captura pendiente: `mysql_trigger_estado_alquiler.png`.*

**Retroalimentacion:** Comparo los estados anterior y nuevo; cuando son distintos, inserto en `rental_events` el identificador del alquiler, la transición y la fecha del cambio.

**Lo que aprendi:** Aprenderé a utilizar `OLD` y `NEW` en un trigger por fila de MySQL y a registrar un cambio sin modificar la tabla principal.

### PostgreSQL

```sql
CREATE OR REPLACE FUNCTION fn_rentals_status_event()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO rental_events (rental_id, event_type, description, event_at)
        VALUES (
            NEW.rental_id,
            'STATUS_CHANGE',
            format('Estado: %s -> %s', OLD.status, NEW.status),
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_rentals_status_event ON rentals;
CREATE TRIGGER trg_rentals_status_event
AFTER UPDATE OF status ON rentals
FOR EACH ROW
EXECUTE FUNCTION fn_rentals_status_event();
```

**Evidencia de ejecucion:**

**PostgreSQL: Registrar cambios de estado de alquiler con un trigger**

*Captura pendiente: `postgresql_trigger_estado_alquiler.png`.*

**Retroalimentacion:** Comparo los estados anterior y nuevo con `IS DISTINCT FROM` y añado un evento únicamente cuando detecto un cambio.

**Lo que aprendi:** Aprenderé a separar en PostgreSQL la función PL/pgSQL que contiene la lógica del trigger y la definición que la asocia a `rentals`.

### Microsoft SQL Server

```sql
CREATE OR ALTER TRIGGER dbo.trg_rentals_status_event
ON dbo.rentals
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.rental_events (rental_id, event_type, description, event_at)
    SELECT
        i.rental_id,
        'STATUS_CHANGE',
        CONCAT('Estado: ', d.status, ' -> ', i.status),
        SYSDATETIME()
    FROM inserted AS i
    JOIN deleted AS d ON d.rental_id = i.rental_id
    WHERE i.status <> d.status;
END;
GO
```

**Evidencia de ejecucion:**

**SQL Server: Registrar cambios de estado de alquiler con un trigger**

*Captura pendiente: `sqlserver_trigger_estado_alquiler.png`.*

**Retroalimentacion:** Relaciono las tablas lógicas `inserted` y `deleted` por `rental_id`. Con esa comparación registro los cambios de estado y admito que una sentencia modifique varias filas.

**Lo que aprendi:** Aprenderé que los triggers de SQL Server deben procesar conjuntos de filas con `inserted` y `deleted`, no asumir una única fila por ejecución.

### Oracle

```sql
CREATE OR REPLACE TRIGGER trg_rentals_status_event
AFTER UPDATE OF status ON rentals
FOR EACH ROW
WHEN (OLD.status <> NEW.status)
BEGIN
    INSERT INTO rental_events (rental_id, event_type, description, event_at)
    VALUES (
        :NEW.rental_id,
        'STATUS_CHANGE',
        'Estado: ' || :OLD.status || ' -> ' || :NEW.status,
        LOCALTIMESTAMP
    );
END;
/
```

**Evidencia de ejecucion:**

**Oracle: Registrar cambios de estado de alquiler con un trigger**

*Captura pendiente: `oracle_trigger_estado_alquiler.png`.*

**Retroalimentacion:** Al actualizar `status`, comparo `:OLD.status` con `:NEW.status` y agrego un evento solo cuando encuentro una transición.

**Lo que aprendi:** Aprenderé a utilizar `:OLD` y `:NEW` en un trigger PL/SQL por fila.

### Verificación del trigger y reversión de la prueba

Primero consulto un alquiler activo y elijo su identificador:

```sql
SELECT rental_id
FROM rentals
WHERE status = 'active'
ORDER BY rental_id;
```

Con el autocommit desactivado, sustituyo el `1` de este ejemplo por el identificador activo que seleccioné y ejecuto la actualización:

```sql
UPDATE rentals
SET status = 'cancelled'
WHERE rental_id = 1
  AND status = 'active';
```

Después de actualizar el alquiler de prueba, consulto el historial para comprobar el evento registrado:

```sql
SELECT rental_event_id, rental_id, event_type, description, event_at
FROM rental_events
WHERE event_type = 'STATUS_CHANGE'
ORDER BY rental_event_id DESC;
```

Al confirmar el resultado, uso **Rollback** en DBeaver antes de volver a activar el autocommit. Así revierto la actualización y el evento que insertó el trigger. Registro en las capturas el trigger creado y la fila temporal de evento; todavía no he ejecutado esta prueba y no presento resultados como verificados.

## Evidencia de trazabilidad

Debajo de cada evidencia puse el título del motor (MySQL, PostgreSQL, SQL Server u Oracle) y una retroalimentación en la que explico para qué sirve la consulta y qué observo en el resultado. En las primeras ocho capturas observo 80 bicicletas disponibles y 67 alquileres completados en cada motor. También dejo marcadas como pendientes las capturas de los procedimientos, los triggers y las consultas que todavía no ejecuto; completaré cada observación cuando tenga el resultado real.

Agregué a [trazabilidad/](./trazabilidad/) las siguientes capturas:

- Bicicletas disponibles: `mysql_bicicletas_disponibles.png`, `postgresql_bicicletas_disponibles.png`, `sqlserver_bicicletas_disponibles.png` y `oracle_bicicletas_disponibles.png`.
- Alquileres completados: `mysql_alquileres_completados.png`, `postgresql_alquileres_completados.png`, `sqlserver_alquileres_completados.png` y `oracle_alquileres_completados.png`.
- Base de datos activa en MySQL: `mysql_base_seleccionada.png`.
- Tablas visibles en MySQL: `mysql_inventario_tablas_mysql.png`.
- Tablas visibles en PostgreSQL: `postgresql_inventario_tablas_postgresql.png`.
- Diez alquileres recientes en PostgreSQL: `postgresql_alquileres_completados_top10_postgresql.png`.
- Tablas visibles en SQL Server: `sqlserver_inventario_tablas_sqlserver.png`.
- Diez alquileres recientes en SQL Server: `sqlserver_alquileres_completados_top10_sqlserver.png`.
- Tablas visibles en Oracle: `oracle_inventario_tablas_oracle.png`.
- Clientes con mas alquileres en MySQL: `mysql_clientes_mas_alquileres_mysql.png`.
- Ultimo alquiler por cliente en PostgreSQL: `postgresql_ultimo_alquiler_por_cliente.png`.
- Puntos de anclaje disponibles en MySQL: `mysql_puntos_disponibles_por_estacion_mysql.png`.
- Incidentes abiertos en MySQL: `mysql_incidentes_abiertos_mysql.png`.
- Ingresos pagados por mes en MySQL: `mysql_ingresos_pagados_por_mes_mysql.png`.
- Alquileres por semana en PostgreSQL: `postgresql_alquileres_por_semana.png`.
- Tiempo de uso de anclajes en PostgreSQL: `postgresql_tiempo_uso_anclajes.png`.
- Incidentes con reportes de revisión en PostgreSQL: `postgresql_incidentes_revision_ilike.png`.
- Calificaciones mensuales en PostgreSQL: `postgresql_calificaciones_por_mes.png`.
- Estados de bicicletas con PIVOT en SQL Server: `sqlserver_bicicletas_por_estado_pivot.png`.
- Inventario JSON en SQL Server: `sqlserver_estaciones_json.png`.
- Impuestos de facturas en SQL Server: `sqlserver_validar_impuestos_facturas.png`.
- Importes de alquileres consecutivos en SQL Server: `sqlserver_comparar_importes_alquileres_lag.png`.
- Rendimiento de tarifas en Oracle: `oracle_rendimiento_tarifas.png`.
- Calendario de alquileres en Oracle: `oracle_calendario_diario_connect_by.png`.
- Incidentes agrupados con ROLLUP en Oracle: `oracle_incidentes_rollup_severidad.png`.
- Participación de ingresos por bicicleta en Oracle: `oracle_participacion_ingresos_bicicletas.png`.
- Alquileres concatenados por cliente en MySQL: `mysql_alquileres_por_cliente_group_concat.png`.
- Pagos por estado con FILTER en PostgreSQL: `postgresql_pagos_por_estado_filter.png`.
- Duración por tipo con DATEDIFF en SQL Server: `sqlserver_duracion_alquiler_por_tipo_datediff.png`.

## Referencias

- [Guía docente de consultas MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/)
- [Guía docente de consultas PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/)
- [Guía docente de consultas Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/)
- [Guía docente de consultas Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/)
- [Guía del esquema PedalLibre](./Creacion%20de%20Tablas%20y%20Reguistros/guia.md)
- [Guia de insercion de datos](./Creacion%20de%20Tablas%20y%20Reguistros/guia_insert_datos.md)
