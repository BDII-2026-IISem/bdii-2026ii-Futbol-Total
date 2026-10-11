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
7. Debajo de cada bloque SQL encuentro la ruta de su captura pendiente. Tomo la imagen en DBeaver mostrando conexion, sentencia y resultado; la guardo con ese nombre en `trazabilidad/`. Despues completo lo que observe y aprendi basandome en las filas reales. Para MySQL, ejecuto cada consulta de esta seccion individualmente en DBeaver.

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
**MySQL: Consultar bicicletas disponibles**
![MySQL: Consultar bicicletas disponibles](trazabilidad/mysql_bicicletas_disponibles.png)

**Retroalimentacion:** La sentencia filtra `bicycles` por `status = 'available'` y ordena por identificador. Observacion: la captura muestra 80 filas recuperadas y todas tienen estado `available`.

**PostgreSQL: Consultar bicicletas disponibles**
![PostgreSQL: Consultar bicicletas disponibles](trazabilidad/postgresql_bicicletas_disponibles.png)

**Retroalimentacion:** La sentencia filtra `bicycles` por `status = 'available'` y ordena por identificador. Observacion: la captura muestra 80 filas recuperadas y todas tienen estado `available`.

**SQL Server: Consultar bicicletas disponibles**
![SQL Server: Consultar bicicletas disponibles](trazabilidad/sqlserver_bicicletas_disponibles.png)

**Retroalimentacion:** La sentencia filtra `bicycles` por `status = 'available'` y ordena por identificador. Observacion: la captura muestra 80 filas recuperadas y todas tienen estado `available`.

**Oracle: Consultar bicicletas disponibles**
![Oracle: Consultar bicicletas disponibles](trazabilidad/oracle_bicicletas_disponibles.png)

**Retroalimentacion:** La sentencia filtra `bicycles` por `status = 'available'` y ordena por identificador. Observacion: la captura muestra 80 filas recuperadas y todas tienen estado `available`.

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
**MySQL: Consultar alquileres completados**
![MySQL: Consultar alquileres completados](trazabilidad/mysql_alquileres_completados.png)

**Retroalimentacion:** La sentencia filtra `rentals` por estado `completed` y ordena por inicio descendente. Observacion: la captura muestra 67 alquileres completados ordenados del mas reciente al mas antiguo.

**PostgreSQL: Consultar alquileres completados**
![PostgreSQL: Consultar alquileres completados](trazabilidad/postgresql_alquileres_completados.png)

**Retroalimentacion:** La sentencia filtra `rentals` por estado `completed` y ordena por inicio descendente. Observacion: la captura muestra 67 alquileres completados ordenados del mas reciente al mas antiguo.

**SQL Server: Consultar alquileres completados**
![SQL Server: Consultar alquileres completados](trazabilidad/sqlserver_alquileres_completados.png)

**Retroalimentacion:** La sentencia filtra `rentals` por estado `completed` y ordena por inicio descendente. Observacion: la captura muestra 67 alquileres completados ordenados del mas reciente al mas antiguo.

**Oracle: Consultar alquileres completados**
![Oracle: Consultar alquileres completados](trazabilidad/oracle_alquileres_completados.png)

**Retroalimentacion:** La sentencia filtra `rentals` por estado `completed` y ordena por inicio descendente. Observacion: la captura muestra 67 alquileres completados ordenados del mas reciente al mas antiguo.

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

**Retroalimentacion:** El resultado presenta el identificador del alquiler junto con el nombre del cliente, serial de la bicicleta, tarifa y estaciones de inicio y fin. La captura muestra 100 filas recuperadas; los `JOIN` combinan las entidades relacionadas y los `LEFT JOIN` permiten conservar el alquiler aunque alguna estación no esté asociada.

**PostgreSQL: Consultar detalle de alquileres relacionados**
![PostgreSQL: Consultar detalle de alquileres relacionados](trazabilidad/postgresql_detalle_alquileres_relacionados.png)

