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
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_restaurant_tables(INT);
CREATE OR REPLACE FUNCTION get_restaurant_tables(
    IN restaurant_id INT)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM tables t
        WHERE t.restaurant = restaurant_id;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_all_table_reservations(INT);
CREATE OR REPLACE FUNCTION get_all_table_reservations(
    IN table_id INT)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.reservation = r.id
        LEFT JOIN get_table(table_id) t ON t.id = rt."table";

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given restaurant id was not associated with any services';
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_restaurant_service_at_timestamp(INT, TIMESTAMP);
CREATE OR REPLACE FUNCTION get_restaurant_service_at_timestamp(
    IN restaurant_id INT,
    IN date_time TIMESTAMP)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.*
        FROM get_restaurant_services(restaurant_id) s
        WHERE EXTRACT(ISODOW FROM date_time) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
          AND date_time::time > s.start_time   -- see doc(6) for '::time' syntax
          AND date_time::time < s.end_time;

--     IF NOT FOUND THEN
--         RETURN NULL;
--     END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_all_restaurant_reservations(INT);
CREATE OR REPLACE FUNCTION get_all_restaurant_reservations(
    IN restaurant_id INT)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM get_restaurant(restaurant_id) rst
        LEFT JOIN reservations r ON r.restaurant = rst.id;

--     IF NOT FOUND THEN
--         RETURN NULL;
--     END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_all_restaurant_reservations_on_date(INT, DATE);
CREATE OR REPLACE FUNCTION get_all_restaurant_reservations_on_date(
    IN restaurant_id INT,
    IN selected_day DATE)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM get_restaurant(restaurant_id) rst
        LEFT JOIN reservations r ON r.restaurant = rst.id
        WHERE r.datetime::date = selected_day;

--     IF NOT FOUND THEN
--         RETURN NULL;
--     END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_reservations_from_table_and_date(INT, DATE);
CREATE OR REPLACE FUNCTION get_reservations_from_table_and_date(
    IN table_id INT,
    IN selected_day DATE)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM get_all_table_reservations(table_id) r
        WHERE r.datetime::date = selected_day;

END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_service_from_reservation(reservations);
CREATE OR REPLACE FUNCTION get_service_from_reservation(
    IN reservation reservations)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
    SELECT s.*
    FROM services s
    WHERE EXTRACT(ISODOW FROM reservation.datetime) = s.day_of_week     -- see doc(5) for 'ISODOW' keyword
      AND reservation.datetime::time >= s.start_time   -- see doc(6) for '::time' syntax
      AND reservation.datetime::time <= s.end_time;
END;
$$ LANGUAGE plpgsql;