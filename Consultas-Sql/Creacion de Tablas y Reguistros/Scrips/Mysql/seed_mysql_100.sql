-- MySQL 8: datos de prueba para Pedalibre-Terminal-Dbeaver.
-- Ejecutar una sola vez sobre las 21 tablas vacias.
USE `Pedalibre-Terminal-Dbeaver`;

DROP TEMPORARY TABLE IF EXISTS seed_numbers;
CREATE TEMPORARY TABLE seed_numbers (
    n INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    city VARCHAR(50) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL
);

INSERT INTO seed_numbers (n, first_name, last_name, email, phone, city, latitude, longitude)
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 100
), personas AS (
    SELECT n,
        CASE MOD(n - 1, 10)
            WHEN 0 THEN 'Valentina' WHEN 1 THEN 'Santiago'
            WHEN 2 THEN 'Isabella' WHEN 3 THEN 'Mateo'
            WHEN 4 THEN 'Camila' WHEN 5 THEN 'Sebastian'
            WHEN 6 THEN 'Mariana' WHEN 7 THEN 'Nicolas'
            WHEN 8 THEN 'Luciana' ELSE 'Samuel'
        END AS first_name,
        CASE FLOOR((n - 1) / 10)
            WHEN 0 THEN 'Gomez' WHEN 1 THEN 'Rodriguez'
            WHEN 2 THEN 'Martinez' WHEN 3 THEN 'Lopez'
            WHEN 4 THEN 'Hernandez' WHEN 5 THEN 'Garcia'
            WHEN 6 THEN 'Perez' WHEN 7 THEN 'Sanchez'
            WHEN 8 THEN 'Ramirez' ELSE 'Torres'
        END AS last_name
    FROM nums
)
SELECT
    n,
    first_name,
    last_name,
    CONCAT(LOWER(first_name), '.', LOWER(last_name), '@example.com'),
    CONCAT('+57 3', LPAD(10000000 + n, 9, '0')),
    CASE MOD(n - 1, 5)
        WHEN 0 THEN 'Bogota'
        WHEN 1 THEN 'Medellin'
        WHEN 2 THEN 'Cali'
        WHEN 3 THEN 'Barranquilla'
        ELSE 'Cartagena'
    END,
    CASE MOD(n - 1, 5)
        WHEN 0 THEN 4.7110
        WHEN 1 THEN 6.2442
        WHEN 2 THEN 3.4516
        WHEN 3 THEN 10.9639
        ELSE 10.3910
    END + MOD(n * 17, 100) / 100000.0,
    CASE MOD(n - 1, 5)
        WHEN 0 THEN -74.0721
        WHEN 1 THEN -75.5812
        WHEN 2 THEN -76.5320
        WHEN 3 THEN -74.7964
        ELSE -75.4794
    END - MOD(n * 13, 100) / 100000.0
FROM personas;

START TRANSACTION;

INSERT INTO roles (role_id, name, description)
SELECT n, CONCAT(
    CASE MOD(n - 1, 5)
        WHEN 0 THEN 'cliente'
        WHEN 1 THEN 'operador'
        WHEN 2 THEN 'mantenimiento'
        WHEN 3 THEN 'supervisor'
        ELSE 'soporte'
    END,
    '_',
    LPAD(n, 3, '0')
), CONCAT('Rol de prueba para ', city)
FROM seed_numbers;

INSERT INTO users (user_id, role_id, username, password_hash, email, is_active)
SELECT n, n,
    CONCAT(LOWER(first_name), '.', LOWER(last_name)),
    SHA2(CONCAT('pedalibre-seed-only|', n), 256),
    email,
    MOD(n, 10) <> 0
FROM seed_numbers;

INSERT INTO clients (client_id, user_id, first_name, last_name, document_number, phone)
SELECT n, n, first_name, last_name,
    CONCAT('CC', LPAD(10000000 + n * 37, 10, '0')),
    phone
FROM seed_numbers;

INSERT INTO stations (station_id, name, address, capacity, status)
SELECT n,
    CONCAT('Estacion ', city, ' ', CASE MOD(n - 1, 4)
        WHEN 0 THEN 'Centro'
        WHEN 1 THEN 'Norte'
        WHEN 2 THEN 'Parque'
        ELSE 'Universidad'
    END),
    CONCAT('Calle ', 10 + MOD(n * 7, 80), ' # ',
        12 + MOD(n * 11, 70), '-', 5 + MOD(n * 13, 40), ', ', city),
    12 + MOD(n * 7, 49),
    CASE MOD(n, 12)
        WHEN 0 THEN 'maintenance'
        WHEN 1 THEN 'limited'
        ELSE 'active'
    END
FROM seed_numbers;

INSERT INTO station_locations (station_location_id, station_id, latitude, longitude)
SELECT n, n, latitude, longitude
FROM seed_numbers;

