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
CREATE OR REPLACE FUNCTION check_new_reservation_timing()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(      -- see doc(1)
        SELECT 1
        FROM get_restaurant_services(NEW.restaurant) s
        WHERE EXTRACT(ISODOW FROM NEW.datetime) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
          AND NEW.datetime::time > s.start_time   -- see doc(6) for '::time' syntax
          AND NEW.datetime::time < s.end_time
    ) THEN
        RAISE EXCEPTION 'BR-04 : The new reservation doesn''t fit into any services slot';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- 'tgv' = 'trigger_validate'
CREATE TRIGGER tgv_new_reservation_timing
    BEFORE INSERT -- new reservation status can only be 'pending' (BR-09)
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_new_reservation_timing();




CREATE OR REPLACE FUNCTION check_update_reservation_timing()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type)
    AND NOT EXISTS(      -- see doc(1)
        SELECT 1
        FROM get_restaurant_services(NEW.restaurant) s
        WHERE EXTRACT(ISODOW FROM NEW.datetime) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
          AND NEW.datetime::time > s.start_time   -- see doc(6) for '::time' syntax
          AND NEW.datetime::time < s.end_time
    ) THEN
        RAISE EXCEPTION 'BR-04 : Timetable conflict for the reservation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- 'tgv' = 'trigger_validate'
CREATE TRIGGER tgv_update_reservation_timing
    -- new reservation status can only be 'pending' (BR-09)
    -- cancelled or completed reservation cannot be modified
    -- confirmed can become pending again
    BEFORE UPDATE OF datetime, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_update_reservation_timing();