import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final restaurant_provider = AsyncNotifierProvider
    .autoDispose.family<RestaurantNotifier, Restaurant, int>(
    //https://riverpod.dev/docs/concepts2/family explaining families
    RestaurantNotifier.new
);

class RestaurantNotifier extends AsyncNotifier<Restaurant> {
  //https://riverpod.dev/docs/concepts2/family
  RestaurantNotifier(this.id);
  final int id;

  @override
  Future<Restaurant> build() async {
    return Restaurant.getRestaurantById(id);
  }

  Future<void> set_current_restaurant(Restaurant restaurant) async {
    log("restaurant_provider set_current_restaurant() ->");
    state = AsyncData(restaurant);
  }
}