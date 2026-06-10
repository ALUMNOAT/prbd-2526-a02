CREATE OR REPLACE VIEW managerState AS
SELECT u.id, u.full_name, u.role
FROM users u
LEFT JOIN restaurant_managers rstm ON rstm.manager = u.id
LEFT JOIN restaurants rst ON rst.id = rstm.restaurant;

SELECT * FROM managerState;



-- RESTAURANTS
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
        WHERE rstm.manager = manager_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION get_manager_restaurants TO authenticated;


-- SERVICES
DROP FUNCTION IF EXISTS get_manager_services(INT);
CREATE OR REPLACE FUNCTION get_manager_services(manager_id INT)
    RETURNS SETOF services AS
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
        SELECT s.*
        FROM services s
                 LEFT JOIN restaurant_managers rstm ON rstm.restaurant = s.restaurant
        WHERE rstm.manager = manager_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION get_manager_services TO authenticated;


-- RESERVATIONS
DROP FUNCTION IF EXISTS get_manager_reservations(INT);
CREATE OR REPLACE FUNCTION get_manager_reservations(manager_id INT)
    RETURNS SETOF reservations AS
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
        SELECT r.*
        FROM reservations r
                 LEFT JOIN restaurant_managers rstm ON rstm.restaurant = r.restaurant
        WHERE rstm.manager = manager_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION get_manager_reservations TO authenticated;



-- CLIENTS
DROP FUNCTION IF EXISTS get_manager_clients(INT);
CREATE OR REPLACE FUNCTION get_manager_clients(manager_id INT)
    RETURNS SETOF users AS
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
        SELECT DISTINCT u.*
        FROM users u
        LEFT JOIN reservations r ON r.client = u.id
        LEFT JOIN restaurant_managers rstm ON rstm.restaurant = r.restaurant
        WHERE rstm.manager = manager_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION get_manager_clients TO authenticated;