/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
(5) https://www.w3schools.com/sql/sql_join_left.asp
(6) https://vrcacademy.com/tutorials/postgresql-database-triggers/
 */


-- this function executes only when a trigger calls it. If we modify the DB correctly,
-- there should not be any error happening
CREATE OR REPLACE FUNCTION check_guest_table_capacity()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(1)
        SELECT r.id, r.number_of_guests, COALESCE(SUM(t.capacity), 0)
        FROM reservations r
            LEFT JOIN reservation_tables rt ON rt.reservation = r.id
            LEFT JOIN tables t ON t.id = rt.table
        WHERE r.status IN ('confirmed'::status_type, 'completed'::status_type)
        GROUP BY r.id, r.number_of_guests
        HAVING r.number_of_guests > COALESCE(SUM(t.capacity), 0))
    THEN
        RAISE EXCEPTION 'Too many guests. Table capacity not suitable';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql security definer;

-- if more guests come to a reservation, do we have enough table seats ?
CREATE TRIGGER trigger_validate_reservation_capacity
    AFTER INSERT OR UPDATE OF number_of_guests, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();

-- if we remove reservation tables, we first need to check that the
-- reservation itself was deleted which changes the status to "cancelled",
-- which doesn't trigger check_guest_table_capacity())
-- CONSTRAINT because it is deferred. see doc(2)
CREATE CONSTRAINT TRIGGER trigger_validate_reservation_tables_capacity
    AFTER DELETE
    ON reservation_tables
    -- deferred because reservation_tables is "delete cascade"-linked to reservations
    -- therefore it waits for the reservations to update first before executing this trigger
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();

-- if we downsize a table, or delete a table, do we still have enough table seats ?
CREATE TRIGGER trigger_validate_reservation_tables_capacity
    AFTER UPDATE OF capacity OR DELETE
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();