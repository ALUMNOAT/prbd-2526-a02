drop function if exists getclientallrestaurantreservationsandservices(int);

CREATE OR REPLACE FUNCTION getclientallrestaurantreservationsandservices(userid int)
    RETURNS TABLE (
                      id int,
                      resto_name text,
                      resto_address text,
                      city text,
                      phone text,
                      description text,
                      rating float8,
                      price_range int,
                      slot_duration int,
                      start_time time,
                      end_time time,
                      pending_count int,
                      latest_reservation timestamp
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            resto.id::int,
            resto."name"::text,
            resto.address::text,
            resto.city::text,
            resto.phone::text,
            resto.description::text,
            resto.rating,
            resto.price_range,
            resto.slot_duration,
            -- On agrège les services d'abord
            MIN(services.start_time) as start_time,
            MAX(services.end_time) as end_time,
            -- On compte DISTINCTEMENT les IDs de réservations en attente
            COUNT(DISTINCT reserve.id) FILTER (WHERE reserve.status = 'pending')::int as pending_count,
            MAX(reserve.datetime) as latest_reservation
        FROM
            restaurants as resto
                -- JOIN explicite pour les services
                LEFT JOIN services ON services.restaurant = resto.id
                -- JOIN explicite pour les réservations (uniquement celles du client)
                LEFT JOIN reservations as reserve ON reserve.restaurant = resto.id AND reserve.client = userid
        GROUP BY
            resto.id,
            resto."name",
            resto.address,
            resto.city,
            resto.phone,
            resto.description,
            resto.rating,
            resto.price_range,
            resto.slot_duration
        ORDER BY
            latest_reservation DESC NULLS LAST;
END
$$ STABLE SECURITY DEFINER LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION getclientallrestaurantreservationsandservices(int) TO authenticated;