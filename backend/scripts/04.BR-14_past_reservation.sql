CREATE OR REPLACE FUNCTION check_past_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM system_time st, NEW
        WHERE NEW.datetime > st.simulated_time
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-14: You cannot make a reservation in the past';
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_past_reservation
    BEFORE INSERT OR UPDATE OF datetime
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_past_reservation();