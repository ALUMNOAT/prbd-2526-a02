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
