




CREATE OR REPLACE FUNCTION get_restaurant_by_id(id INT)
    RETURNS SETOF restaurants AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT *
        FROM restaurants rst
        WHERE rst.id = get_restaurant_by_id.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurant_by_id TO authenticated;



CREATE OR REPLACE FUNCTION get_restaurants_by_manager(user_id INT)
    RETURNS SETOF restaurants AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT *
        FROM restaurants rst
        LEFT JOIN restaurant_managers rstm ON rstm.restaurant = rst.id
        WHERE rstm.manager = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurant_by_id TO authenticated;