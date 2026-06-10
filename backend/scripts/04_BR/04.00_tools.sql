/*
 (1) https://stackoverflow.com/questions/22423958/sql-function-return-type-table-vs-setof-records
 (2) https://stackoverflow.com/questions/36199437/how-to-access-record-elements-in-postgresql
 (3) https://stackoverflow.com/questions/9614922/does-the-join-order-matter-in-sql
 */

set search_path to public;

DROP FUNCTION IF EXISTS get_restaurant(INT);
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


DROP FUNCTION IF EXISTS get_reservations(restaurants);
CREATE OR REPLACE FUNCTION get_reservations(
    IN rst restaurants)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.restaurant = rst.id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS total_tables_capacity_allocated(reservations);
CREATE OR REPLACE FUNCTION total_tables_capacity_allocated(IN given_reservation reservations) RETURNS INT AS $$
SELECT COALESCE(SUM(t.capacity), 0)
FROM tables t
         LEFT JOIN reservation_tables rt ON rt."table" = t.id
         LEFT JOIN reservations r ON r.id = rt.reservation
WHERE r.id = given_reservation.id
$$ LANGUAGE SQL;

-- ############
-- RESERVATIONS
-- ############
DROP FUNCTION IF EXISTS get_reservation(INT);
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

DROP FUNCTION IF EXISTS get_reservation(reservation_tables);
CREATE OR REPLACE FUNCTION get_reservation(
    IN rt reservation_tables)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
    SELECT r.* FROM reservations r
    WHERE r.id = rt.reservation;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation table was not associated with any reservation';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_reservations_from_restaurant_id(INT);
CREATE OR REPLACE FUNCTION get_reservations_from_restaurant_id(
    IN rst_id INT)
    RETURNS SETOF reservations AS $$
    SELECT r.*
    FROM reservations r
    WHERE r.restaurant = rst_id;
$$ LANGUAGE SQL;

SELECT total_tables_capacity_allocated(get_reservations(get_restaurant(1)));


DROP FUNCTION IF EXISTS get_reservations(users);
CREATE OR REPLACE FUNCTION get_reservations(
    IN the_client users)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.client = the_client.id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_reservations(restaurants);
CREATE OR REPLACE FUNCTION get_reservations(
    IN rst restaurants)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.restaurant = rst.id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_reservations(reservation_tables);
CREATE OR REPLACE FUNCTION get_reservations(
    IN given_rt reservation_tables)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.* FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.reservation = r.id
        WHERE rt."table" = given_rt."table";

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation table''s table was not associated with any reservation';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_reservations(tables);
CREATE OR REPLACE FUNCTION get_reservations(
    IN t tables)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.reservation = r.id
        WHERE rt."table" = t.id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_all_restaurant_reservations_on_date(INT, DATE);
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

DROP FUNCTION IF EXISTS get_reservations_from_table_and_date(INT, DATE);
CREATE OR REPLACE FUNCTION get_reservations_from_table_and_date(
    IN table_id INT,
    IN selected_day DATE)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
        SELECT r.*
        FROM get_table_reservations(table_id) r
        WHERE r.datetime::date = selected_day;

END;
$$ LANGUAGE plpgsql;


-- ###########
-- RESTAURANTS
-- ###########
DROP FUNCTION IF EXISTS get_restaurant(INT);
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

DROP FUNCTION IF EXISTS get_restaurant(reservations);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN r reservations)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT rst.* FROM restaurants rst
        WHERE rst.id = r.restaurant;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_restaurant(reservation_tables);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN rt reservation_tables)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT rst.*
        FROM restaurants rst
        LEFT JOIN reservations r ON r.restaurant = rst.id
        LEFT JOIN rt ON rt.reservation = r.id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation table was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_restaurant(tables);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN t tables)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT rst.* FROM restaurants rst
        WHERE rst.id = t.restaurant;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given table was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_restaurant(services);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN s services)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT rst.* FROM restaurants rst
        WHERE rst.id = s.restaurant;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given service was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_restaurant(restaurant_managers);
CREATE OR REPLACE FUNCTION get_restaurant(
    IN rm restaurant_managers)
    RETURNS SETOF restaurants AS $$
BEGIN
    RETURN QUERY
        SELECT rst.* FROM restaurants rst
        WHERE rst.id = rm.restaurant;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given restaurant manager was not associated with any restaurant';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ########
-- SERVICES
-- ########
DROP FUNCTION IF EXISTS get_service(INT);
CREATE OR REPLACE FUNCTION get_service(
    IN service_id INT)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM services s
        WHERE s.id = service_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given service id was not associated with any service';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_service(restaurants, TIMESTAMP);
CREATE OR REPLACE FUNCTION get_service(
    IN r restaurants,
    IN date_time TIMESTAMP)
RETURNS SETOF services AS $$
    SELECT s.* FROM services s
    WHERE s.restaurant = r.id
      AND s.day_of_week = EXTRACT(ISODOW FROM date_time)
      AND s.start_time <= date_time::time
      AND s.end_time >= date_time::time;;
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS get_service(reservations);
CREATE OR REPLACE FUNCTION get_service(
    IN r reservations)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM services s
        WHERE s.restaurant = r.restaurant
          AND s.day_of_week = EXTRACT(ISODOW FROM r.datetime)
          AND s.start_time <= r.datetime::time
          AND s.end_time >= r.datetime::time;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_services(TIMESTAMP);
