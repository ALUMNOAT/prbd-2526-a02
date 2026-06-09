import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/luca_provider/luca_reservation_provider.dart';

import '../../providers/luca_provider/restaurant_provider.dart';
import '../Widgets/reservation_card.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: /*const*/ RestaurantManagementReservationPage(),
    ),
  );
}

class RestaurantManagementReservationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<RestaurantManagementReservationPage> createState() => _RestaurantManagementReservationState();
}

class _RestaurantManagementReservationState extends ConsumerState<RestaurantManagementReservationPage> {
  @override
  Widget build(BuildContext context) {
    final restaurantId = ModalRoute.of(context)!.settings.arguments as int;
    final restaurantState = ref.watch(restaurant_provider(restaurantId));

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return restaurantState.when(
      data: (restaurant) => data(restaurant: restaurant, theme: theme, simulatedTime: simulatedTime, ),
      error: (err, stack) => Text(err.toString()),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class data extends StatelessWidget {
  const data({
    super.key,
    required this.restaurant,
    required this.theme,
    required this.simulatedTime,
  });

  final Restaurant restaurant;
  final ThemeData theme;
  final DateTime simulatedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //BAR
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(restaurant.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
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

      //BODY
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
                selected: const {'all'},
                onSelectionChanged: (_) {},
              ),
            ),
            const SizedBox(height: 8),
    
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if(restaurant.reservations.isEmpty)
                  Text("No reservations")
                else
                  for (var reservation in restaurant.reservations)
                    ReservationCard(
                      reservation: reservation,
                      restaurant: restaurant,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
        ],
      ),
    );
  }
}