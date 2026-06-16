DROP FUNCTION IF EXISTS get_restaurant_by_id(INT);
CREATE OR REPLACE FUNCTION get_tables_by_reservations_id(reservation_id INT)
    RETURNS SETOF tables AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT t.*
        FROM tables t
                 LEFT JOIN reservation_tables rt ON rt."table" = t.id
        WHERE rt.reservation = reservation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_tables_by_reservations_id TO authenticated;
