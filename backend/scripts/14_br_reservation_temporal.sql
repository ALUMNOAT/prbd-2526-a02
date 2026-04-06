-- CLEANUP
DROP TRIGGER IF EXISTS trg_br14_reservation_temporal ON reservations;
drop function if exists get_current_logic_time();
DROP FUNCTION IF EXISTS check_br14_reservation_temporal() CASCADE;

-- FUNCTION

/* Fonction (méthode de config) qui retourne/setup le temps du systeme
 * SET app.simulated_time = '2025-01-01 12:00:00'; (par exemple)
 * (Sans IA chaud de fou) */

CREATE OR REPLACE FUNCTION get_current_logic_time()
    RETURNS TIMESTAMP
AS $$
DECLARE
    sim_time TEXT;
BEGIN
    -- On récupère la variable de session (renvoie NULL si non définie)
    sim_time := current_setting('app.simulated_time', true);
    IF sim_time IS NOT NULL AND sim_time <> '' THEN
        RETURN sim_time::TIMESTAMP;
    END IF;
    RETURN CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

/* Fonction de check */
CREATE OR REPLACE FUNCTION check_br14_reservation_temporal()
    RETURNS TRIGGER AS $$
DECLARE
    now_logic TIMESTAMP := get_current_logic_time();
BEGIN
    -- BR-14 : Interdiction de créer dans le passé (INSERT uniquement)
    IF (TG_OP = 'INSERT') THEN
        IF NEW.datetime < now_logic THEN
            RAISE EXCEPTION 'BR-14: Une réservation ne peut pas être créée dans le passé.';
        END IF;
    END IF;

    -- Règle de transition : confirmed -> pending
    -- Autorisé uniquement si la réservation est dans le futur
    IF (TG_OP = 'UPDATE') THEN
        IF OLD.status = 'confirmed' AND NEW.status = 'pending' THEN
            IF OLD.datetime <= now_logic THEN
                RAISE EXCEPTION 'Transition impossible : Vous ne pouvez repasser en "pending" qu''une réservation future.';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- TRIGGER
CREATE TRIGGER trg_br14_reservation_temporal
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_br14_reservation_temporal();