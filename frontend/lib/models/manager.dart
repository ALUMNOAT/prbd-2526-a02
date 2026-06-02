import 'dart:convert';

import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import '../core/services/api_client.dart';

class Manager {
  // composition is simpler than extension in this case, simply because we use
  // providers that can handle any user-related functions already.
  final User? user;
  final List<Restaurant> restaurants;

  Manager({
    required this.user,
    this.restaurants = const [],
  });

  static Future<List<Restaurant>> getRestaurantsByCurrentManager() async {
    final response = await ApiClient.get(
      'get_restaurants_by_current_manager',
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get restaurants of current manager');
    }
  }
}