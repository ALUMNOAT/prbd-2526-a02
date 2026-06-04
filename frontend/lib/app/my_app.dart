import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prbd_2526_a02/views/creation_reservation.dart';
import 'package:prbd_2526_a02/views/detail_reservation.dart';
import 'package:prbd_2526_a02/views/detail_restaurant.dart';
import 'package:prbd_2526_a02/views/login.dart';
import 'package:prbd_2526_a02/views/recherche_restaurants.dart';
import '../providers/currentUserProvider.dart';
import '../views/manager/restaurant_management_reservations.dart';
import '../views/mes_reservations.dart';
import '../views/manager/my_restaurants.dart';
import '../views/signup.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(currentUserProvider);
    final securityNotifier = ref.read(currentUserProvider.notifier);

    return MaterialApp(
      title: 'ReserVite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      // --- ICI ON UTILISED LES DELEGATES DE LOCALISATION ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'), // Force le français sur l'app
      // -----------------------------------------------------

      initialRoute: securityNotifier.isLoggedIn ? '/homeClient' : '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homeClient': (context) => HomeClientPage(),
        '/homeManager': (context) => HomeManagerPage(),
        '/signup': (context) => SignupPage(),
        '/details_reservation': (context) => ReservationDetailsPage(),
        '/recherche_restaurants': (context) => SearchRestaurantsPage(),
        '/detail_restaurant': (context) => DetailRestaurantPage(),
        '/creation_reservation': (context) => ReservationFormPage(),
        '/restaurant_management_reservations': (context) => RestaurantManagementReservationPage()
      },
    );
  }
}