**Retroalimentacion:** El resultado presenta el identificador del alquiler junto con el nombre del cliente, serial de la bicicleta, tarifa y estaciones de inicio y fin. La captura muestra 100 filas recuperadas; los `JOIN` combinan las entidades relacionadas y los `LEFT JOIN` permiten conservar el alquiler aunque alguna estación no esté asociada.

**SQL Server: Consultar detalle de alquileres relacionados**
![SQL Server: Consultar detalle de alquileres relacionados](trazabilidad/sqlserver_detalle_alquileres_relacionados.png)

**Retroalimentacion:** El resultado presenta el identificador del alquiler junto con el nombre del cliente, serial de la bicicleta, tarifa y estaciones de inicio y fin. La captura muestra 100 filas recuperadas; los `JOIN` combinan las entidades relacionadas y los `LEFT JOIN` permiten conservar el alquiler aunque alguna estación no esté asociada.

**Oracle: Consultar detalle de alquileres relacionados**
![Oracle: Consultar detalle de alquileres relacionados](trazabilidad/oracle_detalle_alquileres_relacionados.png)

**Retroalimentacion:** El resultado presenta el identificador del alquiler junto con el nombre del cliente, serial de la bicicleta, tarifa y estaciones de inicio y fin. La captura muestra 100 filas recuperadas; los `JOIN` combinan las entidades relacionadas y los `LEFT JOIN` permiten conservar el alquiler aunque alguna estación no esté asociada.

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

**Evidencia de ejecucion:**
**MySQL: Resumir alquileres por estado**
![MySQL: Resumir alquileres por estado](trazabilidad/mysql_resumen_alquileres_por_estado.png)

**Retroalimentacion:** La consulta agrupa los alquileres por estado y calcula la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**PostgreSQL: Resumir alquileres por estado**
![PostgreSQL: Resumir alquileres por estado](trazabilidad/postgresql_resumen_alquileres_por_estado.png)

**Retroalimentacion:** La consulta agrupa los alquileres por estado y calcula la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**SQL Server: Resumir alquileres por estado**
![SQL Server: Resumir alquileres por estado](trazabilidad/sqlserver_resumen_alquileres_por_estado.png)

**Retroalimentacion:** La consulta agrupa los alquileres por estado y calcula la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

**Oracle: Resumir alquileres por estado**
![Oracle: Resumir alquileres por estado](trazabilidad/oracle_resumen_alquileres_por_estado.png)

**Retroalimentacion:** La consulta agrupa los alquileres por estado y calcula la cantidad, el importe total y el promedio. Observo tres grupos: 16 `active`, 17 `cancelled` y 67 `completed`; sus importes totales son 132.808, 140.629 y 528.213, respectivamente.

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

