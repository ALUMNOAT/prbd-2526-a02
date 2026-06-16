-- ============================================================================
-- BR-08 : Alignement des créneaux et appartenance aux services
-- ============================================================================

CREATE OR REPLACE FUNCTION check_reservation_time_align_service_time()
    RETURNS TRIGGER AS $$
DECLARE
    v_slot_duration INT;
    v_start_minutes INT;
    v_reservation_minutes INT;
    v_service_exists BOOLEAN;
    v_res_time TIME := date_trunc('minute', NEW.datetime::time); -- ARRONDIE À LA MINUTE
BEGIN
    SELECT slot_duration INTO v_slot_duration
    FROM public.restaurants
    WHERE id = NEW.restaurant;

    -- 1. Alignement strict (Modulo sur les minutes depuis minuit)
    v_reservation_minutes := (EXTRACT(HOUR FROM v_res_time) * 60) + EXTRACT(MINUTE FROM v_res_time);

    IF (v_reservation_minutes % v_slot_duration) <> 0 THEN
        RAISE EXCEPTION 'BR-08: L''heure (%) n''est pas alignée sur le créneau de % min.', v_res_time, v_slot_duration;
    END IF;

    -- 2. Appartenance aux services (Comparaison textuelle ou par tranche de minutes)
    -- On s'assure que le service existe ET que l'heure est bien dans la plage
    SELECT EXISTS (
        SELECT 1
        FROM public.services s
        WHERE s.restaurant = NEW.restaurant
          AND s.day_of_week = EXTRACT(ISODOW FROM NEW.datetime)
          -- Comparaison sur la valeur arrondie à la minute
          AND v_res_time >= s.start_time
          AND v_res_time < s.end_time
    ) INTO v_service_exists;

    IF NOT v_service_exists THEN
        RAISE EXCEPTION 'BR-08: L''heure (%) est hors service.', v_res_time;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Suppression de l'ancien trigger si existant et création du nouveau
DROP TRIGGER IF EXISTS trigger_reservation_time_align_service_time ON public.reservations;

CREATE TRIGGER trigger_reservation_time_align_service_time
    BEFORE INSERT OR UPDATE ON public.reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_time_align_service_time();