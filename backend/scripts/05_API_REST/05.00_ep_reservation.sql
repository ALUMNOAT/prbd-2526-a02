DROP FUNCTION IF EXISTS get_restaurant_reservations_by_id(INT);
CREATE OR REPLACE FUNCTION get_restaurant_reservations_by_id(restaurant_id INT)
    RETURNS SETOF reservations AS
$$
BEGIN
    -- is a user currently connected ?
    -- PERFORM auth.check_logged();

    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.restaurant = restaurant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurant_reservations_by_id TO authenticated;



DROP FUNCTION IF EXISTS test_reservation(INT);
CREATE OR REPLACE FUNCTION test_reservation(reservation_id INT)
    RETURNS reservations AS
$$
BEGIN
    -- is a user currently connected ?
    -- PERFORM auth.check_logged();

    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.id = reservation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION test_reservation TO authenticated, anon;
