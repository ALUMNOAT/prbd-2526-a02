-- (1) https://www.postgresql.org/docs/current/functions-conditional.html
--

-- NETTOYAGE --
--DROP TRIGGER IF EXISTS trg_check_guest_table_capacity ON reservations;
--DROP FUNCTION IF EXISTS check_guest_table_capacity();


CREATE OR REPLACE FUNCTION check_guest_table_capacity()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT r.id, r.number_of_guests, COALESCE(SUM(), 0)
        FROM reservations r
            LEFT JOIN reservation_tables rt ON r.id = rt.reservation
            LEFT JOIN tables t ON rt.table = t.id
        WHERE r.status IN ('confirmed'::status_type, 'completed'::status_type)
        GROUP BY r.id, r.number_of_guests
        HAVING r.number_of_guests > COALESCE(SUM(), 0)
    ) THEN
        RAISE EXCEPTION 'Too many guests. Table capacity not suitable';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql security definer;


/*
-- NETTOYAGE --
DROP TRIGGER IF EXISTS trg_check_reservation_client ON reservations;
DROP FUNCTION IF EXISTS check_reservation_client_role();

-- CREATION FONCTION --
CREATE OR REPLACE FUNCTION check_reservation_client_role()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifie si l'ID de l'utilisateur existe avec le rôle spécifique
    IF NOT EXISTS (
        SELECT 1
        FROM users
        WHERE id = NEW.client
          AND role = 'client'::role_type
    ) THEN
        -- Si l'utilisateur n'est pas trouvé ou n'est pas un client, on lève une exception
        RAISE EXCEPTION
            'BR-01: L''utilisateur (ID %) doit avoir le rôle "client" pour effectuer une réservation.',
            NEW.client;
END IF;

    -- Si tout est correct, on autorise l'opération
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATION TRIGGER --
CREATE TRIGGER trg_check_reservation_client
    BEFORE INSERT OR UPDATE OF client ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION check_reservation_client_role();