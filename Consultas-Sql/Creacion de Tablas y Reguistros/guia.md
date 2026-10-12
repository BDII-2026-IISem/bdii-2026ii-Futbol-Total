# Guía de creación de tablas — PedalLibre

Esta guía reúne los scripts para crear las 21 tablas de PedalLibre en **MySQL, Microsoft SQL Server, Oracle y PostgreSQL**.

## Tablas incluidas

`roles`, `users`, `clients`, `stations`, `station_locations`, `station_schedules`, `docking_points`, `bicycles`, `bicycle_dockings`, `reservations`, `rates`, `rentals`, `rental_events`, `penalties`, `maintenance`, `payments`, `incidents`, `notifications`, `bicycle_history`, `reviews`, `invoices`.

Para crear las tablas desde WSL, usa los scripts SQL por motor dentro de `Scrips/`. Esta es la forma recomendada: evita copiar por accidente bloques de motores distintos o ejecutar un grupo fuera de orden. Los pasos y archivos están en las secciones de cada motor. Para insertar datos de prueba despues de crear las tablas, consulta [guia_insert_datos.md](./guia_insert_datos.md), que describe los datos y contiene los comandos WSL para los cuatro motores.

> **Advertencia:** los scripts de limpieza eliminan tablas y datos existentes. Haz una copia de seguridad y verifica la conexión antes de ejecutarlos. Ejecuta cada sección únicamente en su motor de base de datos. Los tipos y algunas columnas varían para adaptarse a cada motor.

---

# 1. MySQL

Base de datos: `Pedalibre-Terminal-Dbeaver`

## 1.1 Limpiar las tablas anteriores

Este bloque elimina las tablas que aparecen en la conexión MySQL de DBeaver (`alquiler`, `alquiler_audit`, `anclaje`, `bicicleta`, `cliente`, `estacion`, `evento_alquiler`, `mantenimiento`, `pago`, `penalidad`, `reserva` y `tarifa`). También elimina sus datos. Verifica que la conexión activa sea la base MySQL `Pedalibre-Terminal-Dbeaver`.

```sql
USE `Pedalibre-Terminal-Dbeaver`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS
    `alquiler`,
    `alquiler_audit`,
    `anclaje`,
    `bicicleta`,
    `cliente`,
    `estacion`,
    `evento_alquiler`,
    `mantenimiento`,
    `pago`,
    `penalidad`,
    `reserva`,
    `tarifa`;

SET FOREIGN_KEY_CHECKS = 1;
```

En DBeaver, selecciona todo el bloque y ejecútalo como script (**Alt+X / Execute SQL Script**), no sentencia por sentencia. Después actualiza el nodo `Tables`.

### Verificar el borrado

Ejecuta esta consulta después del bloque de limpieza. El resultado esperado es **cero filas**.

```sql
USE `Pedalibre-Terminal-Dbeaver`;

SELECT TABLE_NAME AS tabla
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

## 1.2 Crear las tablas

La opción recomendada es ejecutar el script completo desde WSL. El archivo [`mysql-create-tables.sql`](./Scrips/Mysql/mysql-create-tables.sql) crea las 21 tablas en orden de dependencias. Asegúrate de que el contenedor `mysql` esté en ejecución y de que la base exista; el script no borra ni reemplaza tablas existentes.

```bash
cd "$HOME/ia-lab/services/motores-bd/mysql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mysql/mysql-create-tables.sql" mysql-server:/tmp/mysql-create-tables.sql
docker compose exec -it mysql sh -c 'mysql -u root -p Pedalibre-Terminal-Dbeaver < /tmp/mysql-create-tables.sql'
```

Ingresa la clave de MySQL cuando se solicite. Si prefieres crear las tablas por bloques, los grupos siguientes muestran el orden de dependencias; ejecuta cada bloque completo, en orden, y detente si aparece un error.

### Grupo 1: tablas independientes

```mysql
USE `Pedalibre-Terminal-Dbeaver`;

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE stations (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    capacity INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_stations_capacity CHECK (capacity >= 0)
) ENGINE=InnoDB;

