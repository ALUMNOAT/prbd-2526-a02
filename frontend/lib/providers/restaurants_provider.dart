import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/security_provider.dart';

import '../models/user.dart';

class RestaurantNotifier extends AsyncNotifier<List<Restaurant>> {
  @override
  Future<List<Restaurant>> build() async {
    ref.watch(securityProvider);
    state = AsyncData([]);
    return [];
  }

  Future<void> getAllRestaurants(User manager) async {
    state = const AsyncValue.loading();
    try {
      final restaurants = List<Restaurant>.from(await Restaurant.getRestaurantsByManager(manager));
      state = AsyncData(restaurants);
    } catch (e) {
      print(e);
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }
}
