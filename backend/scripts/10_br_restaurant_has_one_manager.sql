/* (BR-10) Un restaurant doit avoir au moins un manager.  */

/* TG_OP est une variable spéciale (une variable d'état) que PostgreSQL
 * met automatiquement à ta disposition à l'intérieur d'une fonction trigger.
 *
 * Elle contient une chaîne de caractères (TEXT) qui indique quelle opération
 * a déclenché le trigger.
 *
 * TG_OP peut prendre l'une des quatre valeurs suivantes :
 * INSERT : Si le trigger a été déclenché par une insertion.
 * UPDATE : Si le trigger a été déclenché par une mise à jour.
 * DELETE : Si le trigger a été déclenché par une suppression.
 * TRUNCATE : Si le trigger a été déclenché par un vidage de table.
 *
 * Un petit piège à éviter avec TG_OP
 * En INSERT, OLD est NULL (logique, la ligne n'existait pas).
 * En DELETE, NEW est NULL (la ligne n'existe plus).
*/

/* IA: Le cas délicat de l'UPDATE
   Il y a un scénario que votre code actuel ne couvre pas totalement :
   que se passe-t-il si un utilisateur fait un UPDATE pour changer le restaurant d'un manager ?
   Si on déplace le manager du Restaurant A vers le Restaurant B,
   le Restaurant A pourrait se retrouver avec zéro manager.
   Pour être 100% blindé, il faudrait vérifier le compte sur OLD.restaurant lors d'un UPDATE,
   tout comme vous le faites pour le DELETE.
 */

-- NETTOYAGE --
DROP TRIGGER IF EXISTS trg_br10_restaurant_manager ON restaurant_managers;
DROP FUNCTION IF EXISTS check_one_manager_restaurant();

-- CREATION FONCTION --
CREATE OR REPLACE FUNCTION check_one_manager_restaurant()
RETURNS TRIGGER AS $$
DECLARE
    m_count INT;
BEGIN
    -- 1. Sécurité sur l'Ajout ou la Modification (Rôle 'manager' requis)
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NOT EXISTS (
            SELECT 1 FROM users
            WHERE id = NEW.manager AND role = 'manager'::role_type
        ) THEN
            RAISE EXCEPTION 'BR-10: L''utilisateur (ID %) doit avoir le rôle "manager" pour gérer un restaurant.',
                NEW.manager;
        END IF;
    END IF;

    -- 2. Sécurité sur la Suppression (Au moins un manager restant)
    IF (TG_OP = 'DELETE') THEN
        -- On compte combien de manager il reste pour CE restaurant
        SELECT COUNT(*) INTO m_count
        FROM restaurant_managers
        WHERE restaurant = OLD.restaurant;

        -- Si c'est le dernier, on bloque la suppression
        IF m_count <= 1 THEN
            RAISE EXCEPTION 'BR-10: Un restaurant (ID %) doit avoir au moins un manager. Impossible de supprimer le dernier manager (ID %).',
                OLD.restaurant, OLD.manager;
        END IF;

        -- Important pour un trigger de suppression : on retourne OLD
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATION TRIGGER --
CREATE TRIGGER trg_br10_restaurant_manager
    BEFORE INSERT OR UPDATE OR DELETE ON restaurant_managers
    FOR EACH ROW
    EXECUTE FUNCTION check_one_manager_restaurant();