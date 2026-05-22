/*
 (1) https://neon.com/postgresql/plpgsql/plpgsql-function-parameters
 (2) https://stackoverflow.com/questions/36199437/how-to-access-record-elements-in-postgresql
 */

CREATE OR REPLACE FUNCTION check_reservation_schrodinger()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT get_services(get_user(NEW.client))
        INTERSECT
        SELECT get_service(get_restaurant(NEW.restaurant), NEW.datetime)
    ) THEN
        RAISE EXCEPTION 'BR-13: This client already has a reservation ';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_reservation_schrodinger
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_schrodinger();