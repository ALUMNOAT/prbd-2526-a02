/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
(5) https://runebook.dev/en/docs/postgresql/functions-datetime/id-1.5.8.15.13.3
 */


-- finds all the reservations whose reserved table's restaurant
-- isn't the reserved restaurant itself.
CREATE OR REPLACE FUNCTION check_slot()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(1)
        SELECT r.datetime, rst.slot_duration
        FROM reservations r
                 LEFT JOIN restaurants rst ON rst.id = r.restaurant
        WHERE DATE_PART('minute', r.datetime) IN (10, 15, 20, 30, 40, 45, 50, 60)
    ) THEN
        RAISE EXCEPTION 'No slot exists at the given reservation''s timedate';
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
EXECUTE FUNCTION check_slot();

-- if a reservation changes restaurant, its table(s) should too !
CREATE TRIGGER trigger_validate_reservation_tables_ownership
    AFTER INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_slot();