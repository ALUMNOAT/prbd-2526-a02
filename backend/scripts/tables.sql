-- Drop Constraints
ALTER TABLE "tables"
    DROP CONSTRAINT IF EXISTS tables_number_positif,
    DROP CONSTRAINT IF EXISTS tables_capacity_positif;

-- Drop Triggers
DROP TRIGGER IF EXISTS tables_restaurant_no_modify
    ON "tables";

-- Drop Functions
DROP FUNCTION IF EXISTS tables_restaurant_no_modify();

/* 1) Le numéro de table doit être strictement positif
 * et unique au sein d'un même restaurant.
 *
 * Il y a déjà une contrainte dans la table pour unique
 * CONSTRAINT tables_restaurant_table_number_key UNIQUE (restaurant, table_number)
 *
 * Il faut juste que le num de table soit strictement positif
 */

ALTER TABLE "tables"
    ADD CONSTRAINT tables_number_positif
    CHECK ("table_number" > 0);

/* 2) La capacité doit être strictement positive. */

ALTER TABLE "tables"
    ADD CONSTRAINT tables_capacity_positif
    CHECK ("capacity" > 0);

/* 3) On ne peut pas modifier le restaurant d'une table. */

CREATE OR REPLACE FUNCTION tables_restaurant_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    -- On s'assure que la table reste liée au même restaurant
    IF NEW."restaurant" <> OLD."restaurant" THEN
        RAISE EXCEPTION 'Le restaurant ne peut pas être modifié.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tables_restaurant_no_modify
    BEFORE UPDATE ON "tables"
    FOR EACH ROW
    EXECUTE FUNCTION tables_restaurant_no_modify();
