-- PostgreSQL: elimina los registros de las 21 tablas y conserva su estructura.
-- Ejecutar en Pedalibre-Terminal-Dbeaver.
BEGIN;

DELETE FROM invoices;
DELETE FROM rental_events;
DELETE FROM penalties;
DELETE FROM payments;
DELETE FROM incidents;
DELETE FROM reviews;
DELETE FROM reservations;
DELETE FROM bicycle_dockings;
DELETE FROM maintenance;
DELETE FROM bicycle_history;
DELETE FROM rentals;
DELETE FROM clients;
DELETE FROM notifications;
DELETE FROM users;
DELETE FROM docking_points;
DELETE FROM station_locations;
DELETE FROM station_schedules;
DELETE FROM bicycles;
DELETE FROM rates;
DELETE FROM stations;
DELETE FROM roles;

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
