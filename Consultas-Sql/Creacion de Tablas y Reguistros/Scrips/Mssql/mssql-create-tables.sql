-- SQL Server table creation script for Pedalibre-Terminal-Dbeaver.
-- Run with sqlcmd -b so execution stops at the first SQL error.
USE [Pedalibre-Terminal-Dbeaver];
GO

CREATE TABLE dbo.roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.stations (
    station_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    capacity INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT ck_stations_capacity CHECK (capacity >= 0)
);
GO

CREATE TABLE dbo.bicycles (
    bicycle_id INT IDENTITY(1,1) PRIMARY KEY,
    serial_number VARCHAR(80) NOT NULL UNIQUE,
    bicycle_type VARCHAR(50) NOT NULL DEFAULT 'standard',
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    created_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.rates (
    rate_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_unit VARCHAR(30) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT ck_rates_price CHECK (price >= 0)
);
GO

CREATE TABLE dbo.users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150) UNIQUE,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES dbo.roles(role_id)
);
GO

CREATE TABLE dbo.station_locations (
    station_location_id INT IDENTITY(1,1) PRIMARY KEY,
    station_id INT NOT NULL UNIQUE,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    CONSTRAINT fk_station_locations_stations FOREIGN KEY (station_id) REFERENCES dbo.stations(station_id)
);
GO

CREATE TABLE dbo.station_schedules (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    station_id INT NOT NULL,
    day_of_week TINYINT NOT NULL,
    opening_time TIME,
    closing_time TIME,
    is_closed BIT NOT NULL DEFAULT 0,
    CONSTRAINT fk_station_schedules_stations FOREIGN KEY (station_id) REFERENCES dbo.stations(station_id),
    CONSTRAINT ck_station_schedules_day CHECK (day_of_week BETWEEN 1 AND 7)
);
GO

CREATE TABLE dbo.docking_points (
    docking_point_id INT IDENTITY(1,1) PRIMARY KEY,
    station_id INT NOT NULL,
    code VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    CONSTRAINT fk_docking_points_stations FOREIGN KEY (station_id) REFERENCES dbo.stations(station_id),
    CONSTRAINT uq_docking_points_code UNIQUE (station_id, code)
);
GO

CREATE TABLE dbo.clients (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(30),
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT fk_clients_users FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO

CREATE TABLE dbo.bicycle_dockings (
    bicycle_docking_id INT IDENTITY(1,1) PRIMARY KEY,
    bicycle_id INT NOT NULL,
    docking_point_id INT NOT NULL,
    docked_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    undocked_at DATETIME2,
    CONSTRAINT fk_bicycle_dockings_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id),
    CONSTRAINT fk_bicycle_dockings_points FOREIGN KEY (docking_point_id) REFERENCES dbo.docking_points(docking_point_id),
    CONSTRAINT ck_bicycle_dockings_dates CHECK (undocked_at IS NULL OR undocked_at >= docked_at)
);
GO

CREATE TABLE dbo.reservations (
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    bicycle_id INT NOT NULL,
    station_id INT NOT NULL,
    reserved_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    expires_at DATETIME2,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_reservations_clients FOREIGN KEY (client_id) REFERENCES dbo.clients(client_id),
    CONSTRAINT fk_reservations_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id),
    CONSTRAINT fk_reservations_stations FOREIGN KEY (station_id) REFERENCES dbo.stations(station_id)
);
GO

CREATE TABLE dbo.rentals (
    rental_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    bicycle_id INT NOT NULL,
    rate_id INT NOT NULL,
    start_station_id INT,
    end_station_id INT,
    started_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ended_at DATETIME2,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    total_amount DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT fk_rentals_clients FOREIGN KEY (client_id) REFERENCES dbo.clients(client_id),
    CONSTRAINT fk_rentals_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id),
    CONSTRAINT fk_rentals_rates FOREIGN KEY (rate_id) REFERENCES dbo.rates(rate_id),
    CONSTRAINT fk_rentals_start_station FOREIGN KEY (start_station_id) REFERENCES dbo.stations(station_id),
    CONSTRAINT fk_rentals_end_station FOREIGN KEY (end_station_id) REFERENCES dbo.stations(station_id),
    CONSTRAINT ck_rentals_amount CHECK (total_amount >= 0),
    CONSTRAINT ck_rentals_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
);
GO

CREATE TABLE dbo.rental_events (
    rental_event_id INT IDENTITY(1,1) PRIMARY KEY,
    rental_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    event_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_rental_events_rentals FOREIGN KEY (rental_id) REFERENCES dbo.rentals(rental_id)
);
GO

CREATE TABLE dbo.penalties (
    penalty_id INT IDENTITY(1,1) PRIMARY KEY,
    rental_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_penalties_rentals FOREIGN KEY (rental_id) REFERENCES dbo.rentals(rental_id),
    CONSTRAINT ck_penalties_amount CHECK (amount >= 0)
);
GO

CREATE TABLE dbo.maintenance (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    bicycle_id INT NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    scheduled_at DATETIME2,
    completed_at DATETIME2,
    cost DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_maintenance_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id),
    CONSTRAINT ck_maintenance_cost CHECK (cost >= 0)
);
GO

CREATE TABLE dbo.payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    rental_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(150),
    paid_at DATETIME2,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_payments_rentals FOREIGN KEY (rental_id) REFERENCES dbo.rentals(rental_id),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0)
);
GO

CREATE TABLE dbo.notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message VARCHAR(1000) NOT NULL,
    is_read BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_notifications_users FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
GO

CREATE TABLE dbo.bicycle_history (
    bicycle_history_id INT IDENTITY(1,1) PRIMARY KEY,
    bicycle_id INT NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    recorded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_bicycle_history_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id)
);
GO

CREATE TABLE dbo.incidents (
    incident_id INT IDENTITY(1,1) PRIMARY KEY,
    bicycle_id INT,
    client_id INT,
    rental_id INT,
    description VARCHAR(500) NOT NULL,
    severity VARCHAR(30) NOT NULL DEFAULT 'medium',
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    reported_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_incidents_bicycles FOREIGN KEY (bicycle_id) REFERENCES dbo.bicycles(bicycle_id),
    CONSTRAINT fk_incidents_clients FOREIGN KEY (client_id) REFERENCES dbo.clients(client_id),
    CONSTRAINT fk_incidents_rentals FOREIGN KEY (rental_id) REFERENCES dbo.rentals(rental_id)
);
GO

CREATE TABLE dbo.reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    rental_id INT NOT NULL UNIQUE,
    rating TINYINT NOT NULL,
    comment_text VARCHAR(1000),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_reviews_clients FOREIGN KEY (client_id) REFERENCES dbo.clients(client_id),
    CONSTRAINT fk_reviews_rentals FOREIGN KEY (rental_id) REFERENCES dbo.rentals(rental_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE TABLE dbo.invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_id INT NOT NULL UNIQUE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    issued_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_invoices_payments FOREIGN KEY (payment_id) REFERENCES dbo.payments(payment_id),
    CONSTRAINT ck_invoices_amounts CHECK (subtotal >= 0 AND tax >= 0 AND total >= 0)
);
GO

SELECT name AS tabla
FROM sys.tables
WHERE is_ms_shipped = 0
ORDER BY name;
GO