CREATE OR REPLACE FUNCTION get_services(
    IN date_time TIMESTAMP)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM services s
        WHERE s.day_of_week = EXTRACT(ISODOW FROM date_time)
          AND s.start_time <= date_time::time
          AND s.end_time >= date_time::time;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_services(restaurants);
CREATE OR REPLACE FUNCTION get_services(
    IN rst restaurants)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM services s
        WHERE s.restaurant = rst.id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_services(reservations);
CREATE OR REPLACE FUNCTION get_services(
    IN r reservations)
    RETURNS SETOF services AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM services s
        WHERE s.restaurant = r.restaurant
          AND s.day_of_week = EXTRACT(ISODOW FROM r.datetime)
          AND s.start_time <= r.datetime::time
          AND s.end_time >= r.datetime::time;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_services(users);
CREATE OR REPLACE FUNCTION get_services(IN the_user users) RETURNS SETOF services AS $$
    SELECT s.*
    FROM reservations r
    LEFT JOIN services s ON s.restaurant = r.restaurant
    WHERE r.client = the_user.id
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS get_restaurant_service_at_timestamp(INT, TIMESTAMP);
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
END;
$$ LANGUAGE plpgsql;


-- ###########
-- SYSTEM TIME
-- ###########
DROP FUNCTION IF EXISTS get_time();
CREATE OR REPLACE FUNCTION get_time() RETURNS TIMESTAMP AS $$
    SELECT COALESCE(st.simulated_time, current_timestamp(0))
    FROM system_time st;
$$ LANGUAGE SQL;


-- ######
-- TABLES
-- ######
DROP FUNCTION IF EXISTS get_table(INT);
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

DROP FUNCTION IF EXISTS get_table(reservation_tables);
CREATE OR REPLACE FUNCTION get_table(
    IN rt reservation_tables)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT t.* FROM tables t
        WHERE t.id = rt."table";

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tools: The given reservation table was not associated with any table';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_tables(reservation_tables);
CREATE OR REPLACE FUNCTION get_tables(
    IN given_rt reservation_tables)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT t.*
        FROM tables t
        LEFT JOIN reservation_tables rt ON rt."table" = t.id
        WHERE rt.reservation = given_rt.reservation;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_tables(reservations);
CREATE OR REPLACE FUNCTION get_tables(
    IN r reservations)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT t.* FROM tables t
        LEFT JOIN reservation_tables rt ON rt."table" = t.id
        LEFT JOIN r ON r.id = rt.reservation;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_tables(restaurants);
CREATE OR REPLACE FUNCTION get_tables(
    IN r restaurants)
    RETURNS SETOF tables AS $$
BEGIN
    RETURN QUERY
        SELECT t.* FROM tables t
        WHERE t.restaurant = r.id;
END;
$$ LANGUAGE plpgsql;


-- #####
-- USERS
-- #####
DROP FUNCTION IF EXISTS get_user(INT);
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


-- #######
-- BOOLEAN
-- #######
DROP FUNCTION IF EXISTS is_same_service_same_day(reservations, reservations);
CREATE OR REPLACE FUNCTION is_same_service_same_day(
    IN r1 reservations,
    IN r2 reservations)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN
        (r1.datetime::date = r2.datetime::date)
        AND EXISTS(
            SELECT get_service(r1)
            INTERSECT
            SELECT get_service(r2)
        );
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS is_same_service_same_day(reservations, restaurants, TIMESTAMP);
CREATE OR REPLACE FUNCTION is_same_service_same_day(
    IN the_reservation reservations,
    IN the_restaurant restaurants,
    IN date_time TIMESTAMP)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN
        (the_reservation.datetime::date = date_time::date)
        AND EXISTS(
            SELECT get_service(the_reservation)
            INTERSECT
            SELECT get_service(the_restaurant, date_time)
        );
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS is_within_service(TIMESTAMP, services);
CREATE OR REPLACE FUNCTION is_within_service(IN datetime TIMESTAMP, IN s services) RETURNS BOOLEAN AS $$
    SELECT
        EXTRACT(ISODOW FROM datetime) = s.day_of_week
    AND datetime::time >= s.start_time
    AND datetime::time <= s.end_time
$$ LANGUAGE SQL;


-- #######
-- NUMBERS
-- #######
-- doc(N-1) https://stackoverflow.com/questions/24755468/language-sql-vs-language-plpgsql-in-postgresql-functions

DROP FUNCTION IF EXISTS total_tables_capacity(tables);
CREATE OR REPLACE FUNCTION total_tables_capacity(IN t tables) RETURNS INT AS $$
    SELECT COALESCE(SUM(t.capacity), 0)
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS total_tables_capacity_allocated(reservations);
CREATE OR REPLACE FUNCTION total_tables_capacity_allocated(IN given_reservation reservations) RETURNS INT AS $$
    SELECT COALESCE(SUM(t.capacity), 0)
    FROM tables t
    LEFT JOIN reservation_tables rt ON rt."table" = t.id
    LEFT JOIN reservations r ON r.id = rt.reservation
    WHERE r.id = given_reservation.id
$$ LANGUAGE SQL;