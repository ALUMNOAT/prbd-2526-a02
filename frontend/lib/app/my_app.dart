import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prbd_2526_a02/views/login.dart';
import '../providers/security_provider.dart';
import '../views/mes_reservations.dart';
import '../views/mes_restaurants.dart';
import '../views/signup.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityNotifier = ref.read(securityProvider.notifier);
    return MaterialApp(
      title: 'ReserVite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: securityNotifier.isLoggedIn ? '/homeClient' : '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homeClient': (context) => HomeClientPage(),
        '/homeManager': (context) => HomeManagerPage(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