CREATE TABLE bicycles (
    bicycle_id INT AUTO_INCREMENT PRIMARY KEY,
    serial_number VARCHAR(80) NOT NULL UNIQUE,
    bicycle_type VARCHAR(50) NOT NULL DEFAULT 'standard',
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_unit VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_rates_price CHECK (price >= 0)
) ENGINE=InnoDB;
```

### Grupo 2: usuarios y estructura de estaciones

```mysql
USE `Pedalibre-Terminal-Dbeaver`;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB;

CREATE TABLE station_locations (
    station_location_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL UNIQUE,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    CONSTRAINT fk_station_locations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
) ENGINE=InnoDB;

CREATE TABLE station_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    day_of_week TINYINT NOT NULL,
    opening_time TIME,
    closing_time TIME,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_station_schedules_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_station_schedules_day CHECK (day_of_week BETWEEN 1 AND 7)
) ENGINE=InnoDB;

CREATE TABLE docking_points (
    docking_point_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    code VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    CONSTRAINT fk_docking_points_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT uq_docking_points_code UNIQUE (station_id, code)
) ENGINE=InnoDB;

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clients_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;
```

### Grupo 3: operaciones relacionadas

```mysql
USE `Pedalibre-Terminal-Dbeaver`;

CREATE TABLE bicycle_dockings (
    bicycle_docking_id INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id INT NOT NULL,
    docking_point_id INT NOT NULL,
    docked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    undocked_at DATETIME,
    CONSTRAINT fk_bicycle_dockings_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_bicycle_dockings_points FOREIGN KEY (docking_point_id) REFERENCES docking_points(docking_point_id),
    CONSTRAINT ck_bicycle_dockings_dates CHECK (undocked_at IS NULL OR undocked_at >= docked_at)
) ENGINE=InnoDB;

CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    bicycle_id INT NOT NULL,
    station_id INT NOT NULL,
    reserved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_reservations_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reservations_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_reservations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
) ENGINE=InnoDB;

CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    bicycle_id INT NOT NULL,
    rate_id INT NOT NULL,
    start_station_id INT,
    end_station_id INT,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    total_amount DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT fk_rentals_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_rentals_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_rentals_rates FOREIGN KEY (rate_id) REFERENCES rates(rate_id),
    CONSTRAINT fk_rentals_start_station FOREIGN KEY (start_station_id) REFERENCES stations(station_id),
    CONSTRAINT fk_rentals_end_station FOREIGN KEY (end_station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_rentals_amount CHECK (total_amount >= 0),
    CONSTRAINT ck_rentals_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
) ENGINE=InnoDB;

CREATE TABLE rental_events (
    rental_event_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    event_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_events_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
) ENGINE=InnoDB;

CREATE TABLE penalties (
    penalty_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_penalties_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_penalties_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id INT NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    scheduled_at DATETIME,
    completed_at DATETIME,
    cost DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_maintenance_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT ck_maintenance_cost CHECK (cost >= 0)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(150),
    paid_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message VARCHAR(1000) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE bicycle_history (
    bicycle_history_id INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id INT NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bicycle_history_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id)
) ENGINE=InnoDB;
```

### Grupo 4: tablas dependientes finales

```mysql
USE `Pedalibre-Terminal-Dbeaver`;

