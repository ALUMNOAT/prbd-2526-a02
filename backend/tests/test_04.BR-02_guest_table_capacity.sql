set search_path to public;


-- doesn't work, but why is a mystery ?
begin;
do
$test$
    begin
        raise notice 'TEST BR-02: guest table capacity';

        INSERT INTO tables VALUES (99, 1, 99, 4);
        INSERT INTO reservations
        VALUES (99, 1, 1, '2030-1-1 19:00:00', 4, 'pending');
        INSERT INTO reservation_tables VALUES (99, 99);

        perform should_fail($$
        UPDATE reservations SET status = 'confirmed' WHERE id = 99;
        $$);
    end
$test$;
rollback;