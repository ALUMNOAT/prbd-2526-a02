# Projet PRBD 2526 - Groupe a02 - ReserVite

## Notes de version

### Liste des bugs connus

* bug 1
* bug 2
* ...

### Liste des fonctionnalités supplémentaires

...

### Divers

...


## Explication de l'architecture

* app/my_app.dart (le gros routeur/config qui fait les redirections)
* core/services/api_client.dart (ajoute le token JWT directement et on ne 
doit pas taper à chaque fois http://localhost:3000 à chaque requete, juste /rpc)
* models/security.dart ()
* providers/security_provider.dart (logique/état. Le manager d'état

Le workflow (exemple):
1. utilisateur se connecte
2. security_provider est appelé
3. security_provider appelle security.login()
4. security appelle api_Client.post()
5. les données reviennent. security_provider sauvegarde les données dans params.dart (Hive) et dit à l'UI de rebuild/update le screen)

Summary of the Flow

    View (login.dart) -> Captures text.

    Provider (security_provider.dart) -> Manages the "Loading" state.

    Model/Service (security.dart) -> Formats the JSON for the DB.

    ApiClient (api_client.dart) -> Sends the actual bits over the internet.

Example of JWT Payload: {role: client, sub: mamichel@epfc.eu, name: Marc, user_id: 4, exp: 1776975024}