CREATE TABLE incidents (
    incident_id INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id INT,
    client_id INT,
    rental_id INT,
    description VARCHAR(500) NOT NULL,
    severity VARCHAR(30) NOT NULL DEFAULT 'medium',
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incidents_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_incidents_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_incidents_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
) ENGINE=InnoDB;

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    rental_id INT NOT NULL UNIQUE,
    rating TINYINT NOT NULL,
    comment_text VARCHAR(1000),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reviews_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL UNIQUE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_invoices_payments FOREIGN KEY (payment_id) REFERENCES payments(payment_id),
    CONSTRAINT ck_invoices_amounts CHECK (subtotal >= 0 AND tax >= 0 AND total >= 0)
) ENGINE=InnoDB;
```

---

# 2. Microsoft SQL Server

Base de datos: `Pedalibre-Terminal-Dbeaver`

## 2.1 Limpiar tablas anteriores

Este es el comando confirmado que funcionó desde WSL usando el contenedor `mssql` y el login `admin`. **Elimina todas las tablas de usuario y sus datos en `Pedalibre-Terminal-Dbeaver`**. Ejecútalo en la terminal WSL, desde `~/ia-lab/services/motores-bd/mssql`, no dentro del prompt interactivo de `sqlcmd`. Cuando aparezca `Password:`, ingresa la contraseña de `admin`.

```bash
docker compose exec -it mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U admin -C -d Pedalibre-Terminal-Dbeaver -b -Q "SET NOCOUNT ON; DECLARE @sql NVARCHAR(MAX); SELECT @sql = STRING_AGG(CONVERT(NVARCHAR(MAX), N'ALTER TABLE '+QUOTENAME(SCHEMA_NAME(t.schema_id))+N'.'+QUOTENAME(t.name)+N' DROP CONSTRAINT '+QUOTENAME(fk.name)+N';'), N' ') FROM sys.foreign_keys AS fk JOIN sys.tables AS t ON t.object_id=fk.parent_object_id WHERE t.is_ms_shipped=0; IF @sql IS NOT NULL EXEC sys.sp_executesql @sql; SET @sql=NULL; SELECT @sql=STRING_AGG(CONVERT(NVARCHAR(MAX), N'DROP TABLE '+QUOTENAME(SCHEMA_NAME(schema_id))+N'.'+QUOTENAME(name)+N';'), N' ') FROM sys.tables WHERE is_ms_shipped=0; IF @sql IS NOT NULL EXEC sys.sp_executesql @sql; SELECT SCHEMA_NAME(schema_id) AS esquema,name AS tabla FROM sys.tables WHERE is_ms_shipped=0;"
```

La consulta final debe devolver cero filas. Si aparecen tablas, el borrado no se completó. No ejecutes la sección 2.2 hasta verificarlo.

## 2.2 Crear las tablas

Para SQL Server, crea las tablas desde WSL con el archivo [`mssql-create-tables.sql`](./Scrips/Mssql/mssql-create-tables.sql). Contiene las 21 tablas en orden de dependencias y separa cada creación con `GO`, para que el error de una tabla no impida identificar el lote que falló.

Si quedaron tablas de un intento anterior, ejecuta primero el comando de limpieza de la sección 2.1 y confirma que su consulta final no devuelve filas. La creación no es idempotente: no vuelvas a ejecutarla si las tablas ya existen.

```bash
cd "$HOME/ia-lab/services/motores-bd/mssql"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Mssql/mssql-create-tables.sql" mssql-server:/tmp/mssql-create-tables.sql
docker compose exec -it mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U admin -C -d Pedalibre-Terminal-Dbeaver -b -i /tmp/mssql-create-tables.sql
```

# 3. Oracle

Conéctate con el usuario/esquema `PEDALIBRETERMINALDBEAVER`.

## 3.1 Limpiar tablas anteriores

```sql
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/
```

## 3.2 Crear las tablas

La opción recomendada es ejecutar desde WSL el archivo [`oracle-create-tables.sql`](./Scrips/Oracle/oracle-create-tables.sql). Conecta al mismo esquema donde se ejecutará la carga de datos. El script crea las 21 tablas en orden de dependencias; no borra ni reemplaza tablas existentes.

```bash
cd "$HOME/ia-lab/services/motores-bd/oracle"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Oracle/oracle-create-tables.sql" oracle-server:/tmp/oracle-create-tables.sql
docker compose exec -it oracle sqlplus -L 'PEDALIBRETERMINALDBEAVER@//localhost:1521/Pedalibre' @/tmp/oracle-create-tables.sql
```

Ingresa la clave del esquema cuando sqlplus la solicite. Si prefieres crear por bloques, los grupos siguientes muestran el orden de dependencias; ejecuta cada grupo completo en orden y detente si aparece un error.

### Grupo 1: tablas independientes

```sql
CREATE TABLE roles (
    role_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR2(50) NOT NULL UNIQUE,
    description VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stations (
    station_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR2(120) NOT NULL,
    address VARCHAR2(255) NOT NULL,
    capacity NUMBER(10) DEFAULT 0 NOT NULL,
    status VARCHAR2(30) DEFAULT 'active' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_stations_capacity CHECK (capacity >= 0)
);

CREATE TABLE bicycles (
    bicycle_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    serial_number VARCHAR2(80) NOT NULL UNIQUE,
    bicycle_type VARCHAR2(50) DEFAULT 'standard' NOT NULL,
    status VARCHAR2(30) DEFAULT 'available' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rates (
    rate_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    price NUMBER(10,2) NOT NULL,
    billing_unit VARCHAR2(30) NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT ck_rates_price CHECK (price >= 0),
    CONSTRAINT ck_rates_active CHECK (is_active IN (0,1))
);
```

### Grupo 2: usuarios y estructura de estaciones

```sql
CREATE TABLE users (
    user_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    role_id NUMBER NOT NULL,
    username VARCHAR2(100) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    email VARCHAR2(150) UNIQUE,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT ck_users_active CHECK (is_active IN (0,1))
);

CREATE TABLE station_locations (
    station_location_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id NUMBER NOT NULL UNIQUE,
    latitude NUMBER(10,7),
    longitude NUMBER(10,7),
    CONSTRAINT fk_station_locations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE station_schedules (
    schedule_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id NUMBER NOT NULL,
    day_of_week NUMBER(1) NOT NULL,
    opening_time VARCHAR2(8),
    closing_time VARCHAR2(8),
    is_closed NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT fk_station_schedules_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_station_schedules_day CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT ck_station_schedules_closed CHECK (is_closed IN (0,1))
);

CREATE TABLE docking_points (
    docking_point_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id NUMBER NOT NULL,
    code VARCHAR2(30) NOT NULL,
    status VARCHAR2(30) DEFAULT 'available' NOT NULL,
    CONSTRAINT fk_docking_points_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT uq_docking_points_code UNIQUE (station_id, code)
);

CREATE TABLE clients (
    client_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id NUMBER UNIQUE,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    document_number VARCHAR2(50) NOT NULL UNIQUE,
    phone VARCHAR2(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clients_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Grupo 3: operaciones relacionadas

```sql
CREATE TABLE bicycle_dockings (
    bicycle_docking_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id NUMBER NOT NULL,
    docking_point_id NUMBER NOT NULL,
    docked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    undocked_at TIMESTAMP,
    CONSTRAINT fk_bicycle_dockings_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_bicycle_dockings_points FOREIGN KEY (docking_point_id) REFERENCES docking_points(docking_point_id),
    CONSTRAINT ck_bicycle_dockings_dates CHECK (undocked_at IS NULL OR undocked_at >= docked_at)
);

CREATE TABLE reservations (
    reservation_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id NUMBER NOT NULL,
    bicycle_id NUMBER NOT NULL,
    station_id NUMBER NOT NULL,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at TIMESTAMP,
    status VARCHAR2(30) DEFAULT 'pending' NOT NULL,
    CONSTRAINT fk_reservations_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reservations_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_reservations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE rentals (
    rental_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id NUMBER NOT NULL,
    bicycle_id NUMBER NOT NULL,
    rate_id NUMBER NOT NULL,
    start_station_id NUMBER,
    end_station_id NUMBER,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    status VARCHAR2(30) DEFAULT 'active' NOT NULL,
    total_amount NUMBER(10,2) DEFAULT 0,
    CONSTRAINT fk_rentals_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_rentals_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_rentals_rates FOREIGN KEY (rate_id) REFERENCES rates(rate_id),
    CONSTRAINT fk_rentals_start_station FOREIGN KEY (start_station_id) REFERENCES stations(station_id),
    CONSTRAINT fk_rentals_end_station FOREIGN KEY (end_station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_rentals_amount CHECK (total_amount >= 0),
    CONSTRAINT ck_rentals_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE TABLE rental_events (
    rental_event_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id NUMBER NOT NULL,
    event_type VARCHAR2(50) NOT NULL,
    description VARCHAR2(500),
    event_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_rental_events_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

CREATE TABLE penalties (
    penalty_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id NUMBER NOT NULL,
    reason VARCHAR2(255) NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    status VARCHAR2(30) DEFAULT 'pending' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_penalties_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_penalties_amount CHECK (amount >= 0)
);

CREATE TABLE maintenance (
    maintenance_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id NUMBER NOT NULL,
    maintenance_type VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    cost NUMBER(10,2) DEFAULT 0,
    status VARCHAR2(30) DEFAULT 'pending' NOT NULL,
    CONSTRAINT fk_maintenance_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT ck_maintenance_cost CHECK (cost >= 0)
);

CREATE TABLE payments (
    payment_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    payment_method VARCHAR2(50) NOT NULL,
    status VARCHAR2(30) DEFAULT 'pending' NOT NULL,
    transaction_reference VARCHAR2(150),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_payments_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0)
);

CREATE TABLE notifications (
    notification_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    title VARCHAR2(150) NOT NULL,
    message VARCHAR2(1000) NOT NULL,
    is_read NUMBER(1) DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_notifications_users FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT ck_notifications_read CHECK (is_read IN (0,1))
);

CREATE TABLE bicycle_history (
    bicycle_history_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id NUMBER NOT NULL,
    event_type VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_bicycle_history_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id)
);
```

### Grupo 4: tablas dependientes finales

```sql
CREATE TABLE incidents (
    incident_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id NUMBER,
    client_id NUMBER,
    rental_id NUMBER,
    description VARCHAR2(500) NOT NULL,
    severity VARCHAR2(30) DEFAULT 'medium' NOT NULL,
    status VARCHAR2(30) DEFAULT 'open' NOT NULL,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_incidents_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_incidents_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_incidents_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

CREATE TABLE reviews (
    review_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id NUMBER NOT NULL,
    rental_id NUMBER NOT NULL UNIQUE,
    rating NUMBER(1) NOT NULL,
    comment_text VARCHAR2(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_reviews_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reviews_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE invoices (
    invoice_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    payment_id NUMBER NOT NULL UNIQUE,
    invoice_number VARCHAR2(50) NOT NULL UNIQUE,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subtotal NUMBER(10,2) NOT NULL,
    tax NUMBER(10,2) DEFAULT 0 NOT NULL,
    total NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_invoices_payments FOREIGN KEY (payment_id) REFERENCES payments(payment_id),
    CONSTRAINT ck_invoices_amounts CHECK (subtotal >= 0 AND tax >= 0 AND total >= 0)
);
```

# 4. PostgreSQL

Base de datos: `Pedalibre-Terminal-Dbeaver`

## 4.1 Limpiar tablas anteriores del esquema `public`

Este bloque elimina todas las tablas del esquema `public`. Si hay otras tablas que quieras conservar, no lo ejecutes sin adaptar la lista.

```sql
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS public.%I CASCADE', t.tablename);
    END LOOP;
END $$;
```

## 4.2 Crear las tablas

La opción recomendada es ejecutar desde WSL el archivo [`postgres-create-tables.sql`](./Scrips/Postgres/postgres-create-tables.sql). Crea las 21 tablas en orden de dependencias en el esquema `public`; no borra ni reemplaza tablas existentes.

```bash
cd "$HOME/ia-lab/services/motores-bd/postgres"
docker cp "$HOME/ia-lab/projecs/base de datos 2/Consultas-Sql/Creacion de Tablas y Reguistros/Scrips/Postgres/postgres-create-tables.sql" postgres-server:/tmp/postgres-create-tables.sql
docker compose exec -it postgres psql -h localhost -W -U postgres -d Pedalibre-Terminal-Dbeaver -v ON_ERROR_STOP=1 -f /tmp/postgres-create-tables.sql
```

Ingresa la clave de PostgreSQL cuando psql la solicite. Si prefieres crear por bloques, los grupos siguientes muestran el orden de dependencias; ejecuta cada grupo completo en orden y detente si aparece un error.

### Grupo 1: tablas independientes

```sql
CREATE TABLE roles (
    role_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stations (
    station_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_stations_capacity CHECK (capacity >= 0)
);

CREATE TABLE bicycles (
    bicycle_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    serial_number VARCHAR(80) NOT NULL UNIQUE,
    bicycle_type VARCHAR(50) NOT NULL DEFAULT 'standard',
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rates (
    rate_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    billing_unit VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_rates_price CHECK (price >= 0)
);
```

### Grupo 2: usuarios y estructura de estaciones

```sql
CREATE TABLE users (
    user_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    role_id INTEGER NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(150) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE station_locations (
    station_location_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id INTEGER NOT NULL UNIQUE,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    CONSTRAINT fk_station_locations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE station_schedules (
    schedule_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id INTEGER NOT NULL,
    day_of_week SMALLINT NOT NULL,
    opening_time TIME,
    closing_time TIME,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_station_schedules_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_station_schedules_day CHECK (day_of_week BETWEEN 1 AND 7)
);

CREATE TABLE docking_points (
    docking_point_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    station_id INTEGER NOT NULL,
    code VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    CONSTRAINT fk_docking_points_stations FOREIGN KEY (station_id) REFERENCES stations(station_id),
    CONSTRAINT uq_docking_points_code UNIQUE (station_id, code)
);

CREATE TABLE clients (
    client_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id INTEGER UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clients_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Grupo 3: operaciones relacionadas

```sql
CREATE TABLE bicycle_dockings (
    bicycle_docking_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id INTEGER NOT NULL,
    docking_point_id INTEGER NOT NULL,
    docked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    undocked_at TIMESTAMP,
    CONSTRAINT fk_bicycle_dockings_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_bicycle_dockings_points FOREIGN KEY (docking_point_id) REFERENCES docking_points(docking_point_id),
    CONSTRAINT ck_bicycle_dockings_dates CHECK (undocked_at IS NULL OR undocked_at >= docked_at)
);

CREATE TABLE reservations (
    reservation_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    bicycle_id INTEGER NOT NULL,
    station_id INTEGER NOT NULL,
    reserved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_reservations_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reservations_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_reservations_stations FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE rentals (
    rental_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    bicycle_id INTEGER NOT NULL,
    rate_id INTEGER NOT NULL,
    start_station_id INTEGER,
    end_station_id INTEGER,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    total_amount NUMERIC(10,2) DEFAULT 0,
    CONSTRAINT fk_rentals_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_rentals_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_rentals_rates FOREIGN KEY (rate_id) REFERENCES rates(rate_id),
    CONSTRAINT fk_rentals_start_station FOREIGN KEY (start_station_id) REFERENCES stations(station_id),
    CONSTRAINT fk_rentals_end_station FOREIGN KEY (end_station_id) REFERENCES stations(station_id),
    CONSTRAINT ck_rentals_amount CHECK (total_amount >= 0),
    CONSTRAINT ck_rentals_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE TABLE rental_events (
    rental_event_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id INTEGER NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    event_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_events_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

CREATE TABLE penalties (
    penalty_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id INTEGER NOT NULL,
    reason VARCHAR(255) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_penalties_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_penalties_amount CHECK (amount >= 0)
);

CREATE TABLE maintenance (
    maintenance_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id INTEGER NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    cost NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_maintenance_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT ck_maintenance_cost CHECK (cost >= 0)
);

CREATE TABLE payments (
    payment_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rental_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(150),
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0)
);

CREATE TABLE notifications (
    notification_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    message VARCHAR(1000) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE bicycle_history (
    bicycle_history_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id INTEGER NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bicycle_history_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id)
);
```

### Grupo 4: tablas dependientes finales

```sql
CREATE TABLE incidents (
    incident_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    bicycle_id INTEGER,
    client_id INTEGER,
    rental_id INTEGER,
    description VARCHAR(500) NOT NULL,
    severity VARCHAR(30) NOT NULL DEFAULT 'medium',
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    reported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incidents_bicycles FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    CONSTRAINT fk_incidents_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_incidents_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

CREATE TABLE reviews (
    review_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    rental_id INTEGER NOT NULL UNIQUE,
    rating SMALLINT NOT NULL,
    comment_text VARCHAR(1000),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_reviews_rentals FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE invoices (
    invoice_id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    payment_id INTEGER NOT NULL UNIQUE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL DEFAULT 0,
    total NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_invoices_payments FOREIGN KEY (payment_id) REFERENCES payments(payment_id),
    CONSTRAINT ck_invoices_amounts CHECK (subtotal >= 0 AND tax >= 0 AND total >= 0)
);
```

# 5. Comprobar las tablas

## MySQL

```sql
SHOW TABLES;
```

## Microsoft SQL Server

```sql
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

## Oracle

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

## PostgreSQL

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultado esperado:** 21 tablas por motor de base de datos.
