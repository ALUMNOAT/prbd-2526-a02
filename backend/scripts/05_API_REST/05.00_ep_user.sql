DROP FUNCTION IF EXISTS get_current_user();
CREATE OR REPLACE FUNCTION get_current_user()
    RETURNS users AS
$$
DECLARE
    current_user users;
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    SELECT *
    FROM users u
    WHERE u.id = auth.id()
    LIMIT 1
    INTO current_user;

    RETURN current_user;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_current_user TO authenticated;





DROP FUNCTION IF EXISTS get_user_by_id(id INT);
CREATE OR REPLACE FUNCTION get_user_by_id(id INT)
    RETURNS users AS
$$
DECLARE
    user users;
BEGIN
    -- is a user currently connected ?
    PERFORM auth.check_logged();

    SELECT * FROM users u
    WHERE u.id = get_user_by_id.id
    LIMIT 1
    INTO user;

    RETURN user;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_user_by_id TO authenticated;






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






set search_path to "prbd-2526-a02", public;
ALTER SYSTEM SET logging_collector = 'on';
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();

SELECT pg_current_logfile();