CREATE OR REPLACE FUNCTION get_current_user()
    RETURNS SETOF users AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN QUERY
        SELECT *
        FROM users u
        WHERE u.id = auth.id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_current_user TO authenticated;