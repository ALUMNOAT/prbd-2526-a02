/*
 (1) https://stackoverflow.com/questions/6133107/extract-date-yyyy-mm-dd-from-a-timestamp-in-postgresql
 (2) https://www.pgtutorial.com/plpgsql/plpgsql-record/
 (3) https://stackoverflow.com/questions/4547672/return-multiple-fields-as-a-record-in-postgresql-with-pl-pgsql
 (4) https://stackoverflow.com/questions/24755468/language-sql-vs-language-plpgsql-in-postgresql-functions
 (5) https://stackoverflow.com/questions/34721832/postgresql-return-single-row-from-function-after-select-statement
 (6) https://dba.stackexchange.com/questions/67875/return-a-record-with-pl-pgsql-function-to-speed-up-the-query
 (7) https://stackoverflow.com/questions/7945932/how-to-return-result-of-a-select-inside-a-function-in-postgresql
 (8) https://www.postgresql.org/docs/current/plpgsql-control-structures.html#PLPGSQL-STATEMENTS-RETURNING
 */


CREATE OR REPLACE FUNCTION check_table_reservation_overflow()
    RETURNS TRIGGER AS $$
DECLARE
    current_reservation reservations = get_reservation(NEW.reservation);
BEGIN
    IF (current_reservation.status IN ('confirmed'::status_type, 'completed'::status_type))
    AND EXISTS(
        SELECT 1
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.reservation = r.id
        WHERE rt."table" = NEW."table"
          AND r.datetime::date = current_reservation.datetime::date
          -- not necessary since each table is unique to a restaurant, but it pays to be cautious
          AND r.restaurant = current_reservation.restaurant
          AND r.status IN ('confirmed'::status_type, 'completed'::status_type)
          AND current_reservation::time >= get_service(r.id).start_time
          AND current_reservation::time <= get_service(r.id).end_time
    ) THEN
        RAISE EXCEPTION 'BR-06: This table is already reserved.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_table_reservation_overflow
    BEFORE INSERT
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_table_reservation_overflow();

CREATE OR REPLACE FUNCTION get_service(
    IN reservation_id INT)
    RETURNS services AS $$
BEGIN
    RETURN QUERY    -- doc (8) & doc (9)
    SELECT s.*
    FROM services s
    LEFT JOIN reservations r ON r.restaurant = s.restaurant
    WHERE r.id = reservation_id     --I'd rather have the row itself instead of the id int...
      AND s.day_of_week = EXTRACT(ISODOW FROM r.datetime)
      AND r.datetime::time >= s.start_time AND r.datetime::time <= s.end_time;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'BR-13: The given reservation id was not associated with any services';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_reservation(
    IN reservation_id INT)
    RETURNS reservations AS $$
BEGIN
    RETURN QUERY
    SELECT r.*
    FROM reservations r
    WHERE r.id = reservation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'BR-06: The given reservation id was not associated with any reservation';
    END IF;
END;
$$ LANGUAGE plpgsql;