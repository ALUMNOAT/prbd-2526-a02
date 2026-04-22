-- Nettoyage
DROP TRIGGER IF EXISTS trigger_reservation_time_align_service_time ON reservations;
DROP FUNCTION IF EXISTS check_reservation_time_align_service_time();

-- Fonction de vérification
CREATE OR REPLACE FUNCTION check_reservation_time_align_service_time()
RETURNS TRIGGER AS $$
DECLARE
    v_service_exists BOOLEAN;
BEGIN
    -- On vérifie s'il existe un service qui match :
    -- 1. Le même restaurant (NEW.restaurant)
    -- 2. Le même jour de la semaine (ISODOW : 1=Lundi, 7=Dimanche)
    -- 3. Le créneau horaire (entre start_time et end_time)
    SELECT EXISTS (
        SELECT 1
        FROM services
        WHERE services.restaurant = NEW.restaurant
          AND services.day_of_week = EXTRACT(ISODOW FROM NEW.datetime)
          AND NEW.datetime::time >= services.start_time
          AND NEW.datetime::time <= services.end_time
    ) INTO v_service_exists;

    -- Si aucun service ne correspond, on bloque l'insertion/modification
    IF NOT v_service_exists THEN
        RAISE EXCEPTION 'BR-08: L''heure de réservation (%) n''est pas incluse dans les services du restaurant #% pour ce jour de la semaine (%).',
            NEW.datetime::time, NEW.restaurant, EXTRACT(ISODOW FROM NEW.datetime);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Application du trigger
CREATE TRIGGER trigger_reservation_time_align_service_time
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION check_reservation_time_align_service_time();