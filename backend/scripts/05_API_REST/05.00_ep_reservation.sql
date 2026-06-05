CREATE OR REPLACE FUNCTION get_restaurant_reservations_by_id(id INT)
    RETURNS SETOF reservations AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT r.*
        FROM reservations r
        WHERE r.restaurant = get_restaurant_reservations_by_id.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurants_by_current_manager TO authenticated;