**Retroalimentacion:** La consulta forma grupos por metodo y estado, y muestra la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**PostgreSQL: Resumir pagos por metodo y estado**
![PostgreSQL: Resumir pagos por metodo y estado](trazabilidad/postgresql_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** La consulta forma grupos por metodo y estado, y muestra la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**SQL Server: Resumir pagos por metodo y estado**
![SQL Server: Resumir pagos por metodo y estado](trazabilidad/sqlserver_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** La consulta forma grupos por metodo y estado, y muestra la cantidad y la suma de los importes. Observo 12 combinaciones entre `credit_card`, `debit_card`, `digital_wallet` y `pse`, cada una con los estados `paid`, `pending` o `refunded`.

**Oracle: Resumir pagos por metodo y estado**
![Oracle: Resumir pagos por metodo y estado](trazabilidad/oracle_resumen_pagos_por_metodo_estado.png)

**Retroalimentacion:** La consulta forma grupos por metodo y estado, y muestra la cantidad y la suma de los importes. Observo 12 filas. En una fila figura `digital_wallet` y en otra `digital_Wallet`, con distinta capitalizacion; por eso Oracle separa esas variantes en grupos distintos.

**Lo que aprendi:** Aprendi a agrupar pagos por metodo y estado para comparar cantidades e importes.

## Comandos específicos de cada motor

### MySQL

Conecto a la base indicada y verifico el esquema. Si la lista está vacía o no corresponde a PedalLibre, no continúo hasta seleccionar la base correcta.

```sql
SELECT DATABASE() AS base_actual;
```

La respuesta debe ser `Pedalibre-Terminal-Dbeaver`. Si aparece otro nombre, cambio la conexión activa en DBeaver antes de continuar.

**Evidencia de ejecucion:**
**MySQL: Verificar la base de datos activa**
![MySQL: Verificar la base de datos activa](trazabilidad/mysql_base_seleccionada.png)

**Retroalimentacion:** La sentencia `SELECT DATABASE()` identifica la base MySQL activa en esta conexion. Observo `Pedalibre-Terminal-Dbeaver`, por lo que confirmo que la consulta se ejecuta en la base indicada.

**Lo que aprendi:** Aprendi a comprobar la base activa antes de consultar sus tablas.

```sql
SHOW TABLES;
```

**Evidencia de ejecucion:**
**MySQL: Verificar las tablas de la base**
![MySQL: Verificar las tablas de la base](trazabilidad/mysql_inventario_tablas_mysql.png)

**Retroalimentacion:** `SHOW TABLES` lista las tablas visibles en la base MySQL seleccionada, sin consultar sus registros. Observo 21 tablas del proyecto, entre ellas `bicycles`, `clients`, `payments` y `rentals`; esto confirma que el esquema esperado está visible en DBeaver.

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

**Evidencia de ejecucion:**
**MySQL: Contar registros por tabla**
![MySQL: Contar registros por tabla](trazabilidad/mysql_conteo_registros.png)

**Retroalimentacion:** La consulta cuenta las filas de cada una de las 21 tablas. Observo que cada tabla muestra 100 registros, coincidiendo con la cantidad esperada en la guia de insercion.

**Lo que aprendi:** Aprendi a validar con `COUNT(*)` la cantidad de registros cargados antes de analizar los datos.

Para limitar la consulta de alquileres completados a 10 filas, agrego `LIMIT 10` al final:

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

**Retroalimentacion:** `LIMIT 10` restringe la salida a los 10 alquileres completados mas recientes, ordenados por fecha de inicio descendente. Observo diez filas con estado `completed`; la primera corresponde al registro mas reciente mostrado.

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

**Evidencia de ejecucion:**
**PostgreSQL: Verificar las tablas de la base**
![PostgreSQL: Verificar las tablas de la base](trazabilidad/postgresql_inventario_tablas_postgresql.png)

**Retroalimentacion:** La consulta revisa el catalogo `information_schema.tables` y filtra el esquema `public` para mostrar solo tablas base. Observo las 21 tablas del proyecto PedalLibre.

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

**Retroalimentacion:** `LIMIT 10` limita la salida a los 10 alquileres completados con fecha de inicio mas reciente. Observo diez filas, todas con estado `completed`, ordenadas por `started_at` descendente.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Microsoft SQL Server

Verifico las tablas del esquema actual:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

**Evidencia de ejecucion:**
**SQL Server: Verificar las tablas de la base**
![SQL Server: Verificar las tablas de la base](trazabilidad/sqlserver_inventario_tablas_sqlserver.png)

**Retroalimentacion:** La consulta revisa `INFORMATION_SCHEMA.TABLES` y muestra esquema y nombre de cada tabla base. Observo las 21 tablas del proyecto bajo el esquema `dbo`.

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

**Retroalimentacion:** `TOP (10)` limita la salida a diez alquileres completados, ordenados por fecha de inicio descendente. Observo diez filas y todos los registros muestran estado `completed`.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

### Oracle

Verifico las tablas accesibles para el usuario conectado. Si el usuario tiene seleccionado el esquema `PEDALIBRETERMINALDBEAVER`, sus tablas aparecen en `USER_TABLES`.

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

**Evidencia de ejecucion:**
**Oracle: Verificar las tablas de la base**
![Oracle: Verificar las tablas de la base](trazabilidad/oracle_inventario_tablas_oracle.png)

**Retroalimentacion:** La consulta usa `USER_TABLES` para listar las tablas que pertenecen al usuario conectado. Observo las 21 tablas de PedalLibre en el esquema `PEDALIBRETERMINALDBEAVER`.

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

**Retroalimentacion:** `FETCH FIRST 10 ROWS ONLY` limita la salida a diez alquileres completados ordenados por fecha de inicio descendente. Observo diez filas y todas tienen estado `completed`.

**Lo que aprendi:** Aprendi que Oracle puede limitar filas con `FETCH FIRST`, mientras que PostgreSQL usa `LIMIT` y SQL Server usa `TOP`.

**Retroalimentacion:** `LIMIT 10` restringe la salida a los 10 alquileres completados mas recientes. La ejecucion y el resultado de esta variante siguen pendientes de captura.

**Lo que aprendi:** Aprendi a filtrar los alquileres por estado y ordenar los mas recientes primero; la variante del motor limita las filas mostradas.

## Consultas adicionales por motor

En esta sección presento cuatro análisis distintos por motor. Las consultas adicionales de MySQL ya están ejecutadas; para PostgreSQL, SQL Server y Oracle seleccioné temas y funciones diferentes, sin repetir los análisis de las otras secciones. Ejecuto cada grupo solo en la conexión indicada.

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

**Retroalimentacion:** La consulta cuenta los alquileres por cliente y presenta los cinco valores mas altos; el `LEFT JOIN` tambien conserva a clientes sin alquileres. En el resultado observo cinco clientes con un alquiler cada uno; el desempate por `client_id` los ordena de forma ascendente.

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

**Retroalimentacion:** La sentencia agrupa los puntos de anclaje por estacion, cuenta los puntos asociados y suma los disponibles con `CASE`. La captura muestra 100 filas; en las estaciones visibles hay un punto asociado por estacion y `available_points` vale 0 o 1 segun su estado.

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

**Retroalimentacion:** La consulta filtra incidentes `open` y usa `LEFT JOIN` para añadir los datos de bicicleta y cliente cuando estan asociados. La cuadrícula muestra 25 filas; los registros visibles incluyen distintos niveles de severidad y las descripciones de los incidentes.

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

**Retroalimentacion:** La consulta toma pagos con estado `paid` y fecha registrada, agrupa por mes usando `DATE_FORMAT` y suma sus importes. Observo 71 pagos de octubre de 2026 y un total mensual de 568.145.

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
*Captura pendiente: `postgresql_alquileres_por_semana.png`.*

**Retroalimentacion:** `date_trunc('week', ...)` agrupa las fechas por semana; los agregados con `FILTER` separan el total de alquileres de los completados y suman el importe completado. Anotare las semanas y valores que devuelva DBeaver.

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
*Captura pendiente: `postgresql_tiempo_uso_anclajes.png`.*

**Retroalimentacion:** La consulta considera los acoplamientos que ya tienen hora de retiro, calcula su duracion en minutos con `EXTRACT(EPOCH ...)` y promedia por estacion. Anotare las estaciones y duraciones observadas al ejecutarla.

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
*Captura pendiente: `postgresql_incidentes_revision_ilike.png`.*

**Retroalimentacion:** `ILIKE` busca el texto `revision` sin distinguir entre mayusculas y minusculas, y devuelve los incidentes cuya descripcion menciona esa tarea. Anotare cuantas filas aparecen y sus severidades tras ejecutar la consulta.

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
*Captura pendiente: `postgresql_calificaciones_por_mes.png`.*

**Retroalimentacion:** La consulta agrupa las resenas por mes con `date_trunc` y calcula su cantidad, promedio, minima y maxima calificacion. Anotare los valores reales despues de ejecutarla.

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
*Captura pendiente: `sqlserver_bicicletas_por_estado_pivot.png`.*

**Retroalimentacion:** `PIVOT` convierte los estados seleccionados en columnas y cuenta las bicicletas de cada tipo en cada estado. Anotare las cantidades observadas al ejecutar la consulta.

**Lo que aprendi:** Aprendere a usar `PIVOT` en SQL Server para convertir valores de filas en columnas de resumen.

#### Inventario de estaciones en JSON

```sql
SELECT
    s.station_id,
    s.name AS station_name,
    (
        SELECT dp.docking_point_id, dp.code, dp.status
        FROM dbo.docking_points AS dp
        WHERE dp.station_id = s.station_id
        ORDER BY dp.docking_point_id
        FOR JSON PATH
    ) AS docking_points_json
FROM dbo.stations AS s
ORDER BY s.station_id
FOR JSON PATH;
```

**Evidencia de ejecucion:**
**SQL Server: Exportar inventario de estaciones a JSON**
*Captura pendiente: `sqlserver_estaciones_json.png`.*

**Retroalimentacion:** La subconsulta crea un arreglo JSON con los anclajes de cada estacion y la consulta exterior entrega el inventario en formato JSON. Anotare la forma y las filas de salida que muestre DBeaver.

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
*Captura pendiente: `sqlserver_validar_impuestos_facturas.png`.*

**Retroalimentacion:** La consulta calcula el porcentaje de impuesto y comprueba la diferencia entre total, subtotal e impuesto. `NULLIF` evita division entre cero; anotare si las diferencias son cero al revisar las filas.

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
*Captura pendiente: `sqlserver_comparar_importes_alquileres_lag.png`.*

**Retroalimentacion:** `LAG` obtiene el importe del alquiler completado anterior del mismo cliente. La consulta muestra la diferencia entre ambos importes para hasta 20 filas; anotare el resultado real al ejecutarla.

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
*Captura pendiente: `oracle_rendimiento_tarifas.png`.*

**Retroalimentacion:** La consulta relaciona cada tarifa con sus alquileres, cuenta los completados y suma sus importes. `NVL` muestra cero cuando no hay ingresos completados para una tarifa. Anotare los valores observados en DBeaver.

**Lo que aprendi:** Aprendere a usar `NVL` y agregados condicionales de Oracle para comparar el uso y los ingresos de cada tarifa.

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
**Oracle: Contar anclajes disponibles por estacion**
*Captura pendiente: `oracle_puntos_disponibles_por_estacion_oracle.png`.*

**Retroalimentacion:** La sentencia agrupa los anclajes por estacion y cuenta el total y los que estan disponibles usando `CASE`. La ejecucion y los conteos observados siguen pendientes de captura.

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
**Oracle: Consultar incidentes abiertos**
*Captura pendiente: `oracle_incidentes_abiertos_oracle.png`.*

**Retroalimentacion:** La consulta filtra incidentes abiertos y agrega, si estan asociados, el serial de la bicicleta y el nombre del cliente. La ejecucion y las filas reales siguen pendientes de captura.

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

**Evidencia de ejecucion:**
**Oracle: Resumir pagos realizados por mes**
*Captura pendiente: `oracle_ingresos_pagados_por_mes_oracle.png`.*

**Retroalimentacion:** La consulta filtra pagos pagados, agrupa por mes y calcula cantidad e importe mensual. La ejecucion y los valores devueltos siguen pendientes de captura.

**Lo que aprendi:** Aprendi a agrupar los pagos completados por mes; la funcion para expresar ano y mes depende del motor.

## Consultas propias de cada motor

Ademas de las consultas comunes, preparo una consulta que aprovecha una funcion propia de cada motor. Las ejecuto solo en el motor indicado; las capturas y la retroalimentacion del resultado se agregaran despues de que las ejecutes en DBeaver.

### MySQL: agrupar alquileres con `GROUP_CONCAT`

Esta consulta resume los alquileres de cada cliente y concatena sus identificadores ordenados del mas reciente al mas antiguo.

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
*Captura pendiente: `mysql_alquileres_por_cliente_group_concat.png`.*

**Retroalimentacion:** `GROUP_CONCAT` combina en una sola cadena los identificadores de alquiler por cliente, ordenados por fecha descendente. Anotare los clientes y los identificadores que devuelva DBeaver despues de ejecutar la consulta.

**Lo que aprendi:** Aprendere a usar `GROUP_CONCAT` de MySQL para resumir varios registros relacionados en una sola fila.

### PostgreSQL: comparar estados de pago con `FILTER`

Esta consulta compara en una fila por metodo el numero de pagos pagados, pendientes y reembolsados, y suma el importe pagado.

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
*Captura pendiente: `postgresql_pagos_por_estado_filter.png`.*

**Retroalimentacion:** La clausula `FILTER` permite calcular conteos distintos por estado dentro de una sola agrupacion por metodo. `COALESCE` presenta cero si un metodo no tiene pagos pagados. Anotare las cantidades e importes que muestre DBeaver.

**Lo que aprendi:** Aprendere a filtrar cada agregado de PostgreSQL sin separar el resultado en varias consultas.

### SQL Server: duración media de alquiler por tipo de bicicleta

Esta consulta usa `DATEDIFF` para calcular la duracion en minutos de los alquileres completados y promedia el resultado por tipo de bicicleta.

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
*Captura pendiente: `sqlserver_duracion_alquiler_por_tipo_datediff.png`.*

**Retroalimentacion:** `DATEDIFF(MINUTE, ...)` mide los minutos entre el inicio y el fin de cada alquiler completado; el promedio se agrupa por tipo de bicicleta. Anotare los tipos, cantidades y duraciones devueltos al ejecutar la consulta.

**Lo que aprendi:** Aprendere a calcular intervalos de tiempo con `DATEDIFF` de SQL Server y a resumirlos por categoria.

### Oracle: obtener el importe del alquiler más reciente con `KEEP`

Esta consulta conserva a todos los clientes y recupera la fecha y el importe de su alquiler mas reciente. Si hay empate de fechas, `MAX` devuelve el importe mayor entre los alquileres empatados.

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

**Retroalimentacion:** La funcion de agregado `KEEP (DENSE_RANK LAST ...)` devuelve el importe asociado a la fecha maxima de alquiler por cliente. El `LEFT JOIN` mantiene clientes sin alquileres, que apareceran con fecha e importe nulos. Anotare las filas reales tras ejecutarla.

**Lo que aprendi:** Aprendere a usar `KEEP` y `DENSE_RANK` en Oracle para recuperar una medida de la fila que ocupa la posicion mas reciente dentro de cada grupo.

## Evidencia de trazabilidad

Debajo de cada evidencia puse el titulo del motor (MySQL, PostgreSQL, SQL Server u Oracle) y una retroalimentacion que explica para que sirve la consulta y que se observa en el resultado. Las primeras ocho capturas muestran 80 bicicletas disponibles y 67 alquileres completados en cada motor. Las consultas todavia no ejecutadas tienen la captura marcada como pendiente; completare su observacion cuando tenga el resultado real.

Capturas agregadas a [trazabilidad/](./trazabilidad/):

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
- Puntos de anclaje disponibles en MySQL: `mysql_puntos_disponibles_por_estacion_mysql.png`.
- Incidentes abiertos en MySQL: `mysql_incidentes_abiertos_mysql.png`.
- Ingresos pagados por mes en MySQL: `mysql_ingresos_pagados_por_mes_mysql.png`.

## Referencias

- [Guía docente de consultas MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/)
- [Guía docente de consultas PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/)
- [Guía docente de consultas Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/)
- [Guía docente de consultas Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/)
- [Guía del esquema PedalLibre](./Creacion%20de%20Tablas%20y%20Reguistros/guia.md)
- [Guia de insercion de datos](./Creacion%20de%20Tablas%20y%20Reguistros/guia_insert_datos.md)
