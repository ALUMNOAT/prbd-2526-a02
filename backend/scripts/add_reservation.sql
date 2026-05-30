DROP FUNCTION IF EXISTS add_reservation(int, int, timestamp, int, text);

CREATE OR REPLACE FUNCTION add_reservation(
    p_client int,
    p_restaurant int,
    p_datetime timestamp,
    p_guests int,
    p_special_requests text
) RETURNS void AS $$
DECLARE
    v_reservation_id int;
BEGIN
    -- On insère la réservation en 'pending'.
    INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
    VALUES (p_client, p_restaurant, p_datetime, p_guests, 'pending', p_special_requests)
    RETURNING id INTO v_reservation_id;

    -- On ne fait rien d'autre. La table sera assignée par le manager lors du passage au statut 'confirmed'.
END;
$$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.add_reservation(int, int, timestamp, int, text) TO authenticated;