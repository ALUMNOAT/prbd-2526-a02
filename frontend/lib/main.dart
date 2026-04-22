import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/my_app.dart';
import 'core/tools/params.dart';

void main() async {
  await Params.init();
  await initializeDateFormatting('fr_FR', null);
  runApp(ProviderScope(child: MyApp()));
}