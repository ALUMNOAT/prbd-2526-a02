DROP TRIGGER IF EXISTS trigger_check_overlap ON services;
DROP FUNCTION IF EXISTS check_service_overlap() CASCADE;

CREATE OR REPLACE FUNCTION check_service_overlap()
    RETURNS TRIGGER AS $$
BEGIN
    -- On vérifie s'il existe une ligne qui pose problème
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
        RAISE EXCEPTION 'BR-07: Les services du restaurant % le jour % se chevauchent.', NEW.restaurant, NEW.day_of_week;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Application du trigger à la table
CREATE TRIGGER trigger_check_overlap
    BEFORE INSERT OR UPDATE ON services
    FOR EACH row EXECUTE FUNCTION check_service_overlap();

/*
 * Magnifique prompt à l'IA
 *
 * (j'ai merdé un peu la logique de chevauchement car pas de papier)
 *
 * select restaurant, day_of_week, start_time, end_time
 * from services
 * if old.restaurant = new.restaurant AND old.day_of_week =  new.day_of_week then
 * if old.start_time = new.start_time or old.end_time = new.end_time then
 * raise exception "message"
 * end if
 * end if
 * end
 *
 * quelque chose comme ca je pense, non?
 *
 * IA: C'est l'idée générale, mais ton raisonnement actuel est
 * un peu trop restrictif d'un côté et pas assez de l'autre.
 *
 * La logique mathématique du chevauchement
 * Pour que deux périodes [A,B] et [C,D] se chevauchent,
 * il suffit d'une condition simple :
 * Le début de l'un est avant la fin de l'autre,
 * ET la fin de l'un est après le début de l'autre.
 * */