INSERT INTO station_schedules (schedule_id, station_id, day_of_week, opening_time, closing_time, is_closed)
SELECT n, n, MOD(n - 1, 7) + 1,
    MAKETIME(6 + MOD(n, 3), 0, 0),
    MAKETIME(19 + MOD(n, 4), 0, 0),
    MOD(n, 9) = 0
FROM seed_numbers;

INSERT INTO docking_points (docking_point_id, station_id, code, status)
SELECT n, n, CONCAT('B', LPAD(MOD(n * 7, 999), 3, '0')),
    CASE MOD(n, 8)
        WHEN 0 THEN 'occupied'
        WHEN 1 THEN 'maintenance'
        ELSE 'available'
    END
FROM seed_numbers;

INSERT INTO bicycles (bicycle_id, serial_number, bicycle_type, status)
SELECT n, CONCAT('PB-', UPPER(LEFT(city, 3)), '-', LPAD(7000 + n * 19, 5, '0')),
    CASE MOD(n, 4)
        WHEN 0 THEN 'electric'
        WHEN 1 THEN 'urban'
        WHEN 2 THEN 'mountain'
        ELSE 'standard'
    END,
    CASE MOD(n, 10)
        WHEN 0 THEN 'maintenance'
        WHEN 1 THEN 'reserved'
        ELSE 'available'
    END
FROM seed_numbers;

INSERT INTO bicycle_dockings (bicycle_docking_id, bicycle_id, docking_point_id, docked_at, undocked_at)
SELECT n, n, n,
    TIMESTAMPADD(HOUR, -MOD(n * 3, 72), CURRENT_TIMESTAMP),
    CASE WHEN MOD(n, 3) = 0
        THEN TIMESTAMPADD(MINUTE, 25,
            TIMESTAMPADD(HOUR, -MOD(n * 3, 72), CURRENT_TIMESTAMP))
        ELSE NULL
    END
FROM seed_numbers;

INSERT INTO rates (rate_id, name, price, billing_unit, is_active)
SELECT n,
    CONCAT(CASE MOD(n - 1, 4)
        WHEN 0 THEN 'Plan urbano'
        WHEN 1 THEN 'Pase diario'
        WHEN 2 THEN 'Plan estudiante'
        ELSE 'Tarifa electrica'
    END, ' ', LPAD(n, 3, '0')),
    800 + MOD(n * 275, 9200),
    CASE MOD(n, 3)
        WHEN 0 THEN 'hour'
        WHEN 1 THEN 'minute'
        ELSE 'day'
    END,
    MOD(n, 11) <> 0
FROM seed_numbers;

INSERT INTO reservations (reservation_id, client_id, bicycle_id, station_id, reserved_at, expires_at, status)
SELECT n, n, n, n,
    TIMESTAMPADD(DAY, -MOD(n, 30), CURRENT_TIMESTAMP),
    TIMESTAMPADD(HOUR, 2 + MOD(n, 6), CURRENT_TIMESTAMP),
    CASE MOD(n, 5)
        WHEN 0 THEN 'completed'
        WHEN 1 THEN 'cancelled'
        ELSE 'confirmed'
    END
FROM seed_numbers;

INSERT INTO rentals (rental_id, client_id, bicycle_id, rate_id, start_station_id, end_station_id, started_at, ended_at, status, total_amount)
SELECT n, n, n, n, n, 1 + MOD(n * 7, 100),
    TIMESTAMPADD(HOUR, -3 - MOD(n, 40), CURRENT_TIMESTAMP),
    TIMESTAMPADD(HOUR, -2 - MOD(n, 40), CURRENT_TIMESTAMP),
    CASE MOD(n, 6)
        WHEN 0 THEN 'active'
        WHEN 1 THEN 'cancelled'
        ELSE 'completed'
    END,
    800 + MOD(n * 413, 15500)
FROM seed_numbers;

INSERT INTO rental_events (rental_event_id, rental_id, event_type, description, event_at)
SELECT n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN 'bike_unlocked'
        WHEN 1 THEN 'ride_started'
        WHEN 2 THEN 'bike_returned'
        ELSE 'payment_confirmed'
    END,
    CONCAT('Actualizacion del alquiler de ', first_name, ' en ', city),
    TIMESTAMPADD(MINUTE, -MOD(n * 17, 300), CURRENT_TIMESTAMP)
FROM seed_numbers;

INSERT INTO penalties (penalty_id, rental_id, reason, amount, status)
SELECT n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN 'Devolucion fuera de la zona permitida'
        WHEN 1 THEN 'Retraso en la devolucion'
        WHEN 2 THEN 'Dano menor reportado'
        ELSE 'Cargo de limpieza'
    END,
    1500 + MOD(n * 325, 8000),
    CASE MOD(n, 3)
        WHEN 0 THEN 'paid'
        WHEN 1 THEN 'waived'
        ELSE 'pending'
    END
