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
                      pending_count int,
                      latest_reservation timestamp,
                      tables table_info[],    -- Nouveau champ
                      services service_info[] -- Nouveau champ
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
            COUNT(DISTINCT reserve.id) FILTER (WHERE reserve.status = 'pending')::int,
            MAX(reserve.datetime),
            -- Agrégation des tables en tableau de types composites
            ARRAY_AGG(DISTINCT (t.id, t.restaurant, t.table_number, t.capacity)::table_info)
            FILTER (WHERE t.id IS NOT NULL),
            -- Agrégation des services en tableau de types composites
            ARRAY_AGG(DISTINCT (s.id, s.restaurant, s.day_of_week, s.start_time, s.end_time)::service_info)
            FILTER (WHERE s.id IS NOT NULL)
        FROM
            restaurants as resto
                LEFT JOIN services s ON s.restaurant = resto.id
                LEFT JOIN tables t ON t.restaurant = resto.id
                LEFT JOIN reservations as reserve ON reserve.restaurant = resto.id AND reserve.client = userid
        GROUP BY
            resto.id
        ORDER BY
            latest_reservation DESC NULLS LAST;
END
$$ STABLE SECURITY DEFINER LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION getclientallrestaurantreservationsandservices(int) TO authenticated;

/* CREATE TYPE table_info AS (
    id int,
    restaurant int,
    table_number int,
    capacity int
); */

/* CREATE TYPE service_info AS (
    id int,
    restaurant int,
    day_of_week int,
    start_time time,
    end_time time
); */