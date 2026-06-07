import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/providers/luca_provider/security_provider.dart';
import 'dart:developer';

import '../../models/manager.dart';
import '../../providers/luca_provider/manager_provider.dart';
import '../../providers/luca_provider/restaurant_provider.dart';
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
    final managerState = ref.watch(manager_provider);
    final securityNotifier = ref.watch(security_provider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return managerState.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text(err.toString()),
      data: (manager) {
        if (manager == null) {
          return const Text("No manager found");
        }

        return Scaffold(
          appBar: MyAppBar(
              userName: manager.user.fullName,
              securityNotifier: securityNotifier,
              theme: theme,
              simulatedTime: simulatedTime
          ),

          body: MyBody(
              managerState: manager,
          ),

        );
      },
    );
  }
}


// (1) appBar in a Scaffold needs PreferredSizeWidget. See Smebes's answer.
// https://stackoverflow.com/questions/52678469/the-appbardesign-cant-be-assigned-to-the-parameter-type-preferredsizewidget
class MyAppBar extends StatelessWidget implements PreferredSizeWidget{  //(1)
  const MyAppBar({
    super.key,
    required this.userName,
    required this.securityNotifier,
    required this.theme,
    required this.simulatedTime,
  });

  final String? userName;
  final SecurityNotifier securityNotifier;
  final ThemeData theme;
  final DateTime simulatedTime;

  @override // (1)
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}

class MyBody extends StatelessWidget {
  const MyBody({
    super.key,
    required this.managerState,
  });

  final Manager managerState;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          //https://stackoverflow.com/questions/58471237/the-element-type-settext-cant-be-assigned-to-the-list-type-widget
          for (var restaurant in managerState.restaurants)
            RestaurantCard(
                restaurant : restaurant,
            ),
        ],
      ),
    );
  }
}

