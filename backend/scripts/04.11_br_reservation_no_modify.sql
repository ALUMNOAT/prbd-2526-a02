-- NETTOYAGE --
DROP TRIGGER IF EXISTS trg_reservation_status_no_modify ON reservations;
DROP FUNCTION IF EXISTS reservation_status_no_modify();

-- CREATION FONCTION --
CREATE OR REPLACE FUNCTION reservation_status_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IN ('cancelled'::status_type, 'completed'::status_type) THEN
        RAISE EXCEPTION 'BR-11: Une réservation terminée ou annulée ne peut pas être modifiée.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATION TRIGGER --
CREATE TRIGGER trg_reservation_status_no_modify
    BEFORE UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION reservation_status_no_modify();