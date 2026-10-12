-- SQL Server: elimina los registros de las 21 tablas y conserva su estructura.
USE [Pedalibre-Terminal-Dbeaver];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM dbo.invoices;
    DELETE FROM dbo.rental_events;
    DELETE FROM dbo.penalties;
    DELETE FROM dbo.payments;
    DELETE FROM dbo.incidents;
    DELETE FROM dbo.reviews;
    DELETE FROM dbo.reservations;
    DELETE FROM dbo.bicycle_dockings;
    DELETE FROM dbo.maintenance;
    DELETE FROM dbo.bicycle_history;
    DELETE FROM dbo.rentals;
    DELETE FROM dbo.clients;
    DELETE FROM dbo.notifications;
    DELETE FROM dbo.users;
    DELETE FROM dbo.docking_points;
    DELETE FROM dbo.station_locations;
    DELETE FROM dbo.station_schedules;
    DELETE FROM dbo.bicycles;
    DELETE FROM dbo.rates;
    DELETE FROM dbo.stations;
    DELETE FROM dbo.roles;

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
    UNION ALL SELECT N'users', COUNT_BIG(*) FROM dbo.users
    UNION ALL SELECT N'clients', COUNT_BIG(*) FROM dbo.clients
    UNION ALL SELECT N'stations', COUNT_BIG(*) FROM dbo.stations
    UNION ALL SELECT N'station_locations', COUNT_BIG(*) FROM dbo.station_locations
    UNION ALL SELECT N'station_schedules', COUNT_BIG(*) FROM dbo.station_schedules
    UNION ALL SELECT N'docking_points', COUNT_BIG(*) FROM dbo.docking_points
    UNION ALL SELECT N'bicycles', COUNT_BIG(*) FROM dbo.bicycles
    UNION ALL SELECT N'bicycle_dockings', COUNT_BIG(*) FROM dbo.bicycle_dockings
    UNION ALL SELECT N'rates', COUNT_BIG(*) FROM dbo.rates
    UNION ALL SELECT N'reservations', COUNT_BIG(*) FROM dbo.reservations
    UNION ALL SELECT N'rentals', COUNT_BIG(*) FROM dbo.rentals
    UNION ALL SELECT N'rental_events', COUNT_BIG(*) FROM dbo.rental_events
    UNION ALL SELECT N'penalties', COUNT_BIG(*) FROM dbo.penalties
    UNION ALL SELECT N'maintenance', COUNT_BIG(*) FROM dbo.maintenance
    UNION ALL SELECT N'payments', COUNT_BIG(*) FROM dbo.payments
    UNION ALL SELECT N'incidents', COUNT_BIG(*) FROM dbo.incidents
    UNION ALL SELECT N'notifications', COUNT_BIG(*) FROM dbo.notifications
    UNION ALL SELECT N'bicycle_history', COUNT_BIG(*) FROM dbo.bicycle_history
    UNION ALL SELECT N'reviews', COUNT_BIG(*) FROM dbo.reviews
    UNION ALL SELECT N'invoices', COUNT_BIG(*) FROM dbo.invoices
) AS resultados
ORDER BY tabla;
GO
