-- Drop Constraints
ALTER TABLE services
    DROP CONSTRAINT IF EXISTS services_day_of_week_check,
    DROP CONSTRAINT IF EXISTS services_start_time_end_time_check;

-- Drop Triggers
DROP TRIGGER IF EXISTS services_restaurant_no_modify
    ON services;

-- Drop Functions
DROP FUNCTION IF EXISTS services_restaurant_no_modify();

/* 1) Le jour de la semaine doit être compris entre 1 (lundi) et 7 (dimanche). */

ALTER TABLE services
    ADD CONSTRAINT services_day_of_week_check
    CHECK ("day_of_week" BETWEEN 1 AND 7);

/* 2) L'heure de fin doit être postérieure à l'heure de début d'au moins une heure.
 * Note : l'heure de fin d'un service représente l'heure au-delà de laquelle le restaurant n'accepte plus de clients.
*/

ALTER TABLE services
    ADD CONSTRAINT services_start_time_end_time_check
    CHECK ("end_time" - "start_time" >= INTERVAL '1 hour');


/* 3) On ne peut pas modifier le restaurant d'un service. */

CREATE OR REPLACE FUNCTION services_restaurant_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérification de l'immuabilité du restaurant
    IF NEW."restaurant" <> OLD."restaurant" THEN
        RAISE EXCEPTION 'Le restaurant ne peut pas être modifié.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER services_restaurant_no_modify
    BEFORE UPDATE ON services
    FOR EACH ROW
    EXECUTE FUNCTION services_restaurant_no_modify();