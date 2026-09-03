# Actividad de trabajo autónomo:

1. Completar «Combinaciones, agregaciones y subconsultas» y consolidar la evidencia.
2. Completar «Expresiones comunes, vistas y analítica» y consolidar la evidencia.
3. Completar «Funciones, procedimientos o disparadores» y consolidar la evidencia.
4. Actualizar el Kanban, la bitácora y el registro de IA.

---

## Bitácora de trabajo - Pedalibre

### Estructura esperada del proyecto

```text
~/ia-lab/
└── projecs/
    └── base de datos 2/
        └── semana04/
            ├── antes-de-clase/
            │   ├── proceso.md
            │   └── kanban.md
            ├── durante-clase/
            │   ├── proceso.md
            │   └── kanban.md
            ├── despues-de-clase/
            │   ├── proceso.md
            │   └── kanban.md
            └── docs/
                ├── proceso.md
                └── bitacora-tecnica.md
```

## Parte 1: Creación de la estructura de la semana 04

### Bloque 1: entrar a la carpeta del proyecto

```bash
cd ~/ia-lab/projecs/"base de datos 2"
```

### Bloque 2: crear las carpetas principales

```bash
mkdir -p semana04/antes-de-clase
mkdir -p semana04/durante-clase
mkdir -p semana04/despues-de-clase
mkdir -p semana04/docs
```

### Bloque 3: crear los archivos markdown en blanco

```bash
touch semana04/antes-de-clase/proceso.md
touch semana04/antes-de-clase/kanban.md
touch semana04/durante-clase/proceso.md
touch semana04/durante-clase/kanban.md
touch semana04/despues-de-clase/proceso.md
touch semana04/despues-de-clase/kanban.md
touch semana04/docs/proceso.md
touch semana04/docs/bitacora-tecnica.md
```

### Bloque 4: verificar la estructura

```bash
ls -R semana04
```

Resultado: quedó creada la carpeta `semana04` con las tres fases del trabajo académico (`antes-de-clase`, `durante-clase` y `despues-de-clase`) y la carpeta `docs`, todos los archivos `proceso.md`, `kanban.md` y `bitacora-tecnica.md` en blanco y listos para completar.

![Evidencia Parte 1](<../../Reguistro visual/image copy 62.png>)

---

### Bloque 5: Registrar cambios en Git

**Comandos ejecutados:**

```bash
git status
```

Resultado: Había archivos sin seguimiento en `semana04/`

```bash
git add .
```

Resultado: Agregué todos los archivos para preparar el commit.

```bash
git commit -m "Se creo la estructura de la semana 4 y se subio una primera parte que se muestra como se crea esa estructuta en el documento (bitacora-tecnica.md)"
```

Resultado: Se creó el commit con 8 files changed, 73 insertions(+)

```bash
git push
```

Resultado: Se subió exitosamente a GitHub:

- Rama: main
- Commit: c127e58..1a5b33c
- URL: https://github.com/BDII-2026-IISem/bdii-2026ii-Futbol-Total.git

**Fecha y hora del registro:** Tue Sep 1 15:14:45 -05 2026

---

![Evidencia Parte 1 - Proceso Git](<../../Reguistro visual/image copy 63.png>)

**¿Qué hice?**
Utilicé Git para registrar todos los cambios de la estructura que creé. Ejecuté `git status` para verificar archivos sin seguimiento, `git add .` para preparar los cambios, `git commit` para guardarlos localmente con un mensaje descriptivo, y `git push` para subirlos a mi repositorio remoto en GitHub.

---

### Resumen de Parte 1

✅ Creé la estructura de semana 04 en mi repositorio local
✅ Registré evidencia visual del proceso
✅ Documenté cada paso en la bitácora técnica
✅ Agregué, commiteé y subí los cambios a GitHub
✅ Mantuve trazabilidad completa del trabajo realizado

---

## Parte 2: Antes de la clase

### Objetivo General
Completar 4 técnicas avanzadas de consultas SQL:
1. Combinaciones, agregaciones y subconsultas
2. Expresiones comunes y vistas
3. Funciones, procedimientos o disparadores
4. Índices y planes de ejecución

