alter table "tables" drop constraint if exists tables_number_positif;
alter table "tables" drop constraint if exists tables_capacity_positif;

drop trigger if exists tables_restaurant_no_modify on "tables";

drop function if exists tables_restaurant_no_modify();

/* 1) Le numéro de table doit être strictement positif
 * et unique au sein d'un même restaurant.
 *
 * Il y a déjà une contrainte dans la table pour unique
 * CONSTRAINT tables_restaurant_table_number_key UNIQUE (restaurant, table_number)
 *
 * Il faut juste que le num de table soit strictement positif
 */

alter table "tables"
add constraint tables_number_positif
check ("table_number" > 0);

/* 2) La capacité doit être strictement positive. */

alter table "tables"
add constraint tables_capacity_positif
check ("capacity" > 0);

/* 3) On ne peut pas modifier le restaurant d'une table. */

create or replace function tables_restaurant_no_modify()
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

create trigger tables_restaurant_no_modify
before update on "tables"
for each row execute function tables_restaurant_no_modify();
