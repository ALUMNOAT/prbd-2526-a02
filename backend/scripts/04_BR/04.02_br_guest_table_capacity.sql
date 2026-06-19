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
    v_status status_type;
    v_guest_count INT;
    v_total_capacity INT;
    v_table_count INT;
BEGIN
    -- 1. Récupération de l'ID concerné
    IF TG_TABLE_NAME = 'reservations' THEN
        v_reservation_id := NEW.id;
    ELSIF TG_TABLE_NAME = 'reservation_tables' THEN
        v_reservation_id := COALESCE(NEW.reservation, OLD.reservation);
    END IF;

    IF v_reservation_id IS NULL THEN RETURN NULL; END IF;

    -- 2. Récupération des infos de la réservation
    SELECT status, number_of_guests INTO v_status, v_guest_count
    FROM public.reservations WHERE id = v_reservation_id;

    -- On ne vérifie que pour 'confirmed' ou 'completed'
    IF v_status IN ('confirmed'::status_type, 'completed'::status_type) THEN

        -- Calculer le nombre de tables et la capacité totale
        SELECT COUNT(t.id), COALESCE(SUM(t.capacity), 0)
        INTO v_table_count, v_total_capacity
        FROM public.reservation_tables rt
                 JOIN public.tables t ON t.id = rt.table
        WHERE rt.reservation = v_reservation_id;

        -- RÈGLE : Doit avoir au moins une table
        IF v_table_count = 0 THEN
            RAISE EXCEPTION 'BR-02: Une réservation confirmée doit avoir au moins une table associée.';
        END IF;

        -- RÈGLE : Capacité suffisante
        IF v_guest_count > v_total_capacity THEN
            RAISE EXCEPTION 'BR-02: Capacité totale des tables insuffisante pour le nombre de convives.';
        END IF;
    END IF;

    -- Vérification restaurant (indépendant du statut)
    IF EXISTS (
        SELECT 1 FROM public.reservation_tables rt
                          JOIN public.tables t ON t.id = rt.table
                          JOIN public.reservations r ON r.id = rt.reservation
        WHERE rt.reservation = v_reservation_id AND t.restaurant <> r.restaurant
    ) THEN
        RAISE EXCEPTION 'BR-02: Table non associée au bon restaurant.';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


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