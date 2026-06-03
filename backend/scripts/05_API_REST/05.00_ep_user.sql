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

CREATE OR REPLACE FUNCTION test_api()
    RETURNS int AS
$$
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    RETURN 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION test_api TO authenticated;
GRANT EXECUTE ON FUNCTION test_api TO anon;