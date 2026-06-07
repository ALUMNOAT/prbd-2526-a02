



DROP FUNCTION IF EXISTS get_restaurant_by_id(INT);
CREATE OR REPLACE FUNCTION get_restaurant_by_id(restaurant_id INT)
    RETURNS restaurants AS
$$
DECLARE
    restaurant restaurants;
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    SELECT * FROM restaurants rst
    WHERE rst.id = restaurant_id
    LIMIT 1
    INTO restaurant;

    RETURN restaurant;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurant_by_id TO authenticated;



CREATE OR REPLACE FUNCTION get_restaurants_by_current_manager()
    RETURNS SETOF restaurants AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT rst.*
        FROM restaurants rst
        LEFT JOIN restaurant_managers rstm ON rstm.restaurant = rst.id
        WHERE rstm.manager = auth.id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurants_by_current_manager TO authenticated;
