-- ============================================================================
-- NETTOYAGE
-- ============================================================================
DROP TRIGGER IF EXISTS trg_br14_reservation_temporal ON public.reservations;
DROP FUNCTION IF EXISTS public.get_current_logic_time();
DROP FUNCTION IF EXISTS public.check_br14_reservation_temporal() CASCADE;

-- ============================================================================
-- 1. FONCTION : RÉCUPÉRATION DU TEMPS LOGIQUE
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_current_logic_time()
    RETURNS TIMESTAMP AS $$
DECLARE
    v_simulated_time TIMESTAMP;
BEGIN
    SELECT simulated_time INTO v_simulated_time
    FROM public.system_time
    LIMIT 1;

    IF v_simulated_time IS NOT NULL THEN
        RETURN v_simulated_time;
    END IF;

    RETURN CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. FONCTION : TRIGGER DE VÉRIFICATION TEMPORELLE
-- ============================================================================
CREATE OR REPLACE FUNCTION public.check_br14_reservation_temporal()
    RETURNS TRIGGER AS $$
DECLARE
    now_logic TIMESTAMP;
BEGIN
    now_logic := public.get_current_logic_time();

    -- BR-14 : Interdiction de créer dans le passé (INSERT uniquement)
    IF (TG_OP = 'INSERT') THEN
        IF NEW.datetime < now_logic THEN
            RAISE EXCEPTION 'BR-14: Une réservation ne peut pas être créée dans le passé.';
        END IF;
    END IF;

    -- Règle de transition : confirmed -> pending autorisée uniquement dans le futur
    IF (TG_OP = 'UPDATE') THEN
        IF OLD.status = 'confirmed'::public.status_type AND NEW.status = 'pending'::public.status_type THEN
            IF OLD.datetime <= now_logic THEN
                RAISE EXCEPTION 'Transition impossible : Vous ne pouvez repasser en "pending" qu''une réservation future.';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. CRÉATION DU TRIGGER
-- ============================================================================
CREATE TRIGGER trg_br14_reservation_temporal
    BEFORE INSERT OR UPDATE ON public.reservations
    FOR EACH ROW
EXECUTE FUNCTION public.check_br14_reservation_temporal();