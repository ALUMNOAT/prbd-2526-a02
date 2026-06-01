import 'dart:convert';

import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import '../core/services/api_client.dart';

class Manager extends User {
  final List<Restaurant> restaurants = [];

  Manager({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.phone
  }){
    setRestaurants();
  }

  static Future<Manager> fromJson(json) async {
    return Manager(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      // see Peter Gyarmati's answer :
      // https://stackoverflow.com/questions/27673781/enum-from-string
      role: Role.values.byName(json['role']),
      phone: json['phone'],
    );
  }


  void setRestaurants() async {
    restaurants.addAll(await Restaurant.getRestaurantsByManager());
  }

  static Future<Manager> getCurrentManager() async {
    final response = await ApiClient.get('get_current_user');

    if (response.statusCode == 200) {
      return Manager.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get current user');
    }
  }
}