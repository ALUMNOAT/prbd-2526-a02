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

/*
-- if more guests come to a reservation, do we have enough table seats ?
DROP TRIGGER IF EXISTS tgv_reservations_capacity ON reservations;
CREATE TRIGGER tgv_reservations_capacity
    AFTER INSERT OR UPDATE OF number_of_guests, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();
 */

DROP TRIGGER IF EXISTS tgv_reservation_tables_capacity ON reservation_tables;
-- if we remove reservation tables, we first need to check that the
-- reservation itself was deleted which changes the status to "cancelled",
-- which doesn't trigger check_guest_table_capacity())
-- CONSTRAINT because it is deferred. see doc(2)
CREATE CONSTRAINT TRIGGER tgv_reservation_tables_capacity
    AFTER DELETE
    ON reservation_tables
    -- deferred because reservation_tables is "delete cascade"-linked to reservations
    -- therefore it waits for the reservations to update first before executing this trigger
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();

/*
DROP TRIGGER IF EXISTS tgv_tables_capacity ON tables;
-- if we downsize a table, or delete a table, do we still have enough table seats ?
CREATE TRIGGER tgv_tables_capacity
    AFTER UPDATE OF capacity OR DELETE
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_guest_table_capacity();
 */




-- ############
-- RESERVATIONS
-- ############

CREATE OR REPLACE FUNCTION check_reservation_table_capacity()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('confirmed'::status_type, 'completed'::status_type)
    AND NEW.number_of_guests > (
        SELECT SUM(t.capacity)
        FROM tables t
        LEFT JOIN reservation_tables rt ON rt."table" = t.id
        WHERE rt.reservation = NEW.id
    ) THEN
        RAISE EXCEPTION 'BR-02 : Too many guests. Table capacity not suitable';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

DROP TRIGGER IF EXISTS tgv_reservation_table_capacity ON reservations;
CREATE TRIGGER tgv_reservation_table_capacity
    BEFORE INSERT OR UPDATE OF number_of_guests, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_table_capacity();

-- ##################
-- RESERVATION TABLES
-- ##################

-- ######
-- TABLES
-- ######

-- doc(99) https://sqldbaschool.com/course/learning-sql-tutorial-for-beginners/lessons/ternary-operator-in-sql/
-- doc(98) https://dataschool.com/learn-sql/conditional-logic/
CREATE OR REPLACE FUNCTION check_capacity_on_table_update()
    RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.capacity < OLD.capacity)
    AND EXISTS (
        SELECT 1
        FROM reservations r
            LEFT JOIN reservation_tables rt ON rt.reservation = r.id
            LEFT JOIN tables t ON t.id = rt."table"
        WHERE t.id = OLD.id
        AND r.status IN ('confirmed'::status_type, 'completed'::status_type)
        GROUP BY r.id, r.number_of_guests
        HAVING r.number_of_guests > (SUM(t.capacity) + NEW.capacity - OLD.capacity)
    ) THEN
    RAISE EXCEPTION
        'BR-02 : You cannot reduced this reserved table''s capacity, otherwise guests would sit on the floor';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

DROP TRIGGER IF EXISTS tgv_capacity_on_table_update ON tables;
CREATE TRIGGER tgv_capacity_on_table_update
    BEFORE UPDATE OF capacity
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_capacity_on_table_update();


-- doc(99) https://sqldbaschool.com/course/learning-sql-tutorial-for-beginners/lessons/ternary-operator-in-sql/
-- doc(98) https://dataschool.com/learn-sql/conditional-logic/
CREATE OR REPLACE FUNCTION check_capacity_on_table_delete()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM reservations r
            LEFT JOIN reservation_tables rt ON rt.reservation = r.id
            LEFT JOIN tables t ON t.id = rt."table"
        WHERE t.id = OLD.id
          AND r.status IN ('confirmed'::status_type, 'completed'::status_type)
        GROUP BY r.id, r.number_of_guests
        HAVING r.number_of_guests > (SUM(t.capacity) - OLD.capacity)
    ) THEN
        RAISE EXCEPTION 'BR-02 : You cannot delete this reserved table, otherwise guests would sit on the floor';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql security definer;

DROP TRIGGER IF EXISTS tgv_capacity_on_table_delete ON tables;
CREATE TRIGGER tgv_capacity_on_table_delete
    BEFORE DELETE
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_capacity_on_table_delete();
