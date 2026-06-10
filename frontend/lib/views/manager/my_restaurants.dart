import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/providers/luca_provider/ManagerStateProvider.dart';
import 'package:prbd_2526_a02/providers/luca_provider/security_provider.dart';

import '../../providers/luca_provider/ManagerState.dart';
import '../Widgets/restaurant_card.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeManagerPage(),
    ),
  );
}

class HomeManagerPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeManagerPage> createState() => _HomeManagerPageState();
}

class _HomeManagerPageState extends ConsumerState<HomeManagerPage> {
  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/71813090/flutter-riverpod-ref-read-vs-ref-listen-vs-ref-watch
    final managerState_ = ref.watch(managerStateProvider);

    final securityNotifier = ref.watch(security_provider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return managerState_.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text(err.toString()),
      data: (manager) {
        if (manager == null) {
          return Text("No manager found");
        }

        return data(
            manager: manager,
            securityNotifier: securityNotifier,
            theme: theme,
            simulatedTime: simulatedTime
        );
      },
    );
  }
}

class data extends StatelessWidget {
  const data({
    super.key,
    required this.manager,
    required this.securityNotifier,
    required this.theme,
    required this.simulatedTime,
  });

  final ManagerState manager;
  final SecurityNotifier securityNotifier;
  final ThemeData theme;
  final DateTime simulatedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes restaurants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => Navigator.pushReplacementNamed(context, '/homeManager'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion (${manager.user.fullName})',
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            //https://stackoverflow.com/questions/58471237/the-element-type-settext-cant-be-assigned-to-the-list-type-widget
            for (var restaurant in manager.getRestaurantsOrderByLastReservation())
              RestaurantCard(
                manager : manager,
                restaurant : restaurant,
              ),
          ],
        ),
      ),

    );
  }
}
