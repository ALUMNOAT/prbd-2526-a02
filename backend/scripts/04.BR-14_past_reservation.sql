/*
 (1) https://www.postgresql.org/docs/current/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL

 */

CREATE OR REPLACE FUNCTION check_past_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM system_time st, NEW
        WHERE NEW.datetime > COALESCE(st.simulated_time, current_timestamp(0))
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-14: You cannot make a reservation in the past';
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_past_reservation
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_past_reservation();