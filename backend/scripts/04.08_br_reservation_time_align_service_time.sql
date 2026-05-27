-- ============================================================================
-- BR-08 : Alignement des créneaux et appartenance aux services
-- ============================================================================

CREATE OR REPLACE FUNCTION check_reservation_time_align_service_time()
    RETURNS TRIGGER AS $$
DECLARE
    v_slot_duration INT;
    v_minutes_since_midnight INT;
    v_service_exists BOOLEAN;
BEGIN
    -- 1. Récupérer la durée de créneau du restaurant
    SELECT slot_duration INTO v_slot_duration
    FROM public.restaurants
    WHERE id = NEW.restaurant;

    -- 2. Vérifier l'alignement sur les créneaux (Multiple de slot_duration)
    v_minutes_since_midnight := (EXTRACT(HOUR FROM NEW.datetime::time) * 60)
        + EXTRACT(MINUTE FROM NEW.datetime::time);

    IF (v_minutes_since_midnight % v_slot_duration) <> 0 THEN
        RAISE EXCEPTION 'BR-08: L''heure de réservation (%) n''est pas alignée sur le créneau de % minutes.',
            NEW.datetime::time, v_slot_duration;
    END IF;

    -- 3. Vérifier l'appartenance aux services
    SELECT EXISTS (
        SELECT 1
        FROM public.services s
        WHERE s.restaurant = NEW.restaurant
          AND s.day_of_week = EXTRACT(ISODOW FROM NEW.datetime)
          AND NEW.datetime::time >= s.start_time
          AND NEW.datetime::time < s.end_time
    ) INTO v_service_exists;

    IF NOT v_service_exists THEN
        RAISE EXCEPTION 'BR-08: L''heure de réservation (%) n''est pas incluse dans un service actif.',
            NEW.datetime::time;
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