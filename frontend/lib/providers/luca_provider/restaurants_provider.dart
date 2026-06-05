import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/currentUserProvider.dart';
import 'package:prbd_2526_a02/providers/luca_provider/manager_provider.dart';

import '../../models/user.dart';

final restaurants_provider = AsyncNotifierProvider<RestaurantsNotifier, List<Restaurant>?>(
      () => RestaurantsNotifier(),
);

class RestaurantsNotifier extends AsyncNotifier<List<Restaurant>?> {
  @override
  Future<List<Restaurant>?> build() async {
    log('RestaurantsNotifier build() ->');

    final manager = ref.watch(manager_provider).value;

    return manager == null
        ? null
        : await Manager.getRestaurantsByCurrentManager();
  }
}
