-- CLEANUP
DROP TRIGGER IF EXISTS trg_br12_no_table_for_pending_canceled ON reservation_tables;
DROP FUNCTION IF EXISTS check_br12_reservation_status() CASCADE;

-- FUNCTION
CREATE OR REPLACE FUNCTION check_br12_reservation_status()
    RETURNS TRIGGER
AS $$
DECLARE
    current_status status_type;
BEGIN
    -- On récupère le statut actuel de la réservation concernée
    -- NEW fonctionne pour INSERT et UPDATE
    SELECT status INTO current_status
    FROM reservations
    WHERE id = NEW.reservation;

    -- Vérification de la règle BR-12
    IF current_status IN ('pending'::status_type, 'cancelled'::status_type) THEN
        RAISE EXCEPTION 'BR-12: Une réservation en attente ou annulée ne peut être associée à aucune table.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER
CREATE TRIGGER trg_br12_no_table_for_pending_canceled
    BEFORE INSERT OR UPDATE ON reservation_tables
    FOR EACH ROW EXECUTE FUNCTION check_br12_reservation_status();