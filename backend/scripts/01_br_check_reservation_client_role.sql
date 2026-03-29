create or replace function check_reservation_client_role()
    returns trigger
as $$
begin
    if not exists (
        select 1 from users
        where id = new.client and role = 'client'::role_type
    ) then
        raise exception
            'BR-01: L''utilisateur (ID %) doit avoir le rôle "client" pour effectuer une réservation.',
            new.client;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_check_reservation_client
    before insert or update of client on reservations
    for each row execute function check_reservation_client_role();