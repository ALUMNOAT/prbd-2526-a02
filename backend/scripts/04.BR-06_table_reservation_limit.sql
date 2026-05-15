/*
 (1) https://stackoverflow.com/questions/6133107/extract-date-yyyy-mm-dd-from-a-timestamp-in-postgresql
 (2) https://www.pgtutorial.com/plpgsql/plpgsql-record/
 (3) https://stackoverflow.com/questions/4547672/return-multiple-fields-as-a-record-in-postgresql-with-pl-pgsql
 */

CREATE OR REPLACE FUNCTION check_table_reservation_limit()
    RETURNS TRIGGER AS $$
DECLARE
    new_r RECORD = get_reservation(NEW.reservation);
BEGIN
    IF new_r.status IN ('confirmed'::status_type, 'completed'::status_type)
    AND EXISTS(      -- see doc(8)
        SELECT 1
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.table = NEW.table
        LEFT JOIN services s ON s.restaurant = r.restaurant
        WHERE r.status IN ('confirmed'::status_type, 'completed'::status_type)
          AND r.datetime::date = new_r.datetime
          AND s.day_of_week =
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-05: No slots exists at the given reservation''s timedate';
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_table_reservation_limit
    BEFORE INSERT
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_table_reservation_limit();


CREATE OR REPLACE FUNCTION get_reservation(rt_reservation int)
RETURNS RECORD AS $$
    SELECT r.*
    FROM reservations r
    WHERE r.id = rt_reservation
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION table_reservation_overflow(r_rt_data record)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM reservations r
        LEFT JOIN services s ON s.restaurant = r.restaurant
        LEFT JOIN tables t ON t.restaurant = r.restaurant
        WHERE r.restaurant = r_rt_data.restaurant
          AND r.datetime::date = r_rt_data.datetime::date
          AND is_same_service(s.*, r.datetime::time, r_rt_data::time)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_same_service(serv record, r1_time time, r2_time time)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM reservations r
                 LEFT JOIN services s ON s.restaurant = r.restaurant
                 LEFT JOIN tables t ON t.restaurant = r.restaurant
        WHERE r.restaurant = r_rt_data.restaurant
          AND r.datetime::date = r_rt_data.datetime::date
          AND
    );
END;
$$ LANGUAGE plpgsql