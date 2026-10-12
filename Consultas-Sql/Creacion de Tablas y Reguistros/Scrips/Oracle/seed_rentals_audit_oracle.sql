-- Oracle: fila aislada para probar los triggers existentes de RENTALS.
-- Requiere seed_oracle_100.sql y los triggers de auditoria ya instalados.
DECLARE
    v_trigger_test_rental_id rentals.rental_id%TYPE;
    v_resultado SYS_REFCURSOR;
BEGIN
    INSERT INTO rentals
        (client_id, bicycle_id, rate_id, start_station_id, end_station_id,
         started_at, ended_at, status, total_amount)
    VALUES
        (1, 1, 1, 1, 2, SYSTIMESTAMP, NULL, 'active', 0.00)
    RETURNING rental_id INTO v_trigger_test_rental_id;

    UPDATE rentals
    SET ended_at = started_at + INTERVAL '1' HOUR,
        status = 'completed',
        total_amount = 1000.00
    WHERE rental_id = v_trigger_test_rental_id;

    DELETE FROM rentals
    WHERE rental_id = v_trigger_test_rental_id;

    COMMIT;

    OPEN v_resultado FOR
        SELECT v_trigger_test_rental_id AS trigger_test_rental_id
        FROM dual;
    DBMS_SQL.RETURN_RESULT(v_resultado);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
