/*
 (1) https://stackoverflow.com/questions/22423958/sql-function-return-type-table-vs-setof-records
 (2) https://stackoverflow.com/questions/36199437/how-to-access-record-elements-in-postgresql
 */

set search_path to public;

DROP FUNCTION get_reservation(INT);
CREATE OR REPLACE FUNCTION get_reservation(
    IN reservation_id INT)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM reservations r
    WHERE r.id = reservation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation id was not associated with any reservation';
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_table(INT);
CREATE OR REPLACE FUNCTION get_table(
    IN table_id INT)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM tables t
        WHERE t.id = table_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given table id was not associated with any table';
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_restaurant(INT);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN restaurant_id INT)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM restaurants r
        WHERE r.id = restaurant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given restaurant id was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_user(INT);
CREATE OR REPLACE FUNCTION get_user(
    IN user_id INT)
    RETURNS SETOF users AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM users u
        WHERE u.id = user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given user id was not associated with any user';
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_restaurant_services(INT);
CREATE OR REPLACE FUNCTION get_restaurant_services(
    IN restaurant_id INT)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM services s
        WHERE s.restaurant = restaurant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given restaurant id was not associated with any services';
    END IF;
END;
$$ LANGUAGE plpgsql;