import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../providers/security_provider.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: DetailRestaurantPage(),
    ),
  );
}

class DetailRestaurantPage extends ConsumerStatefulWidget{
  @override
  ConsumerState<DetailRestaurantPage> createState() =>
      _DetailRestaurantPageState();
}

class _DetailRestaurantPageState extends ConsumerState<DetailRestaurantPage> {

  @override
  Widget build(BuildContext context) {
    ref.watch(securityProvider);
    final securityNotifier = ref.read(securityProvider.notifier);
    final userID = securityNotifier.userID;
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    // On récupère l'objet 'res' passé en argument de recherche_restaurants.dart (lors qu'on redirige)
    final res = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détails du restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/detail_restaurant',
              // Si on inclue pas argument lors du rechargement, il devient null = page plante
              arguments: res,
            ),
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
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                res['resto_name'],
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(res['rating']?.toString() ?? '0.0'),
                  const SizedBox(width: 16),
                  Text('€' * res['price_range']),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(res['city']),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      res['resto_address'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(res['description']),
              const SizedBox(height: 24),
              const Text(
                'Horaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Lundi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 1),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Mardi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 2),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Mercredi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 3),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Jeudi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 4),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Vendredi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 5),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Samedi',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 6),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Dimanche',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  getHoursForDay(res['services'], 7),
                                  style: const TextStyle(
                                      fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Réserver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getHoursForDay(List services, int dayNum) {
    // On filtre les services qui correspondent au jour (1=Lundi, ..., 7=Dimanche)
    final dayServices = services.where((s) => s['day_of_week'] == dayNum).toList();

    if (dayServices.isEmpty) return 'Fermé';

    // On trie par heure de début pour être sûr
    dayServices.sort((a, b) => a['start_time'].compareTo(b['start_time']));

    // On formate : "12:00 - 14:00, 19:00 - 22:30"
    return dayServices.map((s) {
      // On enlève les secondes (:00) pour faire plus propre si nécessaire avec .substring(0, 5)
      String start = s['start_time'].toString().substring(0, 5);
      String end = s['end_time'].toString().substring(0, 5);
      return '$start - $end';
    }).join(', ');
  }
}
