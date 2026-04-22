-- NETTOYAGE --
DROP TRIGGER IF EXISTS trigger_check_overlap ON services;
DROP FUNCTION IF EXISTS check_service_overlap();

-- CREATION FONCTION --
CREATE OR REPLACE FUNCTION check_service_overlap()
RETURNS TRIGGER AS $$
BEGIN
    -- On vérifie s'il existe une ligne qui pose un problème
    IF EXISTS (
        SELECT 1
        FROM services
        WHERE restaurant = NEW.restaurant       -- Même restaurant
          AND day_of_week = NEW.day_of_week     -- Même jour
          AND id <> NEW.id                      -- Pas la ligne elle-même (utile pour UPDATE)
          -- Logique de chevauchement :
          AND NEW.start_time < end_time
          AND NEW.end_time > start_time
    ) THEN
        RAISE EXCEPTION 'BR-07: Les services du restaurant % le jour % se chevauchent.',
            NEW.restaurant, NEW.day_of_week;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATION TRIGGER --
CREATE TRIGGER trigger_check_overlap
    BEFORE INSERT OR UPDATE ON services
    FOR EACH ROW
    EXECUTE FUNCTION check_service_overlap();

/* La logique mathématique du chevauchement
 * Pour que deux périodes [A,B] et [C,D] se chevauchent,
 * il suffit d'une condition simple :
 * Le début de l'un est avant la fin de l'autre,
 * ET la fin de l'un est après le début de l'autre.
 * */
