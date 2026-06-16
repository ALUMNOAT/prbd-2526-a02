-- ============================================================================
-- NETTOYAGE STRICT DE L'ANCIEN TRIGGER ET DE LA FONCTION
-- ============================================================================
DROP TRIGGER IF EXISTS tgv_reservation_tables_ownership ON public.reservation_tables;
DROP FUNCTION IF EXISTS public.check_table_ownership() CASCADE;

-- ============================================================================
-- FONCTION DE VÉRIFICATION DE PROPRIÉTÉ (BR-03) - VERSION SANS FONCTIONS EXTERNES
-- ============================================================================
CREATE OR REPLACE FUNCTION public.check_table_ownership()
    RETURNS TRIGGER AS $$
DECLARE
    v_reservation_restaurant INT;
    v_table_restaurant INT;
BEGIN
    -- 1. Récupération directe du restaurant lié à la réservation
    SELECT restaurant INTO v_reservation_restaurant
    FROM public.reservations
    WHERE id = NEW.reservation;

    -- 2. Récupération directe du restaurant lié à la table physique
    SELECT restaurant INTO v_table_restaurant
    FROM public.tables
    WHERE id = NEW.table;

    -- 3. Comparaison des deux IDs de restaurant
    IF (v_reservation_restaurant <> v_table_restaurant) THEN
        RAISE EXCEPTION 'BR-03: Selected table do not belong to the restaurant of the reservation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

-- ============================================================================
-- CRÉATION DU TRIGGER
-- ============================================================================
CREATE TRIGGER tgv_reservation_tables_ownership
    BEFORE INSERT OR UPDATE ON public.reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION public.check_table_ownership();