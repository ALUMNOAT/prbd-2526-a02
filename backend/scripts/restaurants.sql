alter table restaurants drop constraint if exists restaurants_name_min_length;
alter table restaurants drop constraint if exists restaurants_address_min_length;
alter table restaurants drop constraint if exists restaurants_city_min_length;
alter table restaurants drop constraint if exists restaurants_phone_check;
alter table restaurants drop constraint if exists restaurants_description_min_length;
alter table restaurants drop constraint if exists restaurants_rating_check;
alter table restaurants drop constraint if exists restaurants_price_range_check;
alter table restaurants drop constraint if exists restaurants_slot_check;

/* 1) Le nom doit avoir au minimum une longueur de 5 caractères. */

alter table restaurants
add constraint restaurants_name_min_length
check (length(TRIM("name")) >= 5);

/* 2) L'adresse doit avoir au minimum une longueur de 5 caractères. */

alter table restaurants
add constraint restaurants_address_min_length
check (length(TRIM("address")) >= 5);

/* 3) La ville doit avoir au minimum une longueur de 3 caractères. */

alter table restaurants
add constraint restaurants_city_min_length
check (length(TRIM("city")) >= 3);

/* 4) Le numéro de téléphone doit avoir un format de numéro belge valide,
 * et peut être encodé avec ou sans espaces de séparation entre les groupes de chiffres. */

alter table restaurants
add constraint restaurants_phone_check
check (
    replace("phone", ' ', '') ~ '^\+32[1-9][0-9]{7,8}$'
    OR replace("phone", ' ', '') ~ '^0[1-9][0-9]{7,8}$'
);

/* 5) La description, si elle est fournie, doit avoir au minimum une longueur de 10 caractères. */

alter table restaurants
add constraint restaurants_description_min_length
check ("description" is null or length(TRIM("description")) >= 10);

/* 6) La note doit être comprise entre 0.0 et 5.0 si elle est définie. */

alter table restaurants
add constraint restaurants_rating_check
check ("rating" is null or ("rating" >= 0.0 and "rating" <= 5.0));

/* 7) La fourchette de prix doit être comprise entre 1 et 4 si elle est définie. */

alter table restaurants
add constraint restaurants_price_range_check
check ("price_range" is null or ("price_range" >= 1 and "price_range" <= 4));


/* 8) La durée de créneau de réservation doit être
 * soit 10, 15, 20, 30 ou 60 minutes. */

/* alter table restaurants
 * add constraint restaurants_slot_check
 * check (
 * 		"slot_duration" = 10
 * 		or "slot_duration" = 15
 * 		or "slot_duration" = 20
 * 		or "slot_duration" = 30
 * 		or "slot_duration" = 60
 * 	);
 *
 * Ca marche mais on va faire plus elegant (merci IA)
 */

alter table restaurants
add constraint restaurants_slot_check
check ("slot_duration" in (10, 15, 20, 30, 60));



