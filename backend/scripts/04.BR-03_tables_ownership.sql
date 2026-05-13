/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
 */


-- finds all the reservations whose reserved table's restaurant
-- isn't the reserved restaurant itself.
CREATE OR REPLACE FUNCTION check_tables_ownership()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(1)
        SELECT r.id, r.restaurant, t.restaurant
        FROM reservations r
            LEFT JOIN reservation_tables rt ON rt.reservation = r.id
            LEFT JOIN tables t ON t.id = rt.table
        WHERE r.restaurant != t.restaurant)
    THEN
        RAISE EXCEPTION 'Selected table(s) do not belong to the selected restaurant''s reservation';
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