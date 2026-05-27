import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/providers/currentUserProvider.dart';

import '../models/security.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeClientPage(),
    ),
  );
}

class HomeClientPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeClientPage> createState() => _HomeClientPageState();
}

class _HomeClientPageState extends ConsumerState<HomeClientPage> {

  String _currentFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider);
    // On récupère le notifier pour accéder aux getters (userID, etc.)
    final securityNotifier = ref.read(currentUserProvider.notifier);
    final userName = securityNotifier.loggedUserName;
    final userID = securityNotifier.userID;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/recherche_restaurants'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => Navigator.pushReplacementNamed(context, '/homeClient'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ($userName)',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
              securityNotifier.logout();
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  'mercredi 04/12/2024 16:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {_currentFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentFilter = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              // Si non connecté, alors le rond tourne, sinon, on fetch
              child: userID == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<dynamic>>(
                // On appelle ta fonction avec l'ID du notifier
                future: Security.getClientReservations(userID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allReservations = snapshot.data ?? [];

                  final reservations = allReservations.where((res) {
                    if (_currentFilter == 'all') return true;
                    return res['status'] == _currentFilter;
                  }).toList();

                  if (reservations.isEmpty) {
                    return const Center(child: Text('Aucune réservation trouvée.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final res = reservations[index];

                      // On définit l'icône et la couleur selon le statut reçu de SQL
                      IconData statusIcon;
                      Color statusColor;
                      switch (res['status']) {
                        case 'confirmed':
                          statusIcon = Icons.check_circle;
                          statusColor = Colors.green;
                          break;
                        case 'pending':
                          statusIcon = Icons.pending;
                          statusColor = Colors.orange;
                          break;
                        case 'cancelled':
                          statusIcon = Icons.cancel;
                          statusColor = Colors.red;
                          break;
                        default:
                          statusIcon = Icons.event_available;
                          statusColor = Colors.blue;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () async {
                            // 1. Log des infos dans la console
                            print("--- Détails de la réservation cliquée ---");
                            print("ID: ${res['id']}");
                            print("Titre (Resto): ${res['resto_name']}");
                            print("Adresse (Ville): ${res['city']}");
                            print("Date: ${res['datetime']}");
                            print("Status: ${res['status']}");
                            print("------------------------------------------");

                            await Navigator.pushNamed(
                              context,
                              '/details_reservation',
                              arguments: res, // On passe l'objet 'res' complet à la page suivante
                            );

                            // si on retourne de detail_reservation, la view s'update
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Tooltip(
                                  message: res['status'],
                                  child: Icon(statusIcon, size: 32, color: statusColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        res['resto_name'], // Donnée dynamique
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            res['city'], // Donnée dynamique
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.parse(res['datetime'])),
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.people, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${res['number_of_guests']} convives', // Donnée dynamique
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/recherche_restaurants'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
