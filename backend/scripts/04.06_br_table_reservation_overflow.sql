-- ============================================================================
-- NETTOYAGE
-- ============================================================================
DROP TRIGGER IF EXISTS tgv_new_table_reservation_overflow ON public.reservation_tables;
DROP FUNCTION IF EXISTS public.check_new_table_reservation_overflow() CASCADE;

-- ============================================================================
-- FONCTION DE VÉRIFICATION DE CONFLIT (BR-06)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.check_new_table_reservation_overflow()
    RETURNS TRIGGER AS $$
DECLARE
    v_res_datetime TIMESTAMP;
    v_res_status status_type;
BEGIN
    -- 1. Récupérer les infos de la réservation liée
    SELECT datetime, status INTO v_res_datetime, v_res_status
    FROM public.reservations
    WHERE id = NEW.reservation;

    -- On ne vérifie le conflit que si la réservation est confirmée
    IF v_res_status = 'confirmed'::status_type THEN

        -- 2. Vérifier si une AUTRE réservation occupe déjà cette table au même moment
        IF EXISTS (
            SELECT 1
            FROM public.reservation_tables rt
                     JOIN public.reservations r ON r.id = rt.reservation
            WHERE rt.table = NEW.table           -- Même table
              AND rt.reservation <> NEW.reservation -- Différente réservation
              AND r.status = 'confirmed'::status_type -- Déjà confirmée
              -- Même jour (date)
              AND r.datetime::date = v_res_datetime::date
            -- On suppose que le service est défini par l'appartenance à la même plage horaire
            -- Ici, on vérifie si l'heure est dans la même plage (ou simplement même jour/service)
            -- Ajuste selon ta logique de services si besoin
        ) THEN
            RAISE EXCEPTION 'BR-06: Cette table est déjà réservée pour ce service.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- ============================================================================
-- TRIGGER
-- ============================================================================
CREATE TRIGGER tgv_new_table_reservation_overflow
    BEFORE INSERT ON public.reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION public.check_new_table_reservation_overflow();