---

### Bloque 1: Combinaciones, agregaciones y subconsultas

**Descripción:** Apliqué `INNER JOIN` para combinar datos de clientes y alquileres, usé funciones de agregación (`COUNT()`, `SUM()`), e implementé una subconsulta para filtrar clientes con gasto superior al promedio.

**Pasos ejecutados:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

Datos de prueba insertados:
- 3 clientes (Juan Pérez, María García, Carlos López)
- 3 bicicletas con descripciones
- 4 registros de alquiler

Consulta ejecutada:
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

**Resultado:** 1 fila retornada - Juan Pérez con 1 alquiler y total de 100000.00 (por encima del promedio)

**Decisiones técnicas:**
- Usé `INNER JOIN` para relacionar solo clientes con alquileres
- La subconsulta calcula el promedio de gastos dinámicamente
- Agrupé por cliente para consolidar múltiples alquileres

**¿Usé IA?** Sí, para corregir los campos faltantes en la tabla (`numero_documento` en cliente).

![Evidencia Query 1](<../../Reguistro visual/image copy 64.png>)

---

### Bloque 2: Expresiones comunes y vistas

**Descripción:** Creé una vista reutilizable usando una expresión común (CTE con `WITH`) que calcula resumen de alquileres por cliente de forma clara y mantenible.

**Pasos ejecutados:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

Vista creada:
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

Consulta ejecutada:
```sql
SELECT * FROM vista_resumen_alquileres;
```

**Resultado:** 3 filas retornadas con resumen de alquileres por cliente:
- Juan Pérez: 2 alquileres, 150000.00
- María García: 1 alquiler, 30000.00
- Carlos López: 1 alquiler, 45000.00

**Decisiones técnicas:**
- Usé CTE (`WITH`) para separar la lógica de agregación
- La vista facilita reutilización sin escribir la consulta completa
- No necesité re-insertar datos; usé los mismos de Query 1

**¿Usé IA?** Sí, para identificar que no era necesario duplicar INSERTs en cada query.

![Evidencia Query 2](<../../Reguistro visual/image copy 65.png>)

---

### Bloque 3: Funciones, procedimientos o disparadores

**Descripción:** Creé un procedimiento almacenado parametrizado que retorna todos los alquileres de un cliente específico con detalles de la bicicleta.

**Pasos ejecutados:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

Procedimiento creado:
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

Procedimiento ejecutado:
```sql
CALL consultar_alquileres_cliente(1);
```

**Resultado:** 2 filas retornadas con alquileres del cliente 1:
- Bici 001, 2026-01-01 a 2026-01-02, 50000.00, FINALIZADO
- Bici 002, 2026-01-05 a 2026-01-07, 100000.00, FINALIZADO

**Decisiones técnicas:**
- Usé parámetro `IN` para recibir el ID del cliente
- El procedimiento encapsula la lógica de consulta compleja
- Permite reutilizar sin modificar código SQL

**¿Usé IA?** Sí, para optimizar la sintaxis de procedimientos.

![Evidencia Query 3](<../../Reguistro visual/image copy 66.png>)

---

### Bloque 4: Índices y planes de ejecución

**Descripción:** Creé un índice compuesto sobre las columnas más utilizadas en filtros (`cliente_id` y `estado`) y analicé su impacto con `EXPLAIN`.

**Pasos ejecutados:**

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

Índice creado:
```sql
CREATE INDEX idx_alquiler_cliente_estado
ON alquiler(cliente_id, estado);
```

Plan de ejecución analizado:
```sql
EXPLAIN
SELECT *
FROM alquiler
WHERE cliente_id = 1
AND estado = 'FINALIZADO';
```

**Resultado:** El índice fue utilizado correctamente:
- Tipo: ref (reference, óptimo para búsquedas)
- Clave usada: idx_alquiler_cliente_estado
- Filas escaneadas: 2 (eficiente)
- Filtrado: 100% (todas las filas coinciden)

