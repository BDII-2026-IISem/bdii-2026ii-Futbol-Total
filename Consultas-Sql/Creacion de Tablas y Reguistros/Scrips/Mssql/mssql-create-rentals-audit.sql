-- SQL Server audit table required by the existing rentals audit triggers.
USE [Pedalibre-Terminal-Dbeaver];
GO

IF OBJECT_ID(N'dbo.rentals_audit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.rentals_audit (
        audit_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        rental_id INT NOT NULL,
        action_name NVARCHAR(10) NOT NULL
            CHECK (action_name IN (N'INSERT', N'UPDATE', N'DELETE')),
        changed_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        changed_by NVARCHAR(128) NOT NULL,
        before_data NVARCHAR(MAX) NULL
            CHECK (before_data IS NULL OR ISJSON(before_data) = 1),
        after_data NVARCHAR(MAX) NULL
            CHECK (after_data IS NULL OR ISJSON(after_data) = 1)
    );
END;
GO
