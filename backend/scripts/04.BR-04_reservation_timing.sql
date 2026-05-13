/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
(5) https://www.postgresql.org/docs/current/functions-datetime.html
(6) https://stackoverflow.com/questions/22835874/postgresql-convert-timestamp-to-time-or-retrieve-only-time-from-timestamp-col#22835922
(7) https://www.geeksforgeeks.org/postgresql/how-to-extract-day-of-week-from-date-field-in-postgresql/
(8) https://www.postgresql.org/docs/current/functions-formatting.html
 */


-- finds all the reservations whose reserved table's restaurant
-- isn't the reserved restaurant itself.
CREATE OR REPLACE FUNCTION check_tables_ownership()
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


-- does the reservation use the table(s) from the correct restaurant ?
CREATE TRIGGER trigger_validate_reservation_tables_ownership
    AFTER INSERT
    ON reservation_tables
    -- deferred because reservation_tables is "delete cascade"-linked to reservations
    -- therefore it waits for the reservations to update first before executing this trigger
EXECUTE FUNCTION check_tables_ownership();

-- if a reservation changes restaurant, its table(s) should too !
CREATE TRIGGER trigger_validate_reservation_tables_ownership
    AFTER INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_tables_ownership();