**Decisiones técnicas:**
- Creé índice compuesto (no simple) para optimizar filtros combinados
- El orden (cliente_id, estado) sigue la regla de selectividad
- Verificué con EXPLAIN que el índice realmente se utiliza

**¿Usé IA?** Sí, para optimizar el orden de columnas en el índice.

![Evidencia Query 4](<../../Reguistro visual/image copy 67.png>)

---

## Resumen de Parte 2

✅ Completé las 4 técnicas de consultas avanzadas
✅ Documenté cada consulta con explicación clara
✅ Capturé evidencia visual de cada ejecución
✅ Registré decisiones técnicas y uso de IA
✅ Todos los queries funcionaron correctamente con datos reales

**Evidencia consolidada:**
- Query 1 (Combinaciones): 1 resultado (clientes arriba del promedio)
- Query 2 (Vistas): 3 resultados (resumen por cliente)
- Query 3 (Procedimientos): 2 resultados (alquileres del cliente 1)
- Query 4 (Índices): Índice optimizado y verificado con EXPLAIN

---

## Parte 3: Durante la clase

### Objetivo

En esta parte trabajé sobre la misma base de datos Pedalibre, pero realicé
pruebas diferentes a las de antes de clase. Utilicé las tablas `estacion`,
`bicicleta` y `anclaje`, ejecuté los comandos desde WSL Ubuntu y registré los
resultados obtenidos.

### Preparación y datos para las nuevas pruebas

Primero comprobé que MySQL estuviera activo con `docker ps` y entré a la base
de datos con:

```bash
mysql -h 127.0.0.1 -u root -p1704 Pedalibre
```

Después revisé las tablas de estaciones, bicicletas y anclajes para confirmar
los datos que utilizaría en las pruebas.

![Prueba de las tablas utilizadas](<../../Reguistro%20visual/image%20copy%2069.png>)

Agregué 2 estaciones, 3 bicicletas y 3 anclajes de prueba. MySQL confirmó cada
inserción con `Query OK`.

```sql
INSERT INTO estacion (nombre, descripcion) VALUES
('Estación Norte - Clase', 'Estación para pruebas de durante clase'),
('Estación Sur - Clase', 'Estación para pruebas de durante clase');
```

```sql
INSERT INTO bicicleta (nombre, descripcion) VALUES
('Bici Clase 004', 'Bicicleta urbana para pruebas'),
('Bici Clase 005', 'Bicicleta eléctrica para pruebas'),
('Bici Clase 006', 'Bicicleta de montaña para pruebas');
```

```sql
INSERT INTO anclaje (estacion_id, bicicleta_id, nombre, descripcion)
SELECT e.id, b.id, 'Anclaje Norte 01', 'Anclaje ocupado'
FROM estacion e
INNER JOIN bicicleta b ON b.nombre = 'Bici Clase 004'
WHERE e.nombre = 'Estación Norte - Clase';
```

```sql
INSERT INTO anclaje (estacion_id, bicicleta_id, nombre, descripcion)
SELECT e.id, b.id, 'Anclaje Norte 02', 'Anclaje ocupado'
FROM estacion e
INNER JOIN bicicleta b ON b.nombre = 'Bici Clase 005'
WHERE e.nombre = 'Estación Norte - Clase';
```

```sql
INSERT INTO anclaje (estacion_id, bicicleta_id, nombre, descripcion)
SELECT e.id, NULL, 'Anclaje Sur 01', 'Anclaje disponible'
FROM estacion e
WHERE e.nombre = 'Estación Sur - Clase';
```

### Evidencia de la inserción de datos

**Evidencia de la inserción:**

![Evidencia de inserción de datos](../../Reguistro%20visual/image%20copy%2068.png)

**Resultado:** Inserté correctamente 2 estaciones, 3 bicicletas y 3 anclajes
para realizar las pruebas de durante la clase desde WSL Ubuntu.

### AC-S04-01: Combinaciones, agregaciones y subconsultas

Consulté qué estaciones tenían una cantidad de bicicletas ancladas igual o
superior al promedio:

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

