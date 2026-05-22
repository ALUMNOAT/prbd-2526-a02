/*
 (1) https://stackoverflow.com/questions/6133107/extract-date-yyyy-mm-dd-from-a-timestamp-in-postgresql
 (2) https://www.pgtutorial.com/plpgsql/plpgsql-record/
 (3) https://stackoverflow.com/questions/4547672/return-multiple-fields-as-a-record-in-postgresql-with-pl-pgsql
 (4) https://stackoverflow.com/questions/24755468/language-sql-vs-language-plpgsql-in-postgresql-functions
 (5) https://stackoverflow.com/questions/34721832/postgresql-return-single-row-from-function-after-select-statement
 (6) https://dba.stackexchange.com/questions/67875/return-a-record-with-pl-pgsql-function-to-speed-up-the-query
 (7) https://stackoverflow.com/questions/7945932/how-to-return-result-of-a-select-inside-a-function-in-postgresql
 (8) https://www.postgresql.org/docs/current/plpgsql-control-structures.html#PLPGSQL-STATEMENTS-RETURNING
 */


CREATE OR REPLACE FUNCTION check_reservation_overflow()
    RETURNS TRIGGER AS $$
DECLARE
    current_reservation reservations = get_reservation(NEW.reservation);
    desired_table tables = get_table(NEW.table);
    desired_table_reservations reservations = get_reservation(desired_table);
BEGIN
    IF (current_reservation.status IN ('confirmed'::status_type))
    AND EXISTS(
        SELECT 1
        FROM desired_table_reservations dtr
        WHERE is_same_service_same_day(current_reservation, dtr)
    ) THEN
        RAISE EXCEPTION 'BR-06: This table is already reserved.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_reservation_overflow
    BEFORE INSERT
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_overflow();