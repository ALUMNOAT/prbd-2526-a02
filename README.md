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

Mes reservations (flux)
=========================

1) Le Future (Security.getClientReservations) : C'est le coursier. Il part à la base de données, attend la réponse, et revient avec le "colis" (le tableau JSON).

2) Le Snapshot : C'est l'état de la livraison. Une fois que le coursier est revenu, snapshot.data contient l'intégralité du tableau (les 5 réservations de Xavier).

3) reservations : C'est juste une variable locale pour extraire le contenu du colis proprement : final reservations = snapshot.data.

4) ListView.builder : C'est une usine de generation des cartes. On lui dit "Il y a 5 éléments dans reservations".

5) res = reservations[index] : À chaque ligne qu'il construit, l'usine prend une seule ligne du tableau (l'index 0, puis 1, puis 2...) pour remplir la carte correspondante.

### 🚀 Navigation & State Sync: The `await` Pattern

When navigating from a list (Home) to a detail view where data might be modified (e.g., cancelling a reservation), using `async/await` on the `Navigator` is critical to keep the UI in sync.

| Step  | User Action    | Code State (Home Page)   | Description                                                                       |
|:------|:---------------|:-------------------------|:----------------------------------------------------------------------------------|
| **1** | **Click Card** | `await Navigator.push()` | The code **pauses** execution at this line.                                       |
| **2** | **Interact**   | *Idle (Waiting)*         | The user is on the Details Page. They update the reservation (e.g., `Annuler`).   |
| **3** | **Click Back** | `Navigator.pop()`        | The Details Page is removed. This "wakes up" the code on the Home Page.           |
| **4** | **Resume**     | **Reactive**             | The `await` finishes. The code moves to the very next line automatically.         |
| **5** | **Rebuild**    | `setState(() {})`        | We trigger a rebuild of the Home Page.                                            |
| **6** | **Update**     | `FutureBuilder`          | The `FutureBuilder` re-runs, fetches fresh DB data, and shows the updated status. |

#### ⚠️ Why we avoid "Fire and Forget" (No Await)
If `await` is omitted, **Step 5** and **Step 6** execute immediately after **Step 1**.
The Home Page refreshes its data *before* the user has actually clicked "Cancel" on the next screen. Consequently, the list remains stale when the user eventually returns.