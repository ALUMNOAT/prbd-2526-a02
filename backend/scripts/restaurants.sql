-- Drop Constraints
ALTER TABLE restaurants
    DROP CONSTRAINT IF EXISTS restaurants_name_min_length,
    DROP CONSTRAINT IF EXISTS restaurants_address_min_length,
    DROP CONSTRAINT IF EXISTS restaurants_city_min_length,
    DROP CONSTRAINT IF EXISTS restaurants_phone_check,
    DROP CONSTRAINT IF EXISTS restaurants_description_min_length,
    DROP CONSTRAINT IF EXISTS restaurants_rating_check,
    DROP CONSTRAINT IF EXISTS restaurants_price_range_check,
    DROP CONSTRAINT IF EXISTS restaurants_slot_check;

/* 1) Le nom doit avoir au minimum une longueur de 5 caractères. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_name_min_length
    CHECK (LENGTH(TRIM("name")) >= 5);

/* 2) L'adresse doit avoir au minimum une longueur de 5 caractères. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_address_min_length
    CHECK (LENGTH(TRIM("address")) >= 5);

/* 3) La ville doit avoir au minimum une longueur de 3 caractères. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_city_min_length
    CHECK (LENGTH(TRIM("city")) >= 3);

/* 4) Le numéro de téléphone doit avoir un format de numéro belge valide,
 * et peut être encodé avec ou sans espaces de séparation entre les groupes de chiffres.
 * Le REPLACE("phone", ' ', '') supprime tous les espaces avant de vérifier la validité.
 * Cela permet aux utilisateurs de saisir 0470 12 34 56 ou 0470123456 sans erreur. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_phone_check
    CHECK (
        REPLACE("phone", ' ', '') ~ '^\+32[1-9][0-9]{7,8}$'
        OR REPLACE("phone", ' ', '') ~ '^0[1-9][0-9]{7,8}$'
    );

/* 5) La description, si elle est fournie, doit avoir au minimum une longueur de 10 caractères. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_description_min_length
    CHECK (
        "description" IS NULL
        OR LENGTH(TRIM("description")) >= 10
    );

/* 6) La note doit être comprise entre 0.0 et 5.0 si elle est définie.
   On va utiliser BETWEEN au lieu de ("rating" >= 0.0 AND "rating" <= 5.0) (bornes incluses)*/

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_rating_check
    CHECK (
        "rating" IS NULL
        OR "rating" BETWEEN 0.0 AND 5.0
    );

/* 7) La fourchette de prix doit être comprise entre 1 et 4 si elle est définie. */

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_price_range_check
    CHECK (
        "price_range" IS NULL
        OR "price_range" BETWEEN 1 AND 4
    );

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

ALTER TABLE restaurants
    ADD CONSTRAINT restaurants_slot_check
    CHECK ("slot_duration" IN (10, 15, 20, 30, 60));

