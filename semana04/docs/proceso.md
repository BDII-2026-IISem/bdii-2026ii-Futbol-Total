# Registro de uso de IA y verificación humana

**Proyecto:** Pedalibre
**Base de datos:** Según instalacion-modelos-base-datos.md

---

## Caso: Antes de la clase

### Parte 1: Prompt enviado a la IA

```
Para comprobar, agregar y hacer subconsultas a mi script SQL que te comparto, 
dame la estructura básica.
```

**Script SQL compartido:** (Base de datos Pedalibre con tablas cliente, bicicleta, alquiler)

---

### Parte 2: Respuesta de la IA

#### 1. Combinaciones, agregaciones y subconsultas

```sql
SELECT c.nombre, COUNT(a.id) AS cantidad_alquileres
FROM cliente c
INNER JOIN alquiler a ON c.id = a.cliente_id
WHERE a.total > (
    SELECT AVG(total)
    FROM alquiler
)
GROUP BY c.nombre;
```

#### 2. Expresiones comunes y vistas

```sql
CREATE VIEW vista_alquileres AS
SELECT c.nombre AS cliente, b.nombre AS bicicleta, a.total
FROM alquiler a
INNER JOIN cliente c ON a.cliente_id = c.id
INNER JOIN bicicleta b ON a.bicicleta_id = b.id;
```

#### 3. Funciones, procedimientos o disparadores

```sql
DELIMITER //

CREATE PROCEDURE listar_alquileres()
BEGIN
    SELECT *
    FROM alquiler;
END //

DELIMITER ;

CALL listar_alquileres();
```

#### 4. Índices y planes de ejecución

```sql
CREATE INDEX idx_alquiler_estado
ON alquiler(estado);

EXPLAIN
SELECT *
FROM alquiler
WHERE estado = 'FINALIZADO';
```

---

### Parte 3: Verificación humana y mejoras que apliqué

**Estado:** ✅ Verificado y mejorado por mí

**Cambios que realicé:**

#### 1. Combinaciones, agregaciones y subconsultas — MEJORADO

```sql
SELECT 
    c.nombre AS cliente,
    COUNT(a.id) AS cantidad_alquileres,
    SUM(a.total) AS total_alquileres
FROM cliente c
INNER JOIN alquiler a 
    ON c.id = a.cliente_id
WHERE a.total > (
    SELECT AVG(total)
    FROM alquiler
)
GROUP BY c.id, c.nombre;
```

**¿Qué mejoré?**

Combiné tres conceptos en una sola consulta: `INNER JOIN` relaciona clientes con sus alquileres, `COUNT()` y `SUM()` realizan agregaciones, y la subconsulta calcula el promedio de los alquileres para mostrar únicamente los que están por encima de ese valor.

---

#### 2. Expresiones comunes y vistas — MEJORADO

```sql
CREATE VIEW vista_resumen_alquileres AS
WITH resumen AS (
    SELECT 
        cliente_id,
        COUNT(*) AS cantidad_alquileres,
        SUM(total) AS total_gastado
    FROM alquiler
    GROUP BY cliente_id
)
SELECT 
    c.nombre AS cliente,
    r.cantidad_alquileres,
    r.total_gastado
FROM resumen r
INNER JOIN cliente c
    ON c.id = r.cliente_id;
```

**¿Qué mejoré?**

Utilicé una expresión común (`WITH`) para organizar el cálculo de los alquileres por cliente y posteriormente convertí el resultado en una vista. Esto me permite consultar el resumen sin tener que escribir nuevamente toda la consulta.

---

#### 3. Funciones, procedimientos o disparadores — MEJORADO

```sql
DELIMITER //

CREATE PROCEDURE consultar_alquileres_cliente(IN p_cliente_id INT)
BEGIN
    SELECT 
        a.id,
        b.nombre AS bicicleta,
        a.fecha_inicio,
        a.fecha_fin,
        a.total,
        a.estado
    FROM alquiler a
    INNER JOIN bicicleta b
        ON a.bicicleta_id = b.id
    WHERE a.cliente_id = p_cliente_id;
END //

DELIMITER ;

CALL consultar_alquileres_cliente(1);
```

**¿Qué mejoré?**

Creé un procedimiento almacenado que recibe el ID de un cliente como parámetro y muestra sus alquileres junto con la bicicleta utilizada. Esto me permite reutilizar la consulta simplemente ejecutando `CALL`.

---

#### 4. Índices y planes de ejecución — MEJORADO

```sql
CREATE INDEX idx_alquiler_cliente_estado
ON alquiler(cliente_id, estado);

EXPLAIN
SELECT *
FROM alquiler
WHERE cliente_id = 1
AND estado = 'FINALIZADO';
```

**¿Qué mejoré?**

Creé un índice compuesto sobre `cliente_id` y `estado`, que son las columnas utilizadas para filtrar la consulta. Luego, usé `EXPLAIN` para analizar el plan de ejecución y comprobar cómo MySQL busca los registros.

---

### Decisiones y conclusiones

- ✅ Validé y mejoré las consultas.
- ✅ Apliqué mejores prácticas en agrupación y nomenclatura.
- ✅ Añadí índices para optimizar performance.
- ✅ Documenté los cambios para referencias futuras.

---

## Caso: Durante la clase

### Parte 1: Prompt enviado a la IA

**Pregunta:**
```
(Aquí va tu pregunta durante la clase)
```

---

### Parte 2: Respuesta de la IA

(Aquí va la respuesta de la IA)

---

### Parte 3: Verificación humana y mejoras que apliqué

**Estado:** ✅ Verificado y mejorado por mí

(Aquí documentas lo que verificaste y mejoraste)
