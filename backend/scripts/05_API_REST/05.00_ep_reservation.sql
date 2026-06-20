set search_path to public;


DROP FUNCTION IF EXISTS get_restaurant_reservations_by_id(INT);
CREATE OR REPLACE FUNCTION get_restaurant_reservations_by_id(restaurant_id INT)
    RETURNS SETOF reservations AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.restaurant = restaurant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurant_reservations_by_id TO authenticated;


DROP FUNCTION IF EXISTS get_reservation_by_id(INT);
CREATE OR REPLACE FUNCTION get_reservation_by_id(reservation_id INT)
    RETURNS reservations AS
$$
DECLARE
    reservation reservations;
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    SELECT * FROM reservations r
    WHERE r.id = reservation_id
    LIMIT 1
    INTO reservation;

    RETURN reservation;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_reservation_by_id TO authenticated;





DROP FUNCTION IF EXISTS complete_reservation(INT);
CREATE OR REPLACE FUNCTION complete_reservation(id INT)
    RETURNS void AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    UPDATE reservations r SET status = 'completed'
    WHERE r.id = complete_reservation.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION complete_reservation TO manager;





DROP FUNCTION IF EXISTS cancel_reservation(INT);
CREATE OR REPLACE FUNCTION cancel_reservation(id INT)
    RETURNS void AS
$$
BEGIN
    --TODO: vérifier que ce soit le manager qui cancel !!!
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    UPDATE reservations r SET status = 'cancelled'
    WHERE r.id = cancel_reservation.id;
    --RETURNING INTO (variable);

    --RETURN (variable);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION cancel_reservation TO manager;



--https://stackoverflow.com/questions/20815028/how-do-i-insert-multiple-values-into-a-postgresql-table-at-once#20820950
--https://stackoverflow.com/questions/12956069/postgres-function-with-list-argument-and-in-clause
DROP FUNCTION IF EXISTS confirm_reservation(INT, INT[]);
CREATE OR REPLACE FUNCTION confirm_reservation(reservation_id INT, tables_id INT[])
    RETURNS void AS
$$
BEGIN
    --TODO: vérifier que ce soit le manager qui confirm !!!
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    INSERT INTO reservation_tables
    VALUES (reservation_id, unnest(tables_id));

    UPDATE reservations r SET status = 'confirmed'
    WHERE r.id = reservation_id;


    --RETURNING INTO (variable);

    --RETURN (variable);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION confirm_reservation TO manager;


DROP FUNCTION IF EXISTS add_reservation_table(INT, INT);
CREATE OR REPLACE FUNCTION add_reservation_table(reservation_id INT, table_id INT)
    RETURNS void AS
$$
BEGIN
    --TODO: vérifier que ce soit le manager qui confirm !!!
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    INSERT INTO reservation_tables
    VALUES (reservation_id, table_id);

    --RETURNING INTO (variable);

    --RETURN (variable);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION add_reservation_table TO manager;

DROP FUNCTION IF EXISTS setup_vip(INT);
CREATE OR REPLACE FUNCTION setup_vip(id INT)
    RETURNS void AS
$$
BEGIN
    --TODO: vérifier que ce soit le manager qui cancel !!!
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    UPDATE reservations r
    SET is_vip = NOT is_vip
    WHERE r.id = setup_vip.id;
    --RETURNING INTO (variable);

    --RETURN (variable);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION setup_vip TO manager;


/*
set search_path to auth;
SELECT auth.login_for_test('bepenelle@epfc.eu');
SELECT confirm_reservation(2, array[4, 5]);
