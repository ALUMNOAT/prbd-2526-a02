import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final restaurant_provider = AsyncNotifierProvider<RestaurantNotifier, Restaurant?>(
      () => RestaurantNotifier(),
);

//
class RestaurantNotifier extends AsyncNotifier<Restaurant?> {
  @override
  Future<Restaurant?> build() async {
    return null;
  }

  Future<void> set_current_restaurant(Restaurant restaurant) async {
    state = AsyncData(restaurant);
  }
}