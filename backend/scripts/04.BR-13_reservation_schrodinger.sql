CREATE OR REPLACE FUNCTION check_reservation_schrodinger()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(8)
        SELECT 1
        FROM NEW
        WHERE NEW.status = 'pending'::status_type
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-09: A new reservation can only be of status ''pending''';
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_reservation_schrodinger
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_schrodinger();


CREATE OR REPLACE FUNCTION get_service_id_or_null(r_id INT)
    RETURNS INTEGER AS $$
BEGIN

END;
$$ LANGUAGE plpgsql;