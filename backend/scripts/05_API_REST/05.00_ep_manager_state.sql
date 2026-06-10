CREATE OR REPLACE VIEW managerState AS
SELECT u.id, u.full_name, u.role
FROM users u
LEFT JOIN restaurant_managers rstm ON rstm.manager = u.id
LEFT JOIN restaurants rst ON rst.id = rstm.restaurant;

SELECT * FROM managerState;


DROP FUNCTION IF EXISTS get_manager_restaurants(INT);
CREATE OR REPLACE FUNCTION get_manager_restaurants(manager_id INT)
    RETURNS SETOF restaurants AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();
    -- is the user a manager ?
    IF (auth.role() != 'manager'::role_type) THEN
        RAISE EXCEPTION 'User id ''%'' does not have access to this resource', manager_id;
    -- is the user the one currently connected ?
    ELSEIF (auth.id() != manager_id) THEN
        RAISE EXCEPTION 'User id ''%'' is not connected', manager_id;
    END IF;

    RETURN QUERY
        SELECT rst.*
        FROM restaurants rst
        LEFT JOIN restaurant_managers rstm ON rstm.restaurant = rst.id
        WHERE rstm.manager = auth.id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_manager_restaurants TO authenticated;