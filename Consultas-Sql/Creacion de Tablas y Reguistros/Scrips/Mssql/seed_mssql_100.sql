-- SQL Server seed data: 100 rows per table in Pedalibre-Terminal-Dbeaver.
-- Run once on 21 empty tables. Explicit IDs keep every foreign key aligned.
USE [Pedalibre-Terminal-Dbeaver];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM dbo.roles)
 OR EXISTS (SELECT 1 FROM dbo.users)
 OR EXISTS (SELECT 1 FROM dbo.clients)
 OR EXISTS (SELECT 1 FROM dbo.stations)
 OR EXISTS (SELECT 1 FROM dbo.station_locations)
 OR EXISTS (SELECT 1 FROM dbo.station_schedules)
 OR EXISTS (SELECT 1 FROM dbo.docking_points)
 OR EXISTS (SELECT 1 FROM dbo.bicycles)
 OR EXISTS (SELECT 1 FROM dbo.bicycle_dockings)
 OR EXISTS (SELECT 1 FROM dbo.rates)
 OR EXISTS (SELECT 1 FROM dbo.reservations)
 OR EXISTS (SELECT 1 FROM dbo.rentals)
 OR EXISTS (SELECT 1 FROM dbo.rental_events)
 OR EXISTS (SELECT 1 FROM dbo.penalties)
 OR EXISTS (SELECT 1 FROM dbo.maintenance)
 OR EXISTS (SELECT 1 FROM dbo.payments)
 OR EXISTS (SELECT 1 FROM dbo.incidents)
 OR EXISTS (SELECT 1 FROM dbo.notifications)
 OR EXISTS (SELECT 1 FROM dbo.bicycle_history)
 OR EXISTS (SELECT 1 FROM dbo.reviews)
 OR EXISTS (SELECT 1 FROM dbo.invoices)
BEGIN
    ;THROW 51000, 'Seed detenido: vacia las 21 tablas con clear_mssql_data.sql antes de cargar.', 1;
END;

DBCC CHECKIDENT ('dbo.roles', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.users', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.clients', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.stations', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.station_locations', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.station_schedules', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.docking_points', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.bicycles', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.bicycle_dockings', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.rates', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.reservations', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.rentals', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.rental_events', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.penalties', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.maintenance', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.payments', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.incidents', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.notifications', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.bicycle_history', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.reviews', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.invoices', RESEED, 0) WITH NO_INFOMSGS;

BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @n INT = 1;
    DECLARE @first_name NVARCHAR(50);
    DECLARE @last_name NVARCHAR(50);
    DECLARE @email NVARCHAR(150);
    DECLARE @phone NVARCHAR(30);
    DECLARE @city NVARCHAR(50);
    DECLARE @latitude DECIMAL(10,7);
    DECLARE @longitude DECIMAL(10,7);
    DECLARE @amount DECIMAL(10,2);

    WHILE @n <= 100
    BEGIN
        SET @first_name = CASE (@n - 1) % 10
            WHEN 0 THEN N'Valentina' WHEN 1 THEN N'Santiago'
            WHEN 2 THEN N'Isabella' WHEN 3 THEN N'Mateo'
            WHEN 4 THEN N'Camila' WHEN 5 THEN N'Sebastian'
            WHEN 6 THEN N'Mariana' WHEN 7 THEN N'Nicolas'
            WHEN 8 THEN N'Luciana' ELSE N'Samuel' END;
        SET @last_name = CASE (@n - 1) / 10
            WHEN 0 THEN N'Gomez' WHEN 1 THEN N'Rodriguez'
            WHEN 2 THEN N'Martinez' WHEN 3 THEN N'Lopez'
            WHEN 4 THEN N'Hernandez' WHEN 5 THEN N'Garcia'
            WHEN 6 THEN N'Perez' WHEN 7 THEN N'Sanchez'
            WHEN 8 THEN N'Ramirez' ELSE N'Torres' END;
        SET @email = LOWER(CONCAT(@first_name, N'.', @last_name, N'@example.com'));
        SET @phone = CONCAT(N'+57 3', FORMAT(10000000 + @n, 'D9'));
        SET @city = CASE (@n - 1) % 5
            WHEN 0 THEN N'Bogota' WHEN 1 THEN N'Medellin'
            WHEN 2 THEN N'Cali' WHEN 3 THEN N'Barranquilla'
            ELSE N'Cartagena' END;
        SET @latitude = CASE (@n - 1) % 5
            WHEN 0 THEN 4.7110 WHEN 1 THEN 6.2442 WHEN 2 THEN 3.4516
            WHEN 3 THEN 10.9639 ELSE 10.3910 END + (@n * 17 % 100) / 100000.0;
        SET @longitude = CASE (@n - 1) % 5
            WHEN 0 THEN -74.0721 WHEN 1 THEN -75.5812 WHEN 2 THEN -76.5320
            WHEN 3 THEN -74.7964 ELSE -75.4794 END - (@n * 13 % 100) / 100000.0;
        SET @amount = 800 + (@n * 413 % 15500);

        SET IDENTITY_INSERT dbo.roles ON;
        INSERT INTO dbo.roles(role_id, name, description)
        VALUES (@n, CONCAT(CASE (@n - 1) % 5
            WHEN 0 THEN N'cliente' WHEN 1 THEN N'operador'
            WHEN 2 THEN N'mantenimiento' WHEN 3 THEN N'supervisor'
            ELSE N'soporte' END, N'_', FORMAT(@n, 'D3')),
            CONCAT(N'Rol de prueba para ', @city));
        SET IDENTITY_INSERT dbo.roles OFF;

        SET IDENTITY_INSERT dbo.users ON;
        INSERT INTO dbo.users(user_id, role_id, username, password_hash, email, is_active)
        VALUES (@n, @n, LOWER(CONCAT(@first_name, N'.', @last_name)),
            CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT('pedalibre-seed-only|', @n)), 2),
            @email, CASE WHEN @n % 10 = 0 THEN 0 ELSE 1 END);
        SET IDENTITY_INSERT dbo.users OFF;

        SET IDENTITY_INSERT dbo.clients ON;
        INSERT INTO dbo.clients(client_id, user_id, first_name, last_name, document_number, phone)
        VALUES (@n, @n, @first_name, @last_name,
            CONCAT('CC', FORMAT(10000000 + @n * 37, 'D10')), @phone);
        SET IDENTITY_INSERT dbo.clients OFF;

        SET IDENTITY_INSERT dbo.stations ON;
        INSERT INTO dbo.stations(station_id, name, address, capacity, status)
        VALUES (@n, CONCAT(N'Estacion ', @city, N' ', CASE (@n - 1) % 4
            WHEN 0 THEN N'Centro' WHEN 1 THEN N'Norte'
            WHEN 2 THEN N'Parque' ELSE N'Universidad' END),
            CONCAT(N'Calle ', 10 + @n * 7 % 80, N' # ',
                12 + @n * 11 % 70, N'-', 5 + @n * 13 % 40, N', ', @city),
            12 + @n * 7 % 49,
            CASE WHEN @n % 12 = 0 THEN 'maintenance'
                 WHEN @n % 12 = 1 THEN 'limited' ELSE 'active' END);
        SET IDENTITY_INSERT dbo.stations OFF;

        SET IDENTITY_INSERT dbo.station_locations ON;
        INSERT INTO dbo.station_locations(station_location_id, station_id, latitude, longitude)
        VALUES (@n, @n, @latitude, @longitude);
        SET IDENTITY_INSERT dbo.station_locations OFF;
        SET IDENTITY_INSERT dbo.station_schedules ON;
        INSERT INTO dbo.station_schedules(schedule_id, station_id, day_of_week, opening_time, closing_time, is_closed)
        VALUES (@n, @n, (@n - 1) % 7 + 1, '06:00', '22:00', CASE WHEN @n % 9 = 0 THEN 1 ELSE 0 END);
        SET IDENTITY_INSERT dbo.station_schedules OFF;
        SET IDENTITY_INSERT dbo.docking_points ON;
        INSERT INTO dbo.docking_points(docking_point_id, station_id, code, status)
        VALUES (@n, @n, CONCAT('B', FORMAT(@n * 7 % 999, 'D3')),
            CASE @n % 8 WHEN 0 THEN 'occupied' WHEN 1 THEN 'maintenance' ELSE 'available' END);
        SET IDENTITY_INSERT dbo.docking_points OFF;
        SET IDENTITY_INSERT dbo.bicycles ON;
        INSERT INTO dbo.bicycles(bicycle_id, serial_number, bicycle_type, status)
        VALUES (@n, CONCAT('PB-', UPPER(LEFT(@city, 3)), '-', FORMAT(7000 + @n * 19, 'D5')),
            CASE @n % 4 WHEN 0 THEN 'electric' WHEN 1 THEN 'urban'
                WHEN 2 THEN 'mountain' ELSE 'standard' END,
            CASE @n % 10 WHEN 0 THEN 'maintenance' WHEN 1 THEN 'reserved'
                ELSE 'available' END);
        SET IDENTITY_INSERT dbo.bicycles OFF;
        SET IDENTITY_INSERT dbo.bicycle_dockings ON;
        INSERT INTO dbo.bicycle_dockings(bicycle_docking_id, bicycle_id, docking_point_id, docked_at, undocked_at)
        VALUES (@n, @n, @n, DATEADD(HOUR, -(@n * 3 % 72), SYSDATETIME()),
            CASE WHEN @n % 3 = 0
                THEN DATEADD(MINUTE, 25, DATEADD(HOUR, -(@n * 3 % 72), SYSDATETIME()))
                ELSE NULL END);
        SET IDENTITY_INSERT dbo.bicycle_dockings OFF;
        SET IDENTITY_INSERT dbo.rates ON;
        INSERT INTO dbo.rates(rate_id, name, price, billing_unit, is_active)
        VALUES (@n, CONCAT(CASE (@n - 1) % 4 WHEN 0 THEN N'Plan urbano'
            WHEN 1 THEN N'Pase diario' WHEN 2 THEN N'Plan estudiante'
            ELSE N'Tarifa electrica' END, N' ', FORMAT(@n, 'D3')),
            800 + @n * 275 % 9200,
            CASE @n % 3 WHEN 0 THEN 'hour' WHEN 1 THEN 'minute' ELSE 'day' END,
            CASE WHEN @n % 11 = 0 THEN 0 ELSE 1 END);
        SET IDENTITY_INSERT dbo.rates OFF;
        SET IDENTITY_INSERT dbo.reservations ON;
        INSERT INTO dbo.reservations(reservation_id, client_id, bicycle_id, station_id, reserved_at, expires_at, status)
        VALUES (@n, @n, @n, @n, DATEADD(DAY, -(@n % 30), SYSDATETIME()),
            DATEADD(HOUR, 2 + @n % 6, SYSDATETIME()),
            CASE @n % 5 WHEN 0 THEN 'completed' WHEN 1 THEN 'cancelled' ELSE 'confirmed' END);
        SET IDENTITY_INSERT dbo.reservations OFF;
        SET IDENTITY_INSERT dbo.rentals ON;
        INSERT INTO dbo.rentals(rental_id, client_id, bicycle_id, rate_id, start_station_id, end_station_id,
            started_at, ended_at, status, total_amount)
        VALUES (@n, @n, @n, @n, @n,
            CASE WHEN @n = 1 THEN 1 ELSE 1 + @n * 7919 % (@n - 1) END,
            DATEADD(HOUR, -3 - @n % 40, SYSDATETIME()),
            DATEADD(HOUR, -2 - @n % 40, SYSDATETIME()),
            CASE @n % 6 WHEN 0 THEN 'active' WHEN 1 THEN 'cancelled' ELSE 'completed' END,
            @amount);
        SET IDENTITY_INSERT dbo.rentals OFF;
        SET IDENTITY_INSERT dbo.rental_events ON;
        INSERT INTO dbo.rental_events(rental_event_id, rental_id, event_type, description, event_at)
        VALUES (@n, @n, CASE @n % 4 WHEN 0 THEN 'bike_unlocked' WHEN 1 THEN 'ride_started'
            WHEN 2 THEN 'bike_returned' ELSE 'payment_confirmed' END,
            CONCAT(N'Actualizacion del alquiler de ', @first_name, N' en ', @city),
            DATEADD(MINUTE, -(@n * 17 % 300), SYSDATETIME()));
        SET IDENTITY_INSERT dbo.rental_events OFF;
        SET IDENTITY_INSERT dbo.penalties ON;
        INSERT INTO dbo.penalties(penalty_id, rental_id, reason, amount, status)
        VALUES (@n, @n, CASE @n % 4 WHEN 0 THEN N'Devolucion fuera de la zona permitida'
            WHEN 1 THEN N'Retraso en la devolucion' WHEN 2 THEN N'Dano menor reportado'
            ELSE N'Cargo de limpieza' END, 1500 + @n * 325 % 8000,
            CASE @n % 3 WHEN 0 THEN 'paid' WHEN 1 THEN 'waived' ELSE 'pending' END);
        SET IDENTITY_INSERT dbo.penalties OFF;
        SET IDENTITY_INSERT dbo.maintenance ON;
        INSERT INTO dbo.maintenance(maintenance_id, bicycle_id, maintenance_type, description, scheduled_at,
            completed_at, cost, status)
        VALUES (@n, @n, CASE @n % 4 WHEN 0 THEN 'brake_service' WHEN 1 THEN 'tire_replacement'
            WHEN 2 THEN 'battery_check' ELSE 'safety_inspection' END,
            CONCAT(N'Revision preventiva en ', @city), DATEADD(DAY, -(@n % 45), SYSDATETIME()),
            CASE WHEN @n % 3 = 0 THEN SYSDATETIME() ELSE NULL END,
            12000 + @n * 137 % 88000,
            CASE WHEN @n % 3 = 0 THEN 'completed' ELSE 'pending' END);
        SET IDENTITY_INSERT dbo.maintenance OFF;
        SET IDENTITY_INSERT dbo.payments ON;
        INSERT INTO dbo.payments(payment_id, rental_id, amount, payment_method, status, transaction_reference, paid_at)
        VALUES (@n, @n, @amount, CASE @n % 4 WHEN 0 THEN 'credit_card' WHEN 1 THEN 'debit_card'
            WHEN 2 THEN 'pse' ELSE 'digital_wallet' END,
            CASE @n % 7 WHEN 0 THEN 'pending' WHEN 1 THEN 'refunded' ELSE 'paid' END,
            CONCAT('PAY-', UPPER(LEFT(@city, 3)), '-', FORMAT(4000 + @n * 23, 'D6')),
            CASE WHEN @n % 7 = 0 THEN NULL ELSE SYSDATETIME() END);
        SET IDENTITY_INSERT dbo.payments OFF;
        SET IDENTITY_INSERT dbo.incidents ON;
        INSERT INTO dbo.incidents(incident_id, bicycle_id, client_id, rental_id, description, severity, status)
        VALUES (@n, @n, @n, @n, CASE @n % 4 WHEN 0 THEN CONCAT(N'La bicicleta requiere revision en ', @city)
            WHEN 1 THEN CONCAT(N'Reporte de freno durante el recorrido de ', @first_name)
            WHEN 2 THEN CONCAT(N'Estacion con anclaje fuera de servicio en ', @city)
            ELSE CONCAT(N'Solicitud de asistencia del cliente ', @first_name) END,
            CASE @n % 3 WHEN 0 THEN 'low' WHEN 1 THEN 'medium' ELSE 'high' END,
            CASE @n % 4 WHEN 0 THEN 'open' WHEN 1 THEN 'investigating'
                WHEN 2 THEN 'resolved' ELSE 'closed' END);
        SET IDENTITY_INSERT dbo.incidents OFF;
        SET IDENTITY_INSERT dbo.notifications ON;
        INSERT INTO dbo.notifications(notification_id, user_id, title, message, is_read)
        VALUES (@n, @n, CASE @n % 4 WHEN 0 THEN N'Alquiler confirmado'
            WHEN 1 THEN N'Recordatorio de devolucion' WHEN 2 THEN N'Pago recibido'
            ELSE N'Novedades de tu estacion' END,
            CONCAT(N'Hola ', @first_name, N', consulta la actualizacion de tu servicio en ', @city, N'.'),
            CASE WHEN @n % 3 = 0 THEN 1 ELSE 0 END);
        SET IDENTITY_INSERT dbo.notifications OFF;
        SET IDENTITY_INSERT dbo.bicycle_history ON;
        INSERT INTO dbo.bicycle_history(bicycle_history_id, bicycle_id, event_type, description)
        VALUES (@n, @n, CASE @n % 4 WHEN 0 THEN 'registered' WHEN 1 THEN 'maintenance'
            WHEN 2 THEN 'docked' ELSE 'status_changed' END,
            CONCAT(N'Registro de bicicleta en ', @city, N'; revision ', 1 + @n * 3 % 12));
        SET IDENTITY_INSERT dbo.bicycle_history OFF;
        SET IDENTITY_INSERT dbo.reviews ON;
        INSERT INTO dbo.reviews(review_id, client_id, rental_id, rating, comment_text)
        VALUES (@n, @n, @n, 1 + @n * 7 % 5, CASE @n % 5
            WHEN 0 THEN CONCAT(N'Buen servicio en ', @city, N', bicicleta en buen estado.')
            WHEN 1 THEN N'Proceso sencillo y rapido.'
            WHEN 2 THEN N'La estacion estaba limpia y bien ubicada.'
            WHEN 3 THEN N'La bicicleta funciono correctamente durante el recorrido.'
            ELSE N'Buena experiencia; volveria a utilizar el servicio.' END);
        SET IDENTITY_INSERT dbo.reviews OFF;
        SET IDENTITY_INSERT dbo.invoices ON;
        INSERT INTO dbo.invoices(invoice_id, payment_id, invoice_number, subtotal, tax, total)
        VALUES (@n, @n, CONCAT('FAC-', YEAR(SYSDATETIME()), '-', FORMAT(8500 + @n * 17, 'D6')),
            @amount, ROUND(@amount * 0.19, 2), ROUND(@amount * 1.19, 2));
        SET IDENTITY_INSERT dbo.invoices OFF;

        SET @n += 1;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT tabla, registros
