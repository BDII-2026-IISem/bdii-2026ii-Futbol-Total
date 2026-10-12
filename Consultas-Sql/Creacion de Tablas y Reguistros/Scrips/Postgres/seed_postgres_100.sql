-- PostgreSQL: 100 registros por tabla con IDs explicitos y secuencias sincronizadas al final.
-- Ejecutar una sola vez en Pedalibre-Terminal-Dbeaver, con las 21 tablas vacias.
BEGIN;

DO $check_empty$
DECLARE
    rows_present BIGINT;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM roles) +
        (SELECT COUNT(*) FROM users) +
        (SELECT COUNT(*) FROM clients) +
        (SELECT COUNT(*) FROM stations) +
        (SELECT COUNT(*) FROM station_locations) +
        (SELECT COUNT(*) FROM station_schedules) +
        (SELECT COUNT(*) FROM docking_points) +
        (SELECT COUNT(*) FROM bicycles) +
        (SELECT COUNT(*) FROM bicycle_dockings) +
        (SELECT COUNT(*) FROM rates) +
        (SELECT COUNT(*) FROM reservations) +
        (SELECT COUNT(*) FROM rentals) +
        (SELECT COUNT(*) FROM rental_events) +
        (SELECT COUNT(*) FROM penalties) +
        (SELECT COUNT(*) FROM maintenance) +
        (SELECT COUNT(*) FROM payments) +
        (SELECT COUNT(*) FROM incidents) +
        (SELECT COUNT(*) FROM notifications) +
        (SELECT COUNT(*) FROM bicycle_history) +
        (SELECT COUNT(*) FROM reviews) +
        (SELECT COUNT(*) FROM invoices)
    INTO rows_present;

    IF rows_present > 0 THEN
        RAISE EXCEPTION 'Seed detenido: vacia las 21 tablas con clear_postgres_data.sql antes de cargar.';
    END IF;
END
$check_empty$;


DO $seed$
DECLARE
    n INTEGER;
    first_name TEXT;
    last_name TEXT;
    email TEXT;
    phone TEXT;
    city TEXT;
    latitude NUMERIC(10,7);
    longitude NUMERIC(10,7);
    amount NUMERIC(10,2);
