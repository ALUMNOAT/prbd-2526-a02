import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/security_provider.dart';

import '../models/user.dart';

final managerProvider = AsyncNotifierProvider<ManagerNotifier, Manager>(
      () => ManagerNotifier(),
);

class ManagerNotifier extends AsyncNotifier<Manager> {
  @override
  Future<Manager> build() async {
    ref.watch(securityProvider);
    state = AsyncLoading();
    return await Manager.getCurrentManager();
  }

  Future<void> getManagerRestaurants() async {
    state = const AsyncValue.loading();
    try {
      final restaurants = await Restaurant.getRestaurantsByManager();
      state = AsyncData(favorites);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }
}
