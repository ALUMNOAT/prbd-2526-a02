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