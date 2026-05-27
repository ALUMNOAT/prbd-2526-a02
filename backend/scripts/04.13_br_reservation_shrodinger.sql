CREATE OR REPLACE FUNCTION check_reservation_schrodinger()
    RETURNS TRIGGER AS $$
BEGIN
    -- On vérifie si une réservation existe pour ce client, au même moment,
    -- sans être annulée ('cancelled').
    IF EXISTS (
        SELECT 1
        FROM public.reservations r
        WHERE r.client = NEW.client
          AND r.datetime = NEW.datetime
          AND r.status != 'cancelled'::status_type
          AND r.id != NEW.id -- On exclut la ligne en cours de traitement (pour les updates)
    ) THEN
        RAISE EXCEPTION 'BR-13: Ce client a déjà une réservation active sur ce créneau.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tgv_reservation_schrodinger ON reservations;

CREATE TRIGGER tgv_reservation_schrodinger
    BEFORE INSERT OR UPDATE OF datetime, client, status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_schrodinger();