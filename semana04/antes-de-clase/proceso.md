# Lo importante para ti como estudiante

## Semana 04: Obtención y transformación eficiente de información

### Objetivo

Aplica consultas avanzadas en tu proyecto: combinaciones, agregaciones, subconsultas, vistas, funciones o procedimientos, e índices.

### Lo que debes hacer

1. Revisar la guía de la semana y entender el tema principal.
2. Trabajar en tu proyecto con estas partes:
   - combinaciones, agregaciones y subconsultas
   - expresiones comunes y vistas
   - funciones, procedimientos o disparadores
   - índices y planes de ejecución
3. Guardar evidencia en tu repositorio (capturas, SQL ejecutado o documentos).
4. Registrar en la bitácora lo que hiciste, qué decisiones tomaste y si usaste IA.
5. Dejar todo listo para entregar con orden y trazabilidad.

### Lo que debo trabajar en mi proyecto

### Código para entrar a la base de datos y ejecutar la consulta

Para conectarte a tu base de datos MySQL desde WSL Ubuntu:

**Entro a MySQL:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

**Ejecuto mi consulta:**

```sql
SELECT *
FROM cliente
LIMIT 10;
```

**Salgo de MySQL:**

```bash
EXIT;
```

---

#### 1. Combinaciones, agregaciones y subconsultas

**¿Por qué la necesito?**
Necesito consultar a los clientes que han gastado más que el promedio en alquileres, combinando información de clientes y alquileres, además de calcular totales y conteos.

**Entro a la base de datos desde WSL Ubuntu:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

**Inserto datos de prueba - Clientes:**

```sql
INSERT INTO cliente (tipo_documento, numero_documento, nombre, email, telefono) VALUES
('CC', '1001234567', 'Juan Pérez', 'juan@example.com', '3001234567'),
('CC', '1007654321', 'María García', 'maria@example.com', '3007654321'),
('CC', '1009876543', 'Carlos López', 'carlos@example.com', '3009876543');
```

**Inserto datos de prueba - Bicicletas:**

```sql
INSERT INTO bicicleta (nombre, descripcion) VALUES
('Bici 001', 'Bicicleta de montaña roja'),
('Bici 002', 'Bicicleta urbana azul'),
('Bici 003', 'Bicicleta de carretera negra');
```

**Inserto datos de prueba - Alquileres:**

```sql
INSERT INTO alquiler (bicicleta_id, cliente_id, fecha_inicio, fecha_fin, total, estado) VALUES
(1, 1, '2026-01-01 08:00:00', '2026-01-02 18:00:00', 50000, 'FINALIZADO'),
(2, 1, '2026-01-05 09:00:00', '2026-01-07 17:00:00', 100000, 'FINALIZADO'),
(3, 2, '2026-01-10 10:00:00', '2026-01-11 16:00:00', 30000, 'FINALIZADO'),
(1, 3, '2026-01-15 11:00:00', '2026-01-16 15:00:00', 45000, 'FINALIZADO');
```

**Ejecuto mi consulta:**

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

**Salgo de la base de datos:**

```bash
EXIT;
```

**¿Qué hace mi consulta?**
Utilicé un `INNER JOIN` para relacionar clientes con sus alquileres, apliqué `COUNT()` y `SUM()` para agregar datos, y una subconsulta para mostrar únicamente los clientes con alquileres por encima del promedio.

**Evidencia:**

![Query 1 - Combinaciones, agregaciones y subconsultas](../../Reguistro%20visual/image%20copy%2064.png)

---

#### 2. Expresiones comunes y vistas

**¿Por qué la necesito?**
Necesito crear una vista que me resuma los alquileres por cliente de forma clara y reutilizable, sin tener que escribir la misma consulta cada vez.

**Entro a la base de datos desde WSL Ubuntu:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

**Creo mi vista:**

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

**Consulto mi vista:**

```sql
SELECT * FROM vista_resumen_alquileres;
```

**Salgo de la base de datos:**

```bash
EXIT;
```

**¿Qué hace mi consulta?**
Utilicé una expresión común (`WITH`) para organizar el cálculo de alquileres por cliente, y luego la convertí en una vista. Esto me permite consultar el resumen de forma simple sin repetir todo el código.

**Evidencia:**

![Query 2 - Expresiones comunes y vistas](../../Reguistro%20visual/image%20copy%2065.png)

---

#### 3. Funciones, procedimientos o disparadores

**¿Por qué la necesito?**
Necesito un procedimiento almacenado que me permita consultar todos los alquileres de un cliente específico junto con los datos de la bicicleta, sin escribir la consulta completa cada vez.

**Entro a la base de datos desde WSL Ubuntu:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

**Creo mi procedimiento almacenado:**

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
```

**Ejecuto mi procedimiento:**

```sql
CALL consultar_alquileres_cliente(1);
```

**Salgo de la base de datos:**

```bash
EXIT;
```

**¿Qué hace mi consulta?**
Creé un procedimiento que recibe el ID de un cliente como parámetro y retorna sus alquileres con los datos de las bicicletas. Solo necesito ejecutar `CALL` y cambiar el número del cliente.

**Evidencia:**

![Query 3 - Funciones, procedimientos o disparadores](../../Reguistro%20visual/image%20copy%2066.png)

---

#### 4. Índices y planes de ejecución

**¿Por qué la necesito?**
Necesito optimizar las búsquedas por estado de alquiler, creando un índice compuesto que acelere las consultas que filtran por cliente y estado.

**Entro a la base de datos desde WSL Ubuntu:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

**Creo mi índice compuesto:**

```sql
CREATE INDEX idx_alquiler_cliente_estado
ON alquiler(cliente_id, estado);
```

**Analizo el plan de ejecución:**

```sql
EXPLAIN
SELECT *
FROM alquiler
WHERE cliente_id = 1
AND estado = 'FINALIZADO';
```

**Salgo de la base de datos:**

```bash
EXIT;
```

**¿Qué hace mi consulta?**
Creé un índice compuesto sobre `cliente_id` y `estado`, que son las columnas que más utilizo para filtrar. Luego usé `EXPLAIN` para analizar el plan de ejecución y comprobar que MySQL usa mi índice correctamente.

**Evidencia:**

![Query 4 - Índices y planes de ejecución](../../Reguistro%20visual/image%20copy%2067.png)

---

### Conclusión de esta parte

- ✅ Apliqué las 4 técnicas clave de consultas avanzadas en mi proyecto Pedalibre.
- ✅ Cada consulta tiene un propósito específico en mi base de datos.
- ✅ Guardé evidencia visual de cada ejecución.
- ✅ Registré las decisiones y mejoras que realicé.
