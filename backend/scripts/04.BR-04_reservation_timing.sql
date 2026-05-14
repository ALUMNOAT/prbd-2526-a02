/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
(5) https://www.postgresql.org/docs/current/functions-datetime.html
(6) https://stackoverflow.com/questions/22835874/postgresql-convert-timestamp-to-time-or-retrieve-only-time-from-timestamp-col#22835922
(7) https://www.geeksforgeeks.org/postgresql/how-to-extract-day-of-week-from-date-field-in-postgresql/
(8) https://www.postgresql.org/docs/current/functions-formatting.html
(9) https://vrcacademy.com/tutorials/postgresql-database-triggers/
(10) https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-EXISTS
(11) https://stackoverflow.com/questions/11299037/postgresql-if-statement <-- 'EXISTS' seems to be good practice
 */


-- if the reservation fits into the restaurant's opening hours, then allow it.
CREATE OR REPLACE FUNCTION check_reservation_timing()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(1)
        SELECT 1
        FROM reservations r
        LEFT JOIN services s ON s.restaurant = r.restaurant
        WHERE NEW.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type)
          AND EXTRACT(ISODOW FROM NEW.datetime) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
          AND NEW.datetime::time > s.start_time   -- see doc(6) for '::time' syntax
          AND NEW.datetime::time < s.end_time
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-04 : Timetable conflict for the reservation';
END;
$$ LANGUAGE plpgsql security definer;

-- 'tgv' = 'trigger_validate'
CREATE TRIGGER tgv_new_reservation_timing
    BEFORE INSERT OR UPDATE OF datetime, status -- new reservation status can only be 'pending' (BR-09)
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_timing();