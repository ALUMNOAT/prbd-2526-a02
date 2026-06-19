-- 1. On garde la même fonction, mais on ajoute un petit garde-fou pour le NULL
CREATE OR REPLACE FUNCTION check_br12_reservation_status()
    RETURNS TRIGGER AS $$
DECLARE
    v_status status_type;
BEGIN
    -- On cherche dans la table reservations
    SELECT status INTO v_status
    FROM reservations
    WHERE id = NEW.reservation;

    -- Si la réservation n'existe pas encore (insérée dans la même transaction),
    -- on ne peut pas valider. Mais comme c'est DEFERRED, elle existera à la fin !
    IF v_status IS NULL THEN
        RETURN NEW; -- On attend le COMMIT
    END IF;

    IF v_status IN ('pending'::status_type, 'cancelled'::status_type) THEN
        RAISE EXCEPTION 'BR-12: Une réservation en attente ou annulée ne peut être associée à aucune table.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. LE TRIGGER MAGIQUE (Constraint Trigger)
DROP TRIGGER IF EXISTS trg_br12_no_table_for_pending_canceled ON reservation_tables;

CREATE CONSTRAINT TRIGGER trg_br12_no_table_for_pending_canceled
    AFTER INSERT OR UPDATE ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_br12_reservation_status();
