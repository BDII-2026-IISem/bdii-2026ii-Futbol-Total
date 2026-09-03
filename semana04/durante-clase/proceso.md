# Proceso - Durante la clase

## Semana 04: Obtención y transformación eficiente de información

En esta sesión voy a usar la misma base de datos Pedalibre de antes de clase,
pero realizaré pruebas nuevas sobre `estacion`, `bicicleta` y `anclaje`.
Aquí registro el procedimiento que voy a seguir en WSL Ubuntu. La explicación
de mis decisiones y del uso de IA queda registrada en la bitácora técnica.

## Preparación

### 1. Voy a comprobar el contenedor de MySQL

```bash
docker ps
```

Voy a continuar solo si aparece `mysql-server`.

### 2. Voy a entrar a Pedalibre

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

### 3. Voy a revisar las tablas que utilizaré

```sql
SELECT id, nombre
FROM estacion
ORDER BY id;
```

```sql
SELECT id, nombre, is_active
FROM bicicleta
ORDER BY id;
```

```sql
SELECT id, estacion_id, bicicleta_id, nombre, is_active
FROM anclaje
ORDER BY id;
```

Voy a revisar visualmente en WSL los resultados de estas tres consultas para
confirmar las tablas y los datos que utilizaré en esta sesión.

![Prueba de las tablas que utilizaré](<../../Reguistro%20visual/image%20copy%2069.png>)

La inserción de los datos ya está documentada en la bitácora técnica, por lo
que no la repito en este proceso.

---

## AC-S04-01: Combinaciones, agregaciones y subconsultas

### 5. Voy a ejecutar la consulta

```sql
SELECT
    e.nombre AS estacion,
    COUNT(DISTINCT a.bicicleta_id) AS bicicletas_ancladas,
    COUNT(a.id) AS total_anclajes
FROM estacion e
LEFT JOIN anclaje a
    ON e.id = a.estacion_id
    AND a.is_active = TRUE
GROUP BY e.id, e.nombre
HAVING COUNT(DISTINCT a.bicicleta_id) >= (
    SELECT AVG(cantidad_bicicletas)
    FROM (
        SELECT COUNT(DISTINCT bicicleta_id) AS cantidad_bicicletas
        FROM anclaje
        WHERE bicicleta_id IS NOT NULL
          AND is_active = TRUE
        GROUP BY estacion_id
    ) AS promedios
);
```

Voy a revisar debajo de `mysql>` las estaciones que cumplen la comparación
con el promedio. Después colocaré la captura en este espacio:

**Evidencia AC-S04-01:**

![Resultado AC-S04-01](<../../Reguistro%20visual/image%20copy%2070.png>)

**Resultado:** La consulta mostró la Estación Norte - Clase con 2 bicicletas
ancladas y 2 anclajes.

### 6. Voy a salir de MySQL

```sql
EXIT;
```

## AC-S04-02: Expresiones comunes, vistas y analítica

### 7. Voy a volver a entrar

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

### 8. Voy a preparar la vista

```sql
DROP VIEW IF EXISTS vista_disponibilidad_estaciones;
```

```sql
CREATE VIEW vista_disponibilidad_estaciones AS
WITH conteo AS (
    SELECT
        estacion_id,
        COUNT(*) AS total_anclajes,
        SUM(CASE WHEN bicicleta_id IS NULL THEN 1 ELSE 0 END)
            AS anclajes_libres
    FROM anclaje
    WHERE is_active = TRUE
    GROUP BY estacion_id
)
SELECT
    e.nombre AS estacion,
    c.total_anclajes,
    c.anclajes_libres,
    ROUND(c.anclajes_libres * 100.0 / c.total_anclajes, 2)
        AS porcentaje_disponible
FROM estacion e
INNER JOIN conteo c ON e.id = c.estacion_id;
```

### 9. Voy a consultar la vista

```sql
SELECT *
FROM vista_disponibilidad_estaciones
ORDER BY porcentaje_disponible DESC;
```

Voy a revisar visualmente la tabla y colocaré la captura aquí:

**Evidencia AC-S04-02:**

![Resultado AC-S04-02](../../Reguistro%20visual/image%20copy%2071.png)

**Resultado:** La vista mostró la Estación Sur - Clase con 1 anclaje libre y
100.00% de disponibilidad, y la Estación Norte - Clase con 0 anclajes libres
y 0.00% de disponibilidad.

### 10. Voy a salir de MySQL

```sql
EXIT;
```

---

## AC-S04-03: Funciones, procedimientos o disparadores

### 11. Voy a volver a entrar

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

### 12. Voy a crear el procedimiento

```sql
DROP PROCEDURE IF EXISTS consultar_bicicletas_disponibles;
```

```sql
DELIMITER //

CREATE PROCEDURE consultar_bicicletas_disponibles(IN p_estacion_id INT)
BEGIN
    SELECT
        e.nombre AS estacion,
        a.nombre AS anclaje,
        b.nombre AS bicicleta
    FROM anclaje a
    INNER JOIN estacion e ON e.id = a.estacion_id
    LEFT JOIN bicicleta b ON b.id = a.bicicleta_id
    WHERE a.estacion_id = p_estacion_id
      AND a.bicicleta_id IS NULL
      AND a.is_active = TRUE;
END //

DELIMITER ;
```

### 13. Voy a obtener el ID y ejecutar el procedimiento

```sql
SET @estacion_prueba = (
    SELECT id
    FROM estacion
    WHERE nombre = 'Estación Sur - Clase'
);
```

```sql
CALL consultar_bicicletas_disponibles(@estacion_prueba);
```

Voy a comprobar visualmente que aparezca el anclaje libre y colocaré la
captura aquí:

**Evidencia AC-S04-03:**

![Resultado AC-S04-03](../../Reguistro%20visual/image%20copy%2072.png)

**Resultado:** El procedimiento encontró 1 anclaje libre en la Estación Sur -
Clase: `Anclaje Sur 01`, sin bicicleta asignada.

### 14. Voy a salir de MySQL

```sql
EXIT;
```

---

## AC-S04-04: Índices y planes de ejecución

### 15. Voy a volver a entrar

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

### 16. Voy a crear el índice

```sql
CREATE INDEX idx_anclaje_estacion_activo
ON anclaje(estacion_id, is_active, bicicleta_id);
```

Si el índice ya existe, voy a continuar con el siguiente bloque sin volver a
crearlo.

### 17. Voy a ejecutar `EXPLAIN`

```sql
EXPLAIN
SELECT id, nombre, bicicleta_id
FROM anclaje
WHERE estacion_id = (
    SELECT id
    FROM estacion
    WHERE nombre = 'Estación Norte - Clase'
)
AND is_active = TRUE
AND bicicleta_id IS NULL;
```

Voy a revisar visualmente la columna `key` en WSL y colocaré aquí la captura:

**Evidencia AC-S04-04:**

![Resultado AC-S04-04](../../Reguistro%20visual/image%20copy%2073.png)

**Resultado:** El índice `idx_anclaje_estacion_activo` fue creado
correctamente y el resultado de `EXPLAIN` mostró que MySQL lo considera entre
las claves posibles para la consulta.

### 18. Voy a salir de MySQL

```sql
EXIT;
```

## Conclusión final

En durante la clase trabajé sobre la misma base de datos Pedalibre, pero
realicé pruebas diferentes a las de antes de clase utilizando las tablas
`estacion`, `bicicleta` y `anclaje`. Combiné tablas y utilicé agregaciones y
subconsultas para analizar las estaciones; creé una vista para consultar la
disponibilidad; desarrollé un procedimiento para encontrar anclajes libres; y
creé un índice que revisé con `EXPLAIN`.

Ejecuté los comandos desde WSL Ubuntu, observé los resultados directamente en
MySQL y guardé evidencias visuales de cada actividad. Con esto comprobé que
puedo aplicar las cuatro técnicas solicitadas sobre datos reales de mi
proyecto y documentar el proceso de forma ordenada.