Este código combinó estaciones y anclajes, contó las bicicletas asignadas y
usó una subconsulta para compararlas con el promedio.

**Resultado:** La consulta mostró la `Estación Norte - Clase` con 2 bicicletas
ancladas y 2 anclajes.

![Evidencia AC-S04-01](<../../Reguistro%20visual/image%20copy%2070.png>)

### AC-S04-02: Expresiones comunes, vistas y analítica

Creé una vista que mostró la disponibilidad de cada estación:

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
INNER JOIN conteo c
    ON e.id = c.estacion_id;
```

Luego consulté la vista:

```sql
SELECT *
FROM vista_disponibilidad_estaciones
ORDER BY porcentaje_disponible DESC;
```

La expresión `WITH` calculó los anclajes libres y la vista presentó el
porcentaje de disponibilidad.

**Resultado:** La `Estación Sur - Clase` tuvo 1 anclaje libre y 100.00% de
disponibilidad. La `Estación Norte - Clase` tuvo 0 anclajes libres y 0.00% de
disponibilidad.

![Evidencia AC-S04-02](<../../Reguistro%20visual/image%20copy%2071.png>)

### AC-S04-03: Funciones, procedimientos o disparadores

Creé un procedimiento para buscar anclajes libres:

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
    INNER JOIN estacion e
        ON e.id = a.estacion_id
    LEFT JOIN bicicleta b
        ON b.id = a.bicicleta_id
    WHERE a.estacion_id = p_estacion_id
      AND a.bicicleta_id IS NULL
      AND a.is_active = TRUE;
END //

DELIMITER ;
```

Obtuve el ID de la estación Sur y ejecuté el procedimiento:

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

Este procedimiento recibió el ID de una estación y devolvió sus anclajes sin
bicicleta.

**Resultado:** Encontré 1 anclaje libre en la `Estación Sur - Clase`:
`Anclaje Sur 01`, sin bicicleta asignada.

![Evidencia AC-S04-03](<../../Reguistro%20visual/image%20copy%2072.png>)

### AC-S04-04: Índices y planes de ejecución

Creé un índice para acelerar la búsqueda de anclajes:

```sql
CREATE INDEX idx_anclaje_estacion_activo
ON anclaje(estacion_id, is_active, bicicleta_id);
```

Después analicé el plan de ejecución:

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

El índice `idx_anclaje_estacion_activo` se creó correctamente. Al ejecutar
`EXPLAIN`, MySQL lo consideró entre las claves posibles para buscar anclajes
activos y libres.

![Evidencia AC-S04-04](<../../Reguistro%20visual/image%20copy%2073.png>)

### Cierre de las pruebas

Después de cada actividad salí de MySQL:

```sql
EXIT;
```

Guardé una captura de cada resultado y la incorporé en este documento.

### Decisiones y uso de IA

- Utilicé la misma base de datos, pero realicé consultas diferentes a las de
  antes de clase.
- Agregué datos nuevos únicamente para probar estaciones, bicicletas y
  anclajes.
- Trabajé desde WSL Ubuntu usando la conexión por `127.0.0.1`.
- Utilicé la IA como apoyo para revisar la sintaxis y organizar los pasos, pero
  ejecuté, verifiqué y documenté los resultados.

### Registro de resultados

| Código | Actividad | Resultado | Evidencia |
|---|---|---|---|
| AC-S04-01 | Estaciones con bicicletas sobre el promedio | Norte: 2 bicicletas ancladas y 2 anclajes | `image copy 70.png` |
| AC-S04-02 | Vista de disponibilidad | Sur: 1 libre, 100%; Norte: 0 libres, 0% | `image copy 71.png` |
| AC-S04-03 | Procedimiento de anclajes libres | Encontró `Anclaje Sur 01` sin bicicleta | `image copy 72.png` |
| AC-S04-04 | Índice y plan `EXPLAIN` | Índice creado y considerado por MySQL | `image copy 73.png` |

### Estado

Completé las cuatro actividades durante la clase, registré los resultados
reales, coloqué las evidencias y dejé documentadas las decisiones tomadas.
