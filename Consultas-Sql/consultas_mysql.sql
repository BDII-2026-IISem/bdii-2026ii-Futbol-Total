-- PedalLibre - consultas de lectura para MySQL 8.
-- En DBeaver, conecta a Pedalibre-Terminal-Dbeaver.
-- Ejecuta y captura una sentencia a la vez (Ctrl+Enter).
-- No ejecutes la guia de creacion ni la semilla desde este archivo.

-- 0. Confirmar que el editor esta conectado a la base esperada.
-- Si base_actual no es Pedalibre-Terminal-Dbeaver, cambia la conexion en DBeaver
-- antes de seguir. Este archivo no cambia de base de datos.
SELECT DATABASE() AS base_actual;

-- 1. Comprobar que las tablas PedalLibre existen en la base seleccionada.
SHOW TABLES;

-- 2. Confirmar el conteo de filas cargadas por tabla.
-- La guia de insercion espera 100 filas por cada una de las 21 tablas.
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

-- 3. Bicicletas disponibles (primeros 10 resultados).
SELECT bicycle_id, serial_number, bicycle_type, status
FROM bicycles
WHERE status = 'available'
ORDER BY bicycle_id
LIMIT 10;

-- 4. Alquileres completados mas recientes.
SELECT rental_id, client_id, bicycle_id, started_at, ended_at, total_amount, status
FROM rentals
WHERE status = 'completed'
ORDER BY started_at DESC, rental_id DESC
LIMIT 10;

-- 5. Detalle de alquiler con cliente, bicicleta, tarifa y estaciones.
SELECT
    r.rental_id,
    c.first_name,
    c.last_name,
    b.serial_number,
    rt.name AS tarifa,
    si.name AS estacion_inicio,
    sf.name AS estacion_fin,
    r.started_at,
    r.ended_at,
    r.status,
    r.total_amount
FROM rentals r
JOIN clients c ON c.client_id = r.client_id
JOIN bicycles b ON b.bicycle_id = r.bicycle_id
JOIN rates rt ON rt.rate_id = r.rate_id
LEFT JOIN stations si ON si.station_id = r.start_station_id
LEFT JOIN stations sf ON sf.station_id = r.end_station_id
ORDER BY r.started_at DESC, r.rental_id DESC
LIMIT 10;

-- 6. Cantidad e importe total y promedio de alquileres por estado.
SELECT
    status,
    COUNT(*) AS cantidad_alquileres,
    SUM(total_amount) AS importe_total,
    AVG(total_amount) AS importe_promedio
FROM rentals
GROUP BY status
ORDER BY status;

-- 7. Resumen de pagos por metodo y estado.
SELECT
    payment_method,
    status,
    COUNT(*) AS cantidad_pagos,
    SUM(amount) AS importe_total
FROM payments
GROUP BY payment_method, status
ORDER BY payment_method, status;

-- 8. Cinco clientes con mayor cantidad de alquileres.
SELECT
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS cantidad_alquileres
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.client_id
GROUP BY c.client_id, c.first_name, c.last_name
ORDER BY cantidad_alquileres DESC, c.client_id
LIMIT 5;

-- 9. Disponibilidad de anclajes agrupada por estacion.
SELECT
    s.station_id,
    s.name AS estacion,
    COUNT(dp.docking_point_id) AS cantidad_anclajes,
    SUM(CASE WHEN dp.status = 'available' THEN 1 ELSE 0 END) AS anclajes_disponibles
FROM stations s
LEFT JOIN docking_points dp ON dp.station_id = s.station_id
GROUP BY s.station_id, s.name
ORDER BY s.station_id;

-- 10. Incidentes abiertos con datos opcionales de bicicleta y cliente.
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
ORDER BY i.reported_at DESC, i.incident_id DESC;

-- 11. Total de pagos pagados agrupados por mes.
SELECT
    DATE_FORMAT(paid_at, '%Y-%m') AS mes_pago,
    COUNT(*) AS cantidad_pagos,
    SUM(amount) AS importe_mensual
FROM payments
WHERE status = 'paid'
  AND paid_at IS NOT NULL
GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
ORDER BY mes_pago;
