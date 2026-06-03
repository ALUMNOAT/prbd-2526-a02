DROP FUNCTION IF EXISTS edit_reservation(int, timestamp, int, text);

CREATE OR REPLACE FUNCTION edit_reservation(
    p_id int,
    p_datetime timestamp,
    p_guests int,
    p_special_requests text
) RETURNS void AS $$
BEGIN
    -- On met à jour la réservation.
    -- On ajoute une condition pour ne modifier que si la réservation n'est pas déjà 'cancelled' ou 'completed'
    UPDATE reservations
    SET
        datetime = p_datetime,
        number_of_guests = p_guests,
        special_requests = p_special_requests,
        status = 'pending' -- repasser en 'pending' pour re-validation
    WHERE id = p_id
      AND status NOT IN ('cancelled', 'completed');

    -- Vérification si la mise à jour a eu lieu
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Réservation introuvable ou statut ne permettant pas la modification (ID: %)', p_id;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.edit_reservation(int, timestamp, int, text) TO authenticated;