DROP FUNCTION IF EXISTS get_available_tables_for_reservation(INT);
/*CREATE OR REPLACE FUNCTION get_available_tables_for_reservation(reservation_id INT)
    RETURNS SETOF tables AS
$$
DECLARE

BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    IF cast(auth.role() != 'manager' as role_type) THEN
        RETURN null;
    END IF;

    RETURN QUERY
        SELECT t.*
        FROM tables t
        WHERE t.restaurant = ;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_restaurants_by_current_manager TO authenticated;*/