/*
 (1) https://stackoverflow.com/questions/50962700/postgresql-checking-for-new-and-old-in-a-function-for-a-trigger
 (2) https://www.postgresql.org/docs/current/functions-string.html
 (3) https://www.postgresql.org/docs/current/plpgsql-errors-and-messages.html
 */

-- Suppression des triggers (dans l'ordre inverse de création)
DROP TRIGGER IF EXISTS tgv_update_reservation ON reservations;
DROP TRIGGER IF EXISTS tgv_new_reservation ON reservations;

-- Suppression des fonctions
DROP FUNCTION IF EXISTS check_update_reservation();
DROP FUNCTION IF EXISTS check_new_reservation();

CREATE OR REPLACE FUNCTION check_new_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != 'pending'::status_type THEN
        RAISE EXCEPTION 'BR-09: A new reservation can only be of status ''pending''';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_new_reservation
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_new_reservation();


CREATE OR REPLACE FUNCTION check_update_reservation()
    RETURNS TRIGGER AS $$
DECLARE
    v_simulated_time TIMESTAMP = COALESCE(
            (SELECT st.simulated_time FROM system_time st),
            current_timestamp(0));
BEGIN
    -- 1. Si aucun changement de statut, on autorise
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    -- 2. Bloc de transitions autorisées
    IF (OLD.status = 'pending'::status_type AND NEW.status = 'confirmed'::status_type) OR
       (OLD.status = 'pending'::status_type AND NEW.status = 'cancelled'::status_type) OR
       (OLD.status = 'confirmed'::status_type AND NEW.status = 'completed'::status_type) OR
       (OLD.status = 'confirmed'::status_type AND NEW.status = 'cancelled'::status_type) OR
        -- Transition conditionnelle : confirmed -> pending
       (OLD.status = 'confirmed'::status_type AND NEW.status = 'pending'::status_type
           AND OLD.datetime > v_simulated_time) -- Condition temporelle à définir selon votre métier
    THEN
        RETURN NEW;
    END IF;

    -- 3. Si aucune des conditions précédentes n'est remplie, on bloque
    RAISE EXCEPTION 'BR-09: Invalid status transition from % to %', OLD.status, NEW.status;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_update_reservation
    BEFORE UPDATE OF status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_update_reservation();