-- PostgreSQL: fila aislada para probar los triggers existentes de rentals.
-- Requiere seed_postgres_100.sql y los triggers de auditoria ya instalados.
BEGIN;

CREATE TEMP TABLE trigger_test_rental_id (
    rental_id INTEGER NOT NULL
) ON COMMIT DROP;

WITH inserted_rental AS (
    INSERT INTO public.rentals
        (client_id, bicycle_id, rate_id, start_station_id, end_station_id,
         started_at, ended_at, status, total_amount)
    VALUES
        (1, 1, 1, 1, 2, CURRENT_TIMESTAMP, NULL, 'active', 0.00)
    RETURNING rental_id
)
INSERT INTO pg_temp.trigger_test_rental_id (rental_id)
SELECT rental_id FROM inserted_rental;

UPDATE public.rentals AS r
SET ended_at = r.started_at + INTERVAL '1 hour',
    status = 'completed',
    total_amount = 1000.00
WHERE r.rental_id = (
    SELECT rental_id FROM pg_temp.trigger_test_rental_id
);

DELETE FROM public.rentals AS r
WHERE r.rental_id = (
    SELECT rental_id FROM pg_temp.trigger_test_rental_id
);

SELECT rental_id AS trigger_test_rental_id
FROM pg_temp.trigger_test_rental_id;

COMMIT;
