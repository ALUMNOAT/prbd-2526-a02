import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_a02/core/tools/my_provider_observer.dart';

import 'app/my_app.dart';
import 'core/tools/params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Params.init();
  await initializeDateFormatting('fr_FR', null);

  runApp(
      ProviderScope(
          observers: [MyProviderObserver()],
          retry: (int _, Object _) => null,
          child: MyApp(),
      ),
  );
}