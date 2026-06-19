set search_path to public;


-- doesn't work, but why is a mystery ?
begin;
do
$test$
    begin
        raise notice 'TEST ENDPOINT ASSIGN TABLES';

        INSERT INTO reservation_tables
        VALUES
            (2, 4),
            (2, 5);

        UPDATE reservations r SET status = 'confirmed'
        WHERE r.id = 2;

        assert (SELECT r.status
            FROM reservations r
            WHERE r.id = 2)  = 'completed'::status_type;
    end
$test$;
rollback;