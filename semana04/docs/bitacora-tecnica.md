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
