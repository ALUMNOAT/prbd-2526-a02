/*
 (1) https://stackoverflow.com/questions/50962700/postgresql-checking-for-new-and-old-in-a-function-for-a-trigger
 (2) https://www.postgresql.org/docs/current/functions-string.html
 (3) https://www.postgresql.org/docs/current/plpgsql-errors-and-messages.html
 */

CREATE OR REPLACE FUNCTION check_new_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != 'pending'::status_type THEN
        RAISE EXCEPTION 'BR-09: A new reservation can only be of status ''pending''';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_new_reservation
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_new_reservation();


CREATE OR REPLACE FUNCTION check_update_reservation()
    RETURNS TRIGGER AS $$
DECLARE
    date_time TIMESTAMP = COALESCE(
            (SELECT st.simulated_time FROM system_time st),
            current_timestamp(0));
BEGIN
    IF (OLD.status = 'confirmed'::status_type AND NEW.status = 'pending'::status_type)
    AND (OLD.datetime > date_time)
    THEN
        RAISE EXCEPTION 'BR-09: You can only edit a reservation that''s set in the future';
    ELSEIF
           (OLD.status = 'pending'::status_type AND NEW.status = 'confirmed'::status_type)
        OR (OLD.status = 'pending'::status_type AND NEW.status = 'cancelled'::status_type)
        OR (OLD.status = 'confirmed'::status_type AND NEW.status = 'completed'::status_type)
        OR (OLD.status = 'confirmed'::status_type AND NEW.status = 'cancelled'::status_type)
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-09: you cannot perform this status transition % -> %', OLD.status, NEW.status;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_update_reservation
    BEFORE UPDATE OF status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_update_reservation();