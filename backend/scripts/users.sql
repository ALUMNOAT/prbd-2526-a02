alter table users drop constraint if exists users_full_name_min_length;
alter table users drop constraint if exists users_passwords_rules;

/* on supprime d'abord les triggers, puis les fonctions, sinon on a erreur */

drop trigger if exists users_role_no_modify on users;

drop function if exists users_role_no_modify();

/* 1) Le nom complet doit avoir une longueur d'au moins 3 caractères. */

alter table users
add constraint users_full_name_min_length
check (length(TRIM("full_name")) >= 3);

/* 2) Le mot de passe doit avoir au minimum une longueur de 8 caractères,
 * doit contenir au moins un chiffre, une lettre majuscule,
 * une lettre minuscule et un caractère spécial parmi les suivants :
 * ,;.:!?/$%&@#. */

/* regexp_match() → retourne text[] ou NULL (à utiliser dans un SELECT)
 * regexp_matches() → retourne un setof text[] (à utiliser dans un FROM)
 * ~ → retourne un boolean */

alter table users
add constraint users_passwords_rules
check (
    length("password") >= 8             /* minimum 8 charactères   */
    and "password" ~ '[0-9]'            /* contient un chiffre     */
    and "password" ~ '[A-Z]'            /* contient une majuscule  */
    and "password" ~ '[a-z]'            /* contient une minuscule  */
    and "password" ~ '[,;.:!?/$%&@#]'   /* contient un car spécial */
);

/* 3) Le mot de passe doit être stocké de manière sécurisée (hachage + sel).
 * auth a une fonction encrypt_pass(), et la table users a ça
 *
 * -- Table Triggers
 * create trigger encrypt_pass after
 * insert
 * 	or
 * update
 * 	on
 * 	public.users for each row execute function auth.encrypt_pass();
 *
 * donc on ne doit rien faire pour la 3)
 */

/* 4) On ne peut pas modifier le rôle d'un utilisateur.
 *
 * Là un check ne sert à rien, du coup trigger pour comparer
 * Règle générale : un trigger se justifie quand vous avez besoin de comparer NEW et OLD
 * (comme pour le rôle), ou d'un effet de bord.
 * Pour une validation sur les valeurs d'un seul record, un CHECK est toujours préférable.
 */

/* Il faut d'abord une fonction, puis un trigger, sinon on a une erreur */

create or replace function users_role_no_modify()
returns trigger
language plpgsql
as $$
begin
	if new.role <> old.role then
	   raise exception 'Le role d''un utilisateur ne peut pas etre modifié.';
	   end if;
	   return new;
end;
$$;

create trigger users_role_no_modify
before update on users
for each row execute function users_role_no_modify();