BEGIN
    FOR n IN 1..100 LOOP
        first_name := CASE MOD(n - 1, 10)
            WHEN 0 THEN 'Valentina' WHEN 1 THEN 'Santiago'
            WHEN 2 THEN 'Isabella' WHEN 3 THEN 'Mateo'
            WHEN 4 THEN 'Camila' WHEN 5 THEN 'Sebastian'
            WHEN 6 THEN 'Mariana' WHEN 7 THEN 'Nicolas'
            WHEN 8 THEN 'Luciana' ELSE 'Samuel' END;
        last_name := CASE FLOOR((n - 1)::NUMERIC / 10)::INTEGER
            WHEN 0 THEN 'Gomez' WHEN 1 THEN 'Rodriguez'
            WHEN 2 THEN 'Martinez' WHEN 3 THEN 'Lopez'
            WHEN 4 THEN 'Hernandez' WHEN 5 THEN 'Garcia'
            WHEN 6 THEN 'Perez' WHEN 7 THEN 'Sanchez'
            WHEN 8 THEN 'Ramirez' ELSE 'Torres' END;
        email := LOWER(first_name || '.' || last_name || '@example.com');
        phone := '+57 3' || LPAD((10000000 + n)::TEXT, 9, '0');
        city := CASE MOD(n - 1, 5)
            WHEN 0 THEN 'Bogota' WHEN 1 THEN 'Medellin'
            WHEN 2 THEN 'Cali' WHEN 3 THEN 'Barranquilla'
            ELSE 'Cartagena' END;
        latitude := CASE MOD(n - 1, 5)
            WHEN 0 THEN 4.7110 WHEN 1 THEN 6.2442 WHEN 2 THEN 3.4516
            WHEN 3 THEN 10.9639 ELSE 10.3910 END + MOD(n * 17, 100) / 100000.0;
        longitude := CASE MOD(n - 1, 5)
            WHEN 0 THEN -74.0721 WHEN 1 THEN -75.5812 WHEN 2 THEN -76.5320
            WHEN 3 THEN -74.7964 ELSE -75.4794 END - MOD(n * 13, 100) / 100000.0;
        amount := 800 + MOD(n * 413, 15500);

        INSERT INTO roles(role_id, name, description)
        VALUES (n, (CASE MOD(n - 1, 5) WHEN 0 THEN 'cliente' WHEN 1 THEN 'operador'
            WHEN 2 THEN 'mantenimiento' WHEN 3 THEN 'supervisor' ELSE 'soporte' END)
            || '_' || LPAD(n::TEXT, 3, '0'), 'Rol de prueba para ' || city);
        INSERT INTO users(user_id, role_id, username, password_hash, email, is_active)
        VALUES (n, n, LOWER(first_name || '.' || last_name),
            ENCODE(SHA256(CONVERT_TO('pedalibre-seed-only|' || n::TEXT, 'UTF8')), 'hex'),
            email, MOD(n, 10) <> 0);
        INSERT INTO clients(client_id, user_id, first_name, last_name, document_number, phone)
        VALUES (n, n, first_name, last_name, 'CC' || LPAD((10000000 + n * 37)::TEXT, 10, '0'), phone);
        INSERT INTO stations(station_id, name, address, capacity, status)
        VALUES (n, 'Estacion ' || city || ' ' ||
            CASE MOD(n - 1, 4) WHEN 0 THEN 'Centro' WHEN 1 THEN 'Norte'
                WHEN 2 THEN 'Parque' ELSE 'Universidad' END,
            'Calle ' || (10 + MOD(n * 7, 80)) || ' # ' ||
                (12 + MOD(n * 11, 70)) || '-' || (5 + MOD(n * 13, 40)) || ', ' || city,
            12 + MOD(n * 7, 49),
            CASE MOD(n, 12) WHEN 0 THEN 'maintenance' WHEN 1 THEN 'limited' ELSE 'active' END);
        INSERT INTO station_locations(station_location_id, station_id, latitude, longitude)
        VALUES (n, n, latitude, longitude);
        INSERT INTO station_schedules(schedule_id, station_id, day_of_week, opening_time, closing_time, is_closed)
        VALUES (n, n, MOD(n - 1, 7) + 1, TIME '06:00', TIME '22:00', MOD(n, 9) = 0);
        INSERT INTO docking_points(docking_point_id, station_id, code, status)
        VALUES (n, n, 'B' || LPAD(MOD(n * 7, 999)::TEXT, 3, '0'),
            CASE MOD(n, 8) WHEN 0 THEN 'occupied' WHEN 1 THEN 'maintenance' ELSE 'available' END);
        INSERT INTO bicycles(bicycle_id, serial_number, bicycle_type, status)
        VALUES (n, 'PB-' || UPPER(LEFT(city, 3)) || '-' || LPAD((7000 + n * 19)::TEXT, 5, '0'),
            CASE MOD(n, 4) WHEN 0 THEN 'electric' WHEN 1 THEN 'urban'
                WHEN 2 THEN 'mountain' ELSE 'standard' END,
            CASE MOD(n, 10) WHEN 0 THEN 'maintenance' WHEN 1 THEN 'reserved'
                ELSE 'available' END);
        INSERT INTO bicycle_dockings(bicycle_docking_id, bicycle_id, docking_point_id, docked_at, undocked_at)
        VALUES (n, n, n, CURRENT_TIMESTAMP - MOD(n * 3, 72) * INTERVAL '1 hour',
            CASE WHEN MOD(n, 3) = 0
                THEN CURRENT_TIMESTAMP - MOD(n * 3, 72) * INTERVAL '1 hour' + INTERVAL '25 minutes'
                ELSE NULL END);
        INSERT INTO rates(rate_id, name, price, billing_unit, is_active)
        VALUES (n, (CASE MOD(n - 1, 4) WHEN 0 THEN 'Plan urbano' WHEN 1 THEN 'Pase diario'
            WHEN 2 THEN 'Plan estudiante' ELSE 'Tarifa electrica' END) || ' ' || LPAD(n::TEXT, 3, '0'),
            800 + MOD(n * 275, 9200),
            CASE MOD(n, 3) WHEN 0 THEN 'hour' WHEN 1 THEN 'minute' ELSE 'day' END,
            MOD(n, 11) <> 0);
        INSERT INTO reservations(reservation_id, client_id, bicycle_id, station_id, reserved_at, expires_at, status)
        VALUES (n, n, n, n, CURRENT_TIMESTAMP - MOD(n, 30) * INTERVAL '1 day',
            CURRENT_TIMESTAMP + (2 + MOD(n, 6)) * INTERVAL '1 hour',
            CASE MOD(n, 5) WHEN 0 THEN 'completed' WHEN 1 THEN 'cancelled' ELSE 'confirmed' END);
        INSERT INTO rentals(rental_id, client_id, bicycle_id, rate_id, start_station_id, end_station_id,
            started_at, ended_at, status, total_amount)
        VALUES (n, n, n, n, n,
            CASE WHEN n = 1 THEN 1 ELSE 1 + MOD(n * 7919, n - 1) END,
            CURRENT_TIMESTAMP - (3 + MOD(n, 40)) * INTERVAL '1 hour',
            CURRENT_TIMESTAMP - (2 + MOD(n, 40)) * INTERVAL '1 hour',
            CASE MOD(n, 6) WHEN 0 THEN 'active' WHEN 1 THEN 'cancelled' ELSE 'completed' END,
            amount);
        INSERT INTO rental_events(rental_event_id, rental_id, event_type, description, event_at)
        VALUES (n, n, CASE MOD(n, 4) WHEN 0 THEN 'bike_unlocked' WHEN 1 THEN 'ride_started'
            WHEN 2 THEN 'bike_returned' ELSE 'payment_confirmed' END,
            'Actualizacion del alquiler de ' || first_name || ' en ' || city,
            CURRENT_TIMESTAMP - MOD(n * 17, 300) * INTERVAL '1 minute');
        INSERT INTO penalties(penalty_id, rental_id, reason, amount, status)
        VALUES (n, n, CASE MOD(n, 4) WHEN 0 THEN 'Devolucion fuera de la zona permitida'
            WHEN 1 THEN 'Retraso en la devolucion' WHEN 2 THEN 'Dano menor reportado'
            ELSE 'Cargo de limpieza' END,
            1500 + MOD(n * 325, 8000),
            CASE MOD(n, 3) WHEN 0 THEN 'paid' WHEN 1 THEN 'waived' ELSE 'pending' END);
        INSERT INTO maintenance(maintenance_id, bicycle_id, maintenance_type, description, scheduled_at,
            completed_at, cost, status)
        VALUES (n, n, CASE MOD(n, 4) WHEN 0 THEN 'brake_service' WHEN 1 THEN 'tire_replacement'
            WHEN 2 THEN 'battery_check' ELSE 'safety_inspection' END,
            'Revision preventiva en ' || city, CURRENT_TIMESTAMP - MOD(n, 45) * INTERVAL '1 day',
            CASE WHEN MOD(n, 3) = 0 THEN CURRENT_TIMESTAMP ELSE NULL END,
            12000 + MOD(n * 137, 88000),
            CASE WHEN MOD(n, 3) = 0 THEN 'completed' ELSE 'pending' END);
        INSERT INTO payments(payment_id, rental_id, amount, payment_method, status, transaction_reference, paid_at)
        VALUES (n, n, amount, CASE MOD(n, 4) WHEN 0 THEN 'credit_card' WHEN 1 THEN 'debit_card'
            WHEN 2 THEN 'pse' ELSE 'digital_wallet' END,
            CASE MOD(n, 7) WHEN 0 THEN 'pending' WHEN 1 THEN 'refunded' ELSE 'paid' END,
            'PAY-' || UPPER(LEFT(city, 3)) || '-' || LPAD((4000 + n * 23)::TEXT, 6, '0'),
            CASE WHEN MOD(n, 7) = 0 THEN NULL ELSE CURRENT_TIMESTAMP END);
        INSERT INTO incidents(incident_id, bicycle_id, client_id, rental_id, description, severity, status)
        VALUES (n, n, n, n, CASE MOD(n, 4)
            WHEN 0 THEN 'La bicicleta requiere revision en ' || city
            WHEN 1 THEN 'Reporte de freno durante el recorrido de ' || first_name
            WHEN 2 THEN 'Estacion con anclaje fuera de servicio en ' || city
            ELSE 'Solicitud de asistencia del cliente ' || first_name END,
            CASE MOD(n, 3) WHEN 0 THEN 'low' WHEN 1 THEN 'medium' ELSE 'high' END,
            CASE MOD(n, 4) WHEN 0 THEN 'open' WHEN 1 THEN 'investigating'
                WHEN 2 THEN 'resolved' ELSE 'closed' END);
        INSERT INTO notifications(notification_id, user_id, title, message, is_read)
        VALUES (n, n, CASE MOD(n, 4) WHEN 0 THEN 'Alquiler confirmado'
            WHEN 1 THEN 'Recordatorio de devolucion' WHEN 2 THEN 'Pago recibido'
            ELSE 'Novedades de tu estacion' END,
            'Hola ' || first_name || ', consulta la actualizacion de tu servicio en ' || city || '.',
            MOD(n, 3) = 0);
        INSERT INTO bicycle_history(bicycle_history_id, bicycle_id, event_type, description)
        VALUES (n, n, CASE MOD(n, 4) WHEN 0 THEN 'registered' WHEN 1 THEN 'maintenance'
            WHEN 2 THEN 'docked' ELSE 'status_changed' END,
            'Registro de bicicleta en ' || city || '; revision ' || (1 + MOD(n * 3, 12)));
        INSERT INTO reviews(review_id, client_id, rental_id, rating, comment_text)
        VALUES (n, n, n, 1 + MOD(n * 7, 5),
            CASE MOD(n, 5) WHEN 0 THEN 'Buen servicio en ' || city || ', bicicleta en buen estado.'
                WHEN 1 THEN 'Proceso sencillo y rapido.'
                WHEN 2 THEN 'La estacion estaba limpia y bien ubicada.'
                WHEN 3 THEN 'La bicicleta funciono correctamente durante el recorrido.'
                ELSE 'Buena experiencia; volveria a utilizar el servicio.' END);
        INSERT INTO invoices(invoice_id, payment_id, invoice_number, subtotal, tax, total)
        VALUES (n, n, 'FAC-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
            LPAD((8500 + n * 17)::TEXT, 6, '0'),
            amount, ROUND(amount * 0.19, 2), ROUND(amount * 1.19, 2));
    END LOOP;
