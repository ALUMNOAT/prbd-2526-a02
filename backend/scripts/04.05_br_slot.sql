-- ============================================================================
-- NETTOYAGE
-- ============================================================================
DROP TRIGGER IF EXISTS trigger_validate_reservation_tables_slot ON public.reservations;
DROP FUNCTION IF EXISTS public.check_slot() CASCADE;

-- ============================================================================
-- FONCTION DE VÉRIFICATION DU CRÉNEAU (BR-05)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.check_slot()
    RETURNS TRIGGER AS $$
DECLARE
    v_slot_duration INT;
    v_minute INT;
BEGIN
    -- 1. Récupération de la durée du slot définie pour ce restaurant
    SELECT slot_duration INTO v_slot_duration
    FROM public.restaurants -- Remplace par ta table de config restaurant si différente
    WHERE id = NEW.restaurant;

    -- Si aucune configuration de slot trouvée, on autorise par défaut ou on lève une erreur
    IF v_slot_duration IS NULL OR v_slot_duration = 0 THEN
        RETURN NEW;
    END IF;

    -- 2. Extraction des minutes de la date de réservation
    v_minute := EXTRACT(MINUTE FROM NEW.datetime);

    -- 3. Vérification du modulo
    IF (v_minute % v_slot_duration) <> 0 THEN
        RAISE EXCEPTION 'BR-05: La réservation doit respecter les créneaux du restaurant (multiple de % min).', v_slot_duration;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- ============================================================================
-- TRIGGER
-- ============================================================================
CREATE TRIGGER trigger_validate_reservation_tables_slot
    BEFORE INSERT OR UPDATE OF datetime ON public.reservations
    FOR EACH ROW
EXECUTE FUNCTION public.check_slot();