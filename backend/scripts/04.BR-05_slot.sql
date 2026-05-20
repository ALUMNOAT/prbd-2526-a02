/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
(5) https://runebook.dev/en/docs/postgresql/functions-datetime/id-1.5.8.15.13.3
(6) https://pulse.support/kb/postgresql-date-part-extract-functions <-- extract is SQL friendly
(7) https://www.postgresql.org/docs/current/plpgsql-trigger.html
(8) https://www.postgresql.org/docs/18/plpgsql-control-structures.html
 */


-- check only new reservations, or updates on datetime.
CREATE OR REPLACE FUNCTION check_slot()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (      -- see doc(8)
        SELECT 1
        FROM get_restaurant(NEW.restaurant) rst
        WHERE EXTRACT('minute', NEW.datetime) % rst.slot_duration = 0
    ) THEN
        RAISE EXCEPTION 'BR-05: No slots exists at the given reservation''s timedate';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- does a reservation fit into a slot ?
CREATE TRIGGER trigger_validate_reservation_tables_slot
    BEFORE INSERT OR UPDATE OF datetime
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_slot();
