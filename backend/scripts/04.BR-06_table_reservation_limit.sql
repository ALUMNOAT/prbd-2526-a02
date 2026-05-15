CREATE OR REPLACE FUNCTION check_table_reservation_limit()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(      -- see doc(8)
        SELECT 1
        FROM reservations r
        LEFT JOIN reservation_tables rt ON rt.reservation = NEW.restaurant
    ) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'BR-05: No slots exists at the given reservation''s timedate';
END;
$$ LANGUAGE plpgsql security definer;

CREATE TRIGGER tgv_table_reservation_limit
    BEFORE UPDATE OF status
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_table_reservation_limit();