-- ============================================================================
-- NETTOYAGE STRICT DES ANCIENS TRIGGERS ET FONCTIONS (AVEC CASCADE)
-- ============================================================================
DROP TRIGGER IF EXISTS tgv_new_reservation_timing ON public.reservations;
DROP TRIGGER IF EXISTS tgv_update_reservation_timing ON public.reservations;
DROP TRIGGER IF EXISTS tgv_reservation_timing ON public.reservations; -- Nettoyage du nouveau trigger
DROP FUNCTION IF EXISTS public.check_new_reservation_timing();
DROP FUNCTION IF EXISTS public.check_update_reservation_timing();
DROP FUNCTION IF EXISTS public.check_reservation_service_hours() CASCADE; -- Ajout du CASCADE par sécurité

-- ============================================================================
-- FONCTION UNIQUE DE VÉRIFICATION DES HORAIRES (BR-04)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.check_reservation_service_hours()
    RETURNS TRIGGER AS $$
BEGIN
    -- La règle BR-04 cible : pending, confirmed et completed (On ignore 'cancelled')
    IF NEW.status IN ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type) THEN

        -- On vérifie s'il existe un service correspondant au jour et à l'heure
        IF NOT EXISTS (
            SELECT 1
            FROM public.services s
            WHERE s.restaurant = NEW.restaurant
              AND s.day_of_week = EXTRACT(ISODOW FROM NEW.datetime)
              AND NEW.datetime::time >= s.start_time
              AND NEW.datetime::time <= s.end_time
        ) THEN
            RAISE EXCEPTION 'BR-04: L''heure de la réservation ne correspond à aucun service ouvert pour ce jour de la semaine.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- ============================================================================
-- UNIQUE TRIGGER (BEFORE INSERT OR UPDATE)
-- ============================================================================
CREATE TRIGGER tgv_reservation_timing
    BEFORE INSERT OR UPDATE OF datetime, status ON public.reservations
    FOR EACH ROW
EXECUTE FUNCTION public.check_reservation_service_hours();