END
$seed$;

SELECT setval(pg_get_serial_sequence('roles', 'role_id'), 100, true);
SELECT setval(pg_get_serial_sequence('users', 'user_id'), 100, true);
SELECT setval(pg_get_serial_sequence('clients', 'client_id'), 100, true);
SELECT setval(pg_get_serial_sequence('stations', 'station_id'), 100, true);
SELECT setval(pg_get_serial_sequence('station_locations', 'station_location_id'), 100, true);
SELECT setval(pg_get_serial_sequence('station_schedules', 'schedule_id'), 100, true);
SELECT setval(pg_get_serial_sequence('docking_points', 'docking_point_id'), 100, true);
SELECT setval(pg_get_serial_sequence('bicycles', 'bicycle_id'), 100, true);
SELECT setval(pg_get_serial_sequence('bicycle_dockings', 'bicycle_docking_id'), 100, true);
SELECT setval(pg_get_serial_sequence('rates', 'rate_id'), 100, true);
SELECT setval(pg_get_serial_sequence('reservations', 'reservation_id'), 100, true);
SELECT setval(pg_get_serial_sequence('rentals', 'rental_id'), 100, true);
SELECT setval(pg_get_serial_sequence('rental_events', 'rental_event_id'), 100, true);
SELECT setval(pg_get_serial_sequence('penalties', 'penalty_id'), 100, true);
SELECT setval(pg_get_serial_sequence('maintenance', 'maintenance_id'), 100, true);
SELECT setval(pg_get_serial_sequence('payments', 'payment_id'), 100, true);
SELECT setval(pg_get_serial_sequence('incidents', 'incident_id'), 100, true);
SELECT setval(pg_get_serial_sequence('notifications', 'notification_id'), 100, true);
SELECT setval(pg_get_serial_sequence('bicycle_history', 'bicycle_history_id'), 100, true);
SELECT setval(pg_get_serial_sequence('reviews', 'review_id'), 100, true);
SELECT setval(pg_get_serial_sequence('invoices', 'invoice_id'), 100, true);
COMMIT;

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
