-- (BR-15) Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.

-- Suppression du trigger
DROP TRIGGER IF EXISTS check_vip_limit_trigger ON reservations;

-- Suppression de la fonction
DROP FUNCTION IF EXISTS check_vip_limit();

create or replace function check_vip_limit()
    returns trigger as $$
declare
    nbre_de_vip int;
    temps_simulé timestamp;
begin
    select simulated_time from system_time into temps_simulé;

    -- 1) si réservation est non VIP et status est complété ou annulé
    if (new.is_vip = false and new.status in ('completed', 'canceled')) then
    Raise Exception 'Mode VIP modifiable uniquement pour les reservations actives';
    END if;

    -- 2) si réservation est dans le passé, alors exception
    if (new.datetime < temps_simulé) then
    Raise Exception 'Mode VIP modifiable seulement pour les réservations futures';
    END if;

    -- 3) si 3 réservations VIP existent déja pour ce restaurant
    -- On compte toutes les réservations VIP pour ce restaurant,
    -- SAUF celle qu'on est en train de modifier
    SELECT COUNT(*) INTO nbre_de_vip
    FROM reservations
    WHERE is_vip = TRUE
      AND restaurant = NEW.restaurant
      AND id <> NEW.id;

    if (nbre_de_vip >= 3) then
    Raise Exception 'Plafond de 3 réservations VIP actives atteint pour ce restaurant';
    END if;

    -- 4) le cas de modification, c'est le trigger qui s'en charge

    Return new;
END;
$$ LANGUAGE plpgsql security definer;

Create trigger check_vip_limit_trigger
    BEFORE UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE Function check_vip_limit();