/*
 (1) https://stackoverflow.com/questions/6133107/extract-date-yyyy-mm-dd-from-a-timestamp-in-postgresql
 (2) https://www.pgtutorial.com/plpgsql/plpgsql-record/
 */

CREATE OR REPLACE FUNCTION check_table_reservation_limit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT r.status
        FROM reservations r
        WHERE r.id = NEW.reservation)
           IN ('confirmed'::status_type, 'completed'::status_type)
    AND EXISTS(      -- see doc(8)
        SELECT 1
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.table = NEW.table
        LEFT JOIN services s ON s.restaurant = r.restaurant
        WHERE r.status IN ('confirmed'::status_type, 'completed'::status_type)
          AND r.datetime::date = NEW.datetime::date
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

CREATE OR REPLACE FUNCTION get_reservation_from_reservation_tables(rt_reservation int)
RETURNS INTEGER AS $$
    SELECT r.id
    FROM reservations r
    WHERE r.id = rt_reservation
$$ LANGUAGE sql