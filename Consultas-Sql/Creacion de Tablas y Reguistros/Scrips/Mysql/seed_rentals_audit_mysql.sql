-- MySQL: fila aislada para probar los triggers existentes de rentals.
-- Requiere seed_mysql_100.sql y los triggers de auditoria ya instalados.
USE `Pedalibre-Terminal-Dbeaver`;

START TRANSACTION;

INSERT INTO rentals
    (client_id, bicycle_id, rate_id, start_station_id, end_station_id,
     started_at, ended_at, status, total_amount)
VALUES
    (1, 1, 1, 1, 2, CURRENT_TIMESTAMP, NULL, 'active', 0.00);

SET @trigger_test_rental_id = LAST_INSERT_ID();

UPDATE rentals
SET ended_at = DATE_ADD(started_at, INTERVAL 1 HOUR),
    status = 'completed',
    total_amount = 1000.00
WHERE rental_id = @trigger_test_rental_id;

DELETE FROM rentals
WHERE rental_id = @trigger_test_rental_id;

COMMIT;

SELECT @trigger_test_rental_id AS trigger_test_rental_id;
