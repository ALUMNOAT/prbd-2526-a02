/*
 (1) https://neon.com/postgresql/plpgsql/plpgsql-function-parameters
 (2) https://stackoverflow.com/questions/36199437/how-to-access-record-elements-in-postgresql
 */

CREATE OR REPLACE FUNCTION check_reservation_schrodinger()
    RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type))
    AND EXISTS(      -- see doc(8)
        SELECT 1
        FROM reservations r
        LEFT JOIN services s ON s.restaurant = r.restaurant
        WHERE r.client = NEW.client
          AND r.datetime::date = NEW.datetime::date
          AND r.restaurant = NEW.restaurant
          AND r.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type)
          AND NEW.datetime::time >= get_service_time(r.id).start_t
          AND NEW.datetime::time <= get_service_time(r.id).end_t
    ) THEN
        RAISE EXCEPTION 'BR-13: This client already has a reservation ';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_reservation_schrodinger
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_schrodinger();


CREATE OR REPLACE FUNCTION get_service_time(reservation_id INT, OUT start_t TIME, OUT end_t TIME)
    RETURNS RECORD AS $$
BEGIN
    SELECT s.start_time, s.end_time INTO start_t, end_t
    FROM services s
    LEFT JOIN reservations r ON r.restaurant = s.restaurant
    WHERE r.id = reservation_id
    AND s.day_of_week = EXTRACT(ISODOW FROM r.datetime)
    AND r.datetime::time >= s.start_time AND r.datetime::time <= s.end_time;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'BR-13: The given reservation id was not associated with any service';
    END IF;
END;
$$ LANGUAGE plpgsql;