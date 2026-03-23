alter table reservations drop constraint if exists reservations_guestsize_check;
alter table reservations drop constraint if exists reservations_special_requests_check;

drop trigger if exists reservations_restaurant_no_modify on reservations;
drop trigger if exists reservations_client_no_modify on reservations;

drop function if exists reservations_restaurant_no_modify();
drop function if exists reservations_client_no_modify();


/* 1) Le statut d'une réservation doit être soit pending (en attente de confirmation),
 * confirmed (confirmée), cancelled (annulée)
 * ou completed (terminée suite à la venue effective du client).
 *
 * alter table reservations
 * add constraint reservations_status_check
 * check ("status" in ('pending', 'confirmed', 'cancelled', 'completed'));
 *
 * On peut faire ça, mais… Dans Data types, on a status_type qui est un enum (comme role_type)
 * Ce qui veut dire qu'il fait un check interieur déjà, donc je ne dois rien écrire */

/* 2) Le nombre de convives d'une réservation doit être strictement positif. */

alter table reservations
add constraint reservations_guestsize_check
check ("number_of_guests" > 0);

/* 3) Le texte des demandes spéciales d'une réservation (special_requests),
 * s'il est défini, doit avoir une longueur minimale de 10 caractères. */

alter table reservations
add constraint reservations_special_requests_check
check ("special_requests" is null or length(TRIM("special_requests")) >= 10);

/* 4) On ne peut pas modifier le restaurant ou le client d'une réservation.
 * On compare nouvelle avec vieille valeur = function + trigger
 * Et il faut 2 fonctions et 2 triggers du coup */

create or replace function reservations_restaurant_no_modify()
returns trigger
language plpgsql
as $$
begin
    if new.restaurant <> old.restaurant then
        raise exception 'Le restaurant ne peut pas etre modifié.';
    end if;
    return new;
end;
$$;

create trigger reservations_restaurant_no_modify
before update on reservations
for each row execute function reservations_restaurant_no_modify();

create or replace function reservations_client_no_modify()
returns trigger
language plpgsql
as $$
begin
    if new.client <> old.client then
        raise exception 'Le client ne peut pas etre modifié.';
    end if;
    return new;
end;
$$;

create trigger reservations_client_no_modify
before update on reservations
for each row execute function reservations_client_no_modify();
