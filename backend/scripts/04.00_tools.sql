/*
 (1) https://stackoverflow.com/questions/22423958/sql-function-return-type-table-vs-setof-records
 (2) https://stackoverflow.com/questions/36199437/how-to-access-record-elements-in-postgresql
 */

set search_path to public;

DROP FUNCTION get_reservation(INT);
CREATE OR REPLACE FUNCTION get_reservation(
    IN reservation_id INT)
    RETURNS SETOF reservations AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM reservations r
    WHERE r.id = reservation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'BR-06: The given reservation id was not associated with any reservation';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT r.datetime
FROM get_reservation(1) r;