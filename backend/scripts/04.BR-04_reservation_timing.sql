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
 */


-- gets all the reservations who have no availability in the chosen restaurant
CREATE OR REPLACE FUNCTION check_reservation_timing()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(1)
        SELECT r.datetime, EXTRACT(ISODOW FROM r.datetime), s.day_of_week, s.start_time, s.end_time
        FROM reservations r
             LEFT JOIN restaurants rst ON rst.id = r.restaurant
             LEFT JOIN services s ON s.id = rst.id
        WHERE r.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type)
        AND EXTRACT(ISODOW FROM r.datetime) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
        AND s.start_time < r.datetime::time     -- see doc(6) for '::time' syntax
        AND r.datetime::time < s.end_time
    ) THEN
        RAISE EXCEPTION 'BR-04 : Timetable conflict for the reservation';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql security definer;

-- if services change, then we need to re-evaluate everything ? seems wrong
CREATE TRIGGER trigger_validate_services_timing
    AFTER DELETE OR UPDATE OF day_of_week, start_time, end_time
    ON services
EXECUTE FUNCTION check_reservation_timing();

-- if a reservation changes datetime, we check if the restaurant allows it
CREATE TRIGGER trigger_validate_reservations_timing
    AFTER INSERT OR UPDATE OF datetime
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_timing();