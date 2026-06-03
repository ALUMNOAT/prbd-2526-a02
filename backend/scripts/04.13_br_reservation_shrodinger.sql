CREATE OR REPLACE FUNCTION check_reservation_schrodinger()
    RETURNS TRIGGER AS $$
DECLARE
    v_service_id_new INT;
BEGIN
    -- 1. Identifier le service de la nouvelle réservation
    -- SI C'EST UNE ANNULATION, ON SORT IMMÉDIATEMENT
    -- Si tu passes le status à 'cancelled', le trigger n'a pas besoin de vérifier les conflits
    IF (TG_OP = 'UPDATE' AND NEW.status = 'cancelled'::status_type) THEN
        RETURN NEW;
    END IF;
    SELECT id INTO v_service_id_new
    FROM public.services s
    WHERE s.restaurant = NEW.restaurant
      AND s.day_of_week = EXTRACT(ISODOW FROM NEW.datetime)
      AND NEW.datetime::time >= s.start_time
      AND NEW.datetime::time < s.end_time;

    -- 2. Chercher un conflit : même client, même jour, même service, statut non-annulé
    IF EXISTS (
        SELECT 1
        FROM public.reservations r
                 JOIN public.services s_old ON s_old.restaurant = r.restaurant
        WHERE r.client = NEW.client
          AND r.id != NEW.id
          AND r.status != 'cancelled'::status_type
          -- Même jour
          AND EXTRACT(ISODOW FROM r.datetime) = EXTRACT(ISODOW FROM NEW.datetime)
          -- Même service (on compare les start_time pour identifier le service)
          AND s_old.day_of_week = EXTRACT(ISODOW FROM r.datetime)
          AND r.datetime::time >= s_old.start_time
          AND r.datetime::time < s_old.end_time
          AND s_old.id = v_service_id_new
    ) THEN
        RAISE EXCEPTION 'BR-13: Un client ne peut pas avoir deux réservations pour le même service.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;