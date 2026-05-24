-- Drop Constraints
ALTER TABLE reservations
    DROP CONSTRAINT IF EXISTS reservations_guestsize_check,
    DROP CONSTRAINT IF EXISTS reservations_special_requests_check;

-- Drop Triggers
DROP TRIGGER IF EXISTS reservations_restaurant_no_modify
    ON reservations;

DROP TRIGGER IF EXISTS reservations_client_no_modify
    ON reservations;

-- Drop Functions
DROP FUNCTION IF EXISTS reservations_restaurant_no_modify();
DROP FUNCTION IF EXISTS reservations_client_no_modify();
drop function if exists getclientreservations(int);
drop function if exists clientannulerreservation(int);

/* 1) Le statut d'une réservation doit être soit pending (en attente de confirmation),
 * confirmed (confirmée), cancelled (annulée)
 * ou completed (terminée suite à la venue effective du client).
 *
 * alter table reservations
 * add constraint reservations_status_check
 * check ("status" in ('pending', 'confirmed', 'cancelled', 'completed'));
 *
 * On peut faire ça, mais… Dans Data types, on a status_type qui est un enum (comme role_type)
 * Ce qui veut dire qu'il fait un check interieur déjà, donc on ne dois rien écrire */


/* 2) Le nombre de convives d'une réservation doit être strictement positif. */

ALTER TABLE reservations
    ADD CONSTRAINT reservations_guestsize_check
    CHECK ("number_of_guests" > 0);

/* 3) Le texte des demandes spéciales d'une réservation (special_requests),
 * s'il est défini, doit avoir une longueur minimale de 10 caractères. */

ALTER TABLE reservations
    ADD CONSTRAINT reservations_special_requests_check
    CHECK (
        "special_requests" IS NULL
        OR LENGTH(TRIM("special_requests")) >= 10
    );

/* 4) On ne peut pas modifier le restaurant ou le client d'une réservation.
 * On compare nouvelle avec vieille valeur = function + trigger
 * Et il faut 2 fonctions et 2 triggers du coup */

CREATE OR REPLACE FUNCTION reservations_restaurant_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.restaurant <> OLD.restaurant THEN
        RAISE EXCEPTION 'Le restaurant ne peut pas etre modifié.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservations_restaurant_no_modify
    BEFORE UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION reservations_restaurant_no_modify();

CREATE OR REPLACE FUNCTION reservations_client_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.client <> OLD.client THEN
        RAISE EXCEPTION 'Le client ne peut pas etre modifié.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservations_client_no_modify
    BEFORE UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION reservations_client_no_modify();

CREATE OR REPLACE FUNCTION getclientreservations(userid int)
    RETURNS TABLE (
                      id int,
                      status text,
                      resto_name text,
                      resto_address text,
                      city text,
                      datetime timestamp,
                      number_of_guests int,
                      special_requests text,
                      phone text
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT reserve.id::int, reserve.status::text, resto."name"::text, resto.address::text, resto.city::text, reserve.datetime::timestamp, reserve.number_of_guests::int, reserve.special_requests::text, resto.phone::text
        FROM reservations as reserve, restaurants as resto
        WHERE reserve.restaurant = resto.id
        AND reserve.client = userid
        ORDER BY reserve.datetime DESC;
END
$$
    STABLE
    SECURITY DEFINER
    language plpgsql;

GRANT EXECUTE ON FUNCTION getclientreservations(int) TO authenticated;

create or replace function clientannulerreservation(_id int)
returns void
as
$$
begin
    -- Use UPDATE to modify the existing record
    update reservations
    set status = 'cancelled'  -- Use single quotes for string/enum literals
    where id = _id;           -- Use the parameter to target the specific row
end
$$ language plpgsql security definer;

GRANT EXECUTE ON FUNCTION clientannulerreservation(int) TO authenticated;