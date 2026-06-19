import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/config/app_config.dart';
import 'package:prbd_2526_a02/providers/currentUserProvider.dart';

import '../models/reservation.dart';

// MODIFICATION : Création d'un provider pour charger les données.
// On utilise autoDispose pour que les données soient rechargées si on quitte et revient sur la page.
final allRestaurantsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final userID = ref.read(currentUserProvider.notifier).userID;
  if (userID == null) return [];
  // Appel direct à ta logique métier
  return await Reservation.getAllClientRestaurantsReservations(userID);
});

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SearchRestaurantsPage(),
    ),
  );
}

class SearchRestaurantsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchRestaurantsPage> createState() =>
      _SearchRestaurantsPageState();
}

class _SearchRestaurantsPageState extends ConsumerState<SearchRestaurantsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(allRestaurantsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rechercher un restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.invalidate(allRestaurantsProvider),
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              // MODIFICATION : Utilisation de .when() pour gérer loading/error/data proprement
              child: restaurantsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Erreur: $err')),
                data: (allRestaurants) {
                  final filteredData = allRestaurants.where((res) {
                    final name = (res['resto_name'] ?? '').toString().toLowerCase();
                    final city = (res['city'] ?? '').toString().toLowerCase();
                    final description = (res['description'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || city.contains(_searchQuery) || description.contains(_searchQuery);
                  }).toList();

                  final bool isTooMany = filteredData.length >= AppConfig.maxRestaurantsSearch;
                  final filteredRestaurants = isTooMany
                      ? filteredData.take(AppConfig.maxRestaurantsSearch).toList()
                      : filteredData;

                  // ON RETOURNE UNE COLUMN QUI CONTIENT TOUT
                  return Column(
                    children: [
                      // Condition directe dans la liste des enfants
                      if (filteredRestaurants.length >= AppConfig.maxRestaurantsSearch)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          color: Colors.orange.shade50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final res = filteredRestaurants[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                // LEFT SLOT
                                leading: const Icon(
                                  Icons.restaurant,
                                  size: 40,
                                ),

                                // TOP TEXT SLOT
                                title: Text(
                                  res['resto_name'] ?? 'Nom inconnu',
                                ),

                                // MAIN CONTENT SLOT (Your mockup lives here)
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(res['city'] ?? ''),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          res['rating']?.toString() ??
                                              '0.0',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '€' * res['price_range'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (res['latest_reservation'] !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Dernière réservation: ${res['latest_reservation'] != null ? DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(DateTime.parse(res['latest_reservation'])) : 'Jamais'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (res['pending_count'] > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pending,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${res['pending_count']} demande(s) en attente',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),

                                // RIGHT SLOT
                                trailing: const Icon(Icons.chevron_right),

                                // INTERACTION
                                onTap: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    '/detail_restaurant',
                                    arguments: res,
                                  );
                                  if (mounted) setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}