FROM (
  SELECT N'roles' AS tabla, COUNT_BIG(*) AS registros FROM dbo.roles
UNION ALL
SELECT N'users' AS tabla, COUNT_BIG(*) AS registros FROM dbo.users
UNION ALL
SELECT N'clients' AS tabla, COUNT_BIG(*) AS registros FROM dbo.clients
UNION ALL
SELECT N'stations' AS tabla, COUNT_BIG(*) AS registros FROM dbo.stations
UNION ALL
SELECT N'station_locations' AS tabla, COUNT_BIG(*) AS registros FROM dbo.station_locations
UNION ALL
SELECT N'station_schedules' AS tabla, COUNT_BIG(*) AS registros FROM dbo.station_schedules
UNION ALL
SELECT N'docking_points' AS tabla, COUNT_BIG(*) AS registros FROM dbo.docking_points
UNION ALL
SELECT N'bicycles' AS tabla, COUNT_BIG(*) AS registros FROM dbo.bicycles
UNION ALL
SELECT N'bicycle_dockings' AS tabla, COUNT_BIG(*) AS registros FROM dbo.bicycle_dockings
UNION ALL
SELECT N'rates' AS tabla, COUNT_BIG(*) AS registros FROM dbo.rates
UNION ALL
SELECT N'reservations' AS tabla, COUNT_BIG(*) AS registros FROM dbo.reservations
UNION ALL
SELECT N'rentals' AS tabla, COUNT_BIG(*) AS registros FROM dbo.rentals
UNION ALL
SELECT N'rental_events' AS tabla, COUNT_BIG(*) AS registros FROM dbo.rental_events
UNION ALL
SELECT N'penalties' AS tabla, COUNT_BIG(*) AS registros FROM dbo.penalties
UNION ALL
SELECT N'maintenance' AS tabla, COUNT_BIG(*) AS registros FROM dbo.maintenance
UNION ALL
SELECT N'payments' AS tabla, COUNT_BIG(*) AS registros FROM dbo.payments
UNION ALL
SELECT N'incidents' AS tabla, COUNT_BIG(*) AS registros FROM dbo.incidents
UNION ALL
SELECT N'notifications' AS tabla, COUNT_BIG(*) AS registros FROM dbo.notifications
UNION ALL
SELECT N'bicycle_history' AS tabla, COUNT_BIG(*) AS registros FROM dbo.bicycle_history
UNION ALL
SELECT N'reviews' AS tabla, COUNT_BIG(*) AS registros FROM dbo.reviews
UNION ALL
SELECT N'invoices' AS tabla, COUNT_BIG(*) AS registros FROM dbo.invoices
) AS resultados
ORDER BY tabla;
GO
