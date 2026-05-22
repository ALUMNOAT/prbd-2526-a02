/*
(1) https://www.postgresql.org/docs/current/functions-conditional.html
(2) https://www.postgresql.org/docs/9.0/sql-createconstraint.html
(3) https://www.postgresql.org/docs/current/sql-createtrigger.html
(4) https://www.postgresql.org/docs/current/sql-insert.html
 */


-- if the table belongs to the restaurant, all good
CREATE OR REPLACE FUNCTION check_table_ownership()
    RETURNS TRIGGER AS $$
DECLARE
    the_reservation reservations = get_reservation(NEW.reservation);
    the_table tables = get_table(NEW.table);
BEGIN
    IF (the_reservation.restaurant != the_table.restaurant) THEN
        RAISE EXCEPTION 'BR-03: Selected table do not belong to the restaurant of the reservation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- does the reservation table use the table from the correct restaurant ?
CREATE TRIGGER tgv_reservation_tables_ownership
    BEFORE INSERT -- we cannot update reservation_tables
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_table_ownership();

