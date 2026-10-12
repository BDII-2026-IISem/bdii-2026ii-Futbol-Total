-- SQL Server: fila aislada para probar los triggers existentes de rentals.
-- Requiere seed_mssql_100.sql y los triggers de auditoria ya instalados.
USE [Pedalibre-Terminal-Dbeaver];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @trigger_test_rental TABLE (rental_id INT PRIMARY KEY);

BEGIN TRANSACTION;

INSERT INTO dbo.rentals
    (client_id, bicycle_id, rate_id, start_station_id, end_station_id,
     started_at, ended_at, status, total_amount)
OUTPUT inserted.rental_id INTO @trigger_test_rental (rental_id)
VALUES
    (1, 1, 1, 1, 2, SYSDATETIME(), NULL, 'active', 0.00);

UPDATE r
SET ended_at = DATEADD(HOUR, 1, r.started_at),
    status = 'completed',
    total_amount = 1000.00
FROM dbo.rentals AS r
INNER JOIN @trigger_test_rental AS t
    ON t.rental_id = r.rental_id;

DELETE r
FROM dbo.rentals AS r
INNER JOIN @trigger_test_rental AS t
    ON t.rental_id = r.rental_id;

SELECT rental_id AS trigger_test_rental_id
FROM @trigger_test_rental;

COMMIT TRANSACTION;
GO
