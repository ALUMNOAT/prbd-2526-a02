-- ============================================================================
-- NETTOYAGE STRICT DE TOUS LES ANCIENS TRIGGERS
-- ============================================================================
DROP TRIGGER IF EXISTS trigger_validate_reservation_capacity ON public.reservations;
DROP TRIGGER IF EXISTS trigger_validate_reservation_tables_capacity ON public.reservation_tables;
DROP TRIGGER IF EXISTS trigger_validate_reservation_tables_insert_update ON public.reservation_tables;
DROP TRIGGER IF EXISTS trigger_validate_reservation_tables_capacity ON public.tables;

-- ============================================================================
-- 1. FONCTION DE VÉRIFICATION UNIQUE (Capacité + Restaurant)
-- ============================================================================
CREATE OR REPLACE FUNCTION check_guest_table_capacity()
    RETURNS TRIGGER AS $$
DECLARE
    v_reservation_id INT;
    v_invalid_restaurant_exists BOOLEAN;
BEGIN
    -- Détermination de l'ID de réservation concerné selon la table qui déclenche
    IF TG_TABLE_NAME = 'reservations' THEN
        v_reservation_id := NEW.id;
    ELSIF TG_TABLE_NAME = 'reservation_tables' THEN
        v_reservation_id := COALESCE(NEW.reservation, OLD.reservation);
    END IF;

    -- Si aucune réservation n'est ciblée (cas de suppression globale sur tables), on skip
    IF v_reservation_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- VERIFICATION 1 : Correspondance du restaurant
    SELECT EXISTS (
        SELECT 1
        FROM public.reservation_tables rt
                 JOIN public.tables t ON t.id = rt.table
                 JOIN public.reservations r ON r.id = rt.reservation
        WHERE rt.reservation = v_reservation_id
          AND t.restaurant <> r.restaurant
    ) INTO v_invalid_restaurant_exists;

    IF v_invalid_restaurant_exists THEN
        RAISE EXCEPTION 'BR-02: Une table associée n''appartient pas au même restaurant que la réservation.';
    END IF;

    -- VERIFICATION 2 : Capacité totale suffisante (Uniquement pour confirmed/completed)
    IF EXISTS (
        SELECT r.id
        FROM public.reservations r
                 LEFT JOIN public.reservation_tables rt ON rt.reservation = r.id
                 LEFT JOIN public.tables t ON t.id = rt.table
        WHERE r.id = v_reservation_id
          AND r.status IN ('confirmed'::status_type, 'completed'::status_type)
        GROUP BY r.id, r.number_of_guests
        HAVING r.number_of_guests > COALESCE(SUM(t.capacity), 0)
    ) THEN
        RAISE EXCEPTION 'BR-02: Too many guests. Table capacity not suitable';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql security definer;


-- ============================================================================
-- 2. RECRÉATION DES TRIGGERS PROPREMENT
-- ============================================================================

-- Trigger 1: Changements sur la réservation directe
CREATE TRIGGER trigger_validate_reservation_capacity
    AFTER INSERT OR UPDATE OF number_of_guests, status ON public.reservations
    FOR EACH ROW EXECUTE FUNCTION check_guest_table_capacity();

-- Trigger 2: Ajout ou modification d'une liaison de table
CREATE TRIGGER trigger_validate_reservation_tables_insert_update
    AFTER INSERT OR UPDATE ON public.reservation_tables
    FOR EACH ROW EXECUTE FUNCTION check_guest_table_capacity();

-- Trigger 3: Retrait d'une liaison de table (Différé en fin de transaction)
CREATE CONSTRAINT TRIGGER trigger_validate_reservation_tables_capacity
    AFTER DELETE ON public.reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION check_guest_table_capacity();