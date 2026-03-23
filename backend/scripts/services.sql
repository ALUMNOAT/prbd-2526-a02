alter table services drop constraint if exists services_day_of_week_check;
alter table services drop constraint if exists services_start_time_end_time_check;

drop trigger if exists services_restaurant_no_modify on services;

drop function if exists services_restaurant_no_modify();

/* 1) Le jour de la semaine doit être compris entre 1 (lundi) et 7 (dimanche). */

alter table services
add constraint services_day_of_week_check
check ("day_of_week" >= 1 and "day_of_week" <= 7);

/* 2) L'heure de fin doit être postérieure à l'heure de début d'au moins une heure.
 * Note : l'heure de fin d'un service représente l'heure au-delà de laquelle le restaurant n'accepte plus de clients.
*/

alter table services
add constraint services_start_time_end_time_check
check ("end_time" - "start_time" >= interval '1 hour');


/* 3) On ne peut pas modifier le restaurant d'un service. */

create or replace function services_restaurant_no_modify()
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

create trigger services_restaurant_no_modify
before update on services
for each row execute function services_restaurant_no_modify();