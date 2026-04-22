-- Drop Constraints
ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_full_name_min_length,
    DROP CONSTRAINT IF EXISTS users_passwords_rules;

-- Drop Triggers
DROP TRIGGER IF EXISTS users_role_no_modify
    ON users;

-- Drop Functions
DROP FUNCTION IF EXISTS users_role_no_modify();

/* 1) Le nom complet doit avoir une longueur d'au moins 3 caractères. */

ALTER TABLE users
    ADD CONSTRAINT users_full_name_min_length
    CHECK (length(TRIM("full_name")) >= 3);

/* 2) Le mot de passe doit avoir au minimum une longueur de 8 caractères,
 * doit contenir au moins un chiffre, une lettre majuscule,
 * une lettre minuscule et un caractère spécial parmi les suivants :
 * ,;.:!?/$%&@#. */

/* regexp_match() → retourne text[] ou NULL (à utiliser dans un SELECT)
 * regexp_matches() → retourne un setof text[] (à utiliser dans un FROM)
 * ~ → retourne un boolean */

ALTER TABLE users
    ADD CONSTRAINT users_passwords_rules
    CHECK (
        length("password") >= 8             /* minimum 8 charactères   */
        AND "password" ~ '[0-9]'            /* contient un chiffre     */
        AND "password" ~ '[A-Z]'            /* contient une majuscule  */
        AND "password" ~ '[a-z]'            /* contient une minuscule  */
        AND "password" ~ '[,;.:!?/$%&@#]'   /* contient un car spécial */
    );

/* 3) Le mot de passe doit être stocké de manière sécurisée (hachage + sel).
 * auth a une fonction encrypt_pass(), et la table users a ça
 *
 * -- Table Triggers
 * create trigger encrypt_pass after
 * insert
 * 	or
 * update
 * 	on
 * 	public.users for each row execute function auth.encrypt_pass();
 *
 * donc on ne doit rien faire pour la 3)
 */

/* 4) On ne peut pas modifier le rôle d'un utilisateur.
 *
 * Là un check ne sert à rien, du coup trigger pour comparer
 * Règle générale : un trigger se justifie quand vous avez besoin de comparer NEW et OLD
 * (comme pour le rôle), ou d'un effet de bord.
 * Pour une validation sur les valeurs d'un seul record, un CHECK est toujours préférable.
 */

CREATE OR REPLACE FUNCTION users_role_no_modify()
RETURNS TRIGGER AS $$
BEGIN
    -- Empêche le changement de privilèges (ex: de 'client' à 'admin')
    IF NEW."role" <> OLD."role" THEN
        RAISE EXCEPTION 'Le rôle d''un utilisateur ne peut pas être modifié.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_role_no_modify
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION users_role_no_modify();

