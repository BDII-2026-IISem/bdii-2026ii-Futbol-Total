# Consultas SQL de PedalLibre en cuatro motores

## Introducción

En este informe documento las consultas que voy a ejecutar en DBeaver sobre las bases de datos de PedalLibre. Tomo como referencia los ejemplos de consulta de las guías docentes de [MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/), [PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/), [Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/) y [Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/), adaptándolos a las tablas reales del proyecto.

Me concentro en consultas de lectura que permiten revisar registros, filtrar resultados, relacionar tablas y resumir información. No vuelvo a crear ni modificar tablas o registros, y no incluyo triggers. Las consultas principales usan sintaxis común a los cuatro motores; las consultas para limitar resultados se muestran por separado cuando cambia la sintaxis.

## Base de datos y tablas

En la carpeta [Creacion de Tablas y Reguistros](./Creacion%20de%20Tablas%20y%20Reguistros/) consulté la guía del esquema y los scripts de datos de prueba. Estos describen 21 tablas del dominio PedalLibre: `roles`, `users`, `clients`, `stations`, `station_locations`, `station_schedules`, `docking_points`, `bicycles`, `bicycle_dockings`, `reservations`, `rates`, `rentals`, `rental_events`, `penalties`, `maintenance`, `payments`, `incidents`, `notifications`, `bicycle_history`, `reviews` e `invoices`. El script de datos de prueba contempla 100 registros por tabla y por motor.

Por tanto, las tablas que consultaré son las tablas adicionales del proyecto, creadas sobre cada motor; no son tablas que se creen automáticamente al instalar MySQL, PostgreSQL, SQL Server u Oracle. La verificación se basa en los archivos SQL del proyecto; no he abierto las conexiones locales para comprobar en vivo el estado actual de cada servidor.

### Conexiones que usaré

| Motor | Base de datos o esquema indicado |
|---|---|
| MySQL | `Pedalibre-Terminal-Dbeaver` |
| Microsoft SQL Server | `Pedalibre-Terminal-Dbeaver` |
| PostgreSQL | `Pedalibre-Terminal-Dbeaver` |
| Oracle | Esquema `PEDALIBRETERMINALDBEAVER` |

**Observación para MySQL:** el nombre indicado para la conexión es `Pedalibre-Terminal-Dbeaver`, pero tanto la guía del esquema como el script de datos de prueba identifican la base MySQL como `Pedalibre-DW`. Antes de ejecutar, selecciono en DBeaver la base que realmente contiene las 21 tablas y confirmo ese nombre en el navegador de bases de datos. No ejecuto `USE` a ciegas ni cambio la base de destino.

## Procedimiento en DBeaver

1. Abro DBeaver y localizo la conexión correspondiente al motor con el que voy a trabajar.
2. Confirmo que la conexión esté activa y selecciono la base de datos o el esquema de la tabla PedalLibre. Para Oracle uso el esquema `PEDALIBRETERMINALDBEAVER`.
3. Abro un editor SQL asociado a esa conexión y verifico el nombre de la conexión/base antes de ejecutar cualquier comando.
4. Compruebo que existen las tablas del proyecto con el comando de inspección indicado para el motor. Si no aparecen `bicycles`, `rentals`, `payments` y las demás tablas del esquema, detengo la ejecución y corrijo la conexión o el esquema seleccionado.
5. Ejecuto una consulta a la vez: selecciono el bloque completo y uso **Ejecutar sentencia** en DBeaver. Las consultas de este informe son de solo lectura.
6. Reviso las filas devueltas en la cuadrícula de resultados. Las filas exactas pueden variar según los datos cargados en la base.
7. Para la evidencia de trazabilidad, tomo una captura donde se distingan la conexión, la consulta ejecutada y su resultado. Guardo la imagen que aportaré en `trazabilidad/`, con el nombre del motor, por ejemplo `mysql.png`, `postgresql.png`, `sqlserver.png` u `oracle.png`.

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

### 2. Consultar alquileres completados

Aplico un filtro por estado y ordeno los alquileres desde el más reciente. Limito la salida a las primeras 10 filas con la variante del motor descrita en la sección correspondiente.

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

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

## Comandos específicos de cada motor

### MySQL

Conecto a la base indicada y verifico el esquema. Si la lista está vacía o no corresponde a PedalLibre, no continúo hasta seleccionar la base correcta.

```sql
SHOW TABLES;
```

Para limitar la consulta de alquileres completados a 10 filas, agrego `LIMIT 10` al final:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

### PostgreSQL

Verifico las tablas visibles en el esquema `public`:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

Para limitar la consulta de alquileres completados a 10 filas, uso `LIMIT 10`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
LIMIT 10;
```

### Microsoft SQL Server

Verifico las tablas del esquema actual:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

Para limitar la consulta de alquileres completados a 10 filas, uso `TOP (10)`:

```sql
SELECT TOP (10)
    rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC;
```

### Oracle

Verifico las tablas accesibles para el usuario conectado. Si el usuario tiene seleccionado el esquema `PEDALIBRETERMINALDBEAVER`, sus tablas aparecen en `USER_TABLES`.

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

Para limitar la consulta de alquileres completados a 10 filas, uso `FETCH FIRST 10 ROWS ONLY`:

```sql
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC
FETCH FIRST 10 ROWS ONLY;
```

## Evidencia de trazabilidad

Guardaré aquí las capturas reales de ejecución que aportaré, sin sustituirlas por imágenes ilustrativas:

- `trazabilidad/mysql.png`
- `trazabilidad/postgresql.png`
- `trazabilidad/sqlserver.png`
- `trazabilidad/oracle.png`

Cada captura debe mostrar en DBeaver el motor/conexión, el comando ejecutado y el resultado. La carpeta se prepara junto con este informe; las imágenes se añadirán cuando estén disponibles.

## Referencias

- [Guía docente de consultas MySQL](https://tecnogua.com/academic/site/bd/gestion/mysql/mysql/)
- [Guía docente de consultas PostgreSQL](https://tecnogua.com/academic/site/bd/gestion/postgresql/postgresql/)
- [Guía docente de consultas Microsoft SQL Server](https://tecnogua.com/academic/site/bd/gestion/mssql/mssql/)
- [Guía docente de consultas Oracle](https://tecnogua.com/academic/site/bd/gestion/oracle/oracle/)
- [Guía del esquema PedalLibre](./Creacion%20de%20Tablas%20y%20Reguistros/guia.md)
- [Datos de prueba por motor](./Creacion%20de%20Tablas%20y%20Reguistros/seed_100_por_motor.md)
