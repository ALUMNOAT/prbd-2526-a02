/*
 (1) https://www.postgresql.org/docs/current/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL

 */

CREATE OR REPLACE FUNCTION check_past_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.datetime < get_time() THEN
        RAISE EXCEPTION 'BR-14: You cannot make a reservation in the past';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_past_reservation
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_past_reservation();