FROM seed_numbers;

INSERT INTO maintenance (maintenance_id, bicycle_id, maintenance_type, description, scheduled_at, completed_at, cost, status)
SELECT n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN 'brake_service'
        WHEN 1 THEN 'tire_replacement'
        WHEN 2 THEN 'battery_check'
        ELSE 'safety_inspection'
    END,
    CONCAT('Revision preventiva en ', city),
    TIMESTAMPADD(DAY, -MOD(n, 45), CURRENT_TIMESTAMP),
    CASE WHEN MOD(n, 3) = 0 THEN CURRENT_TIMESTAMP ELSE NULL END,
    12000 + MOD(n * 137, 88000),
    CASE WHEN MOD(n, 3) = 0 THEN 'completed' ELSE 'pending' END
FROM seed_numbers;

INSERT INTO payments (payment_id, rental_id, amount, payment_method, status, transaction_reference, paid_at)
SELECT n, n, 800 + MOD(n * 413, 15500),
    CASE MOD(n, 4)
        WHEN 0 THEN 'credit_card'
        WHEN 1 THEN 'debit_card'
        WHEN 2 THEN 'pse'
        ELSE 'digital_wallet'
    END,
    CASE MOD(n, 7)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'refunded'
        ELSE 'paid'
    END,
    CONCAT('PAY-', UPPER(LEFT(city, 3)), '-', LPAD(4000 + n * 23, 6, '0')),
    CASE WHEN MOD(n, 7) = 0 THEN NULL ELSE CURRENT_TIMESTAMP END
FROM seed_numbers;

INSERT INTO incidents (incident_id, bicycle_id, client_id, rental_id, description, severity, status)
SELECT n, n, n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN CONCAT('La bicicleta requiere revision en ', city)
        WHEN 1 THEN CONCAT('Reporte de freno durante el recorrido de ', first_name)
        WHEN 2 THEN CONCAT('Estacion con anclaje fuera de servicio en ', city)
        ELSE CONCAT('Solicitud de asistencia del cliente ', first_name)
    END,
    CASE MOD(n, 3)
        WHEN 0 THEN 'low'
        WHEN 1 THEN 'medium'
        ELSE 'high'
    END,
    CASE MOD(n, 4)
        WHEN 0 THEN 'open'
        WHEN 1 THEN 'investigating'
        WHEN 2 THEN 'resolved'
        ELSE 'closed'
    END
FROM seed_numbers;

INSERT INTO notifications (notification_id, user_id, title, message, is_read)
SELECT n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN 'Alquiler confirmado'
        WHEN 1 THEN 'Recordatorio de devolucion'
        WHEN 2 THEN 'Pago recibido'
        ELSE 'Novedades de tu estacion'
    END,
    CONCAT('Hola ', first_name, ', consulta la actualizacion de tu servicio en ', city, '.'),
    MOD(n, 3) = 0
FROM seed_numbers;

INSERT INTO bicycle_history (bicycle_history_id, bicycle_id, event_type, description)
SELECT n, n,
    CASE MOD(n, 4)
        WHEN 0 THEN 'registered'
        WHEN 1 THEN 'maintenance'
        WHEN 2 THEN 'docked'
        ELSE 'status_changed'
    END,
    CONCAT('Registro de bicicleta en ', city, '; revision ', 1 + MOD(n * 3, 12))
FROM seed_numbers;

INSERT INTO reviews (review_id, client_id, rental_id, rating, comment_text)
SELECT n, n, n, 1 + MOD(n * 7, 5),
    CASE MOD(n, 5)
        WHEN 0 THEN CONCAT('Buen servicio en ', city, ', bicicleta en buen estado.')
        WHEN 1 THEN 'Proceso sencillo y rapido.'
        WHEN 2 THEN 'La estacion estaba limpia y bien ubicada.'
        WHEN 3 THEN 'La bicicleta funciono correctamente durante el recorrido.'
        ELSE 'Buena experiencia; volveria a utilizar el servicio.'
    END
FROM seed_numbers;

INSERT INTO invoices (invoice_id, payment_id, invoice_number, subtotal, tax, total)
SELECT n, n, CONCAT('FAC-', YEAR(CURRENT_DATE), '-', LPAD(8500 + n * 17, 6, '0')),
    800 + MOD(n * 413, 15500),
    ROUND((800 + MOD(n * 413, 15500)) * 0.19, 2),
    ROUND((800 + MOD(n * 413, 15500)) * 1.19, 2)
FROM seed_numbers;

COMMIT;
DROP TEMPORARY TABLE IF EXISTS seed_numbers;

SELECT tabla, registros
FROM (
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
) AS resultados
ORDER BY tabla;
