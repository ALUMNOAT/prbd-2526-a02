import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class Restaurant {
  final int id;
  final String name;
  final String city;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;
  List<Luca_Reservation> reservations;

  // (1) using private named parameters require a boilerplate :(
  // only in dart 3.13 can this be bypassed... so let's make 'em public :/
  // https://dart.dev/language/constructors#private-named-parameters
  Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    this.description,
    this.rating,
    this.priceRange,
    required this.slotDuration,
    this.reservations = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      phone: json['phone'],
      description: json['description'],
      rating: json['rating'],
      priceRange: json['price_range'],
      slotDuration: json['slot_duration'],
    );
  }

  //https://stackoverflow.com/questions/65343818/whats-the-meaning-of-arrow-in-dart-flutter
  String get euroPricing {
    return priceRange == null
        ? '?'
        : '€' * priceRange!; // added '!' because we know it's not null here
  }

  //https://stackoverflow.com/questions/59423646/how-to-filter-a-list-with-condition-in-dart
  int get pendingCount =>
    reservations.where((reservation) => reservation.status == Status.pending).toList().length;

  /*
   * L'utilisation de runtimeType dans la surcharge de l'opérateur == permet de s'assurer
   * que l'objet other est exactement de la même classe que this. Cela évite des comparaisons
   * entre objets d'une classe dérivée ou d'un autre type qui aurait des propriétés similaires.
   */
  @override
  bool operator == (Object other) => identical(this, other) ||
    other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  Future<List<Luca_Reservation>> getReservations() async {
    log("restaurant getReservations() ->");

    final response = await ApiClient.post(
      'get_restaurant_reservations_by_id',
      body: json.encode({'restaurant_id': id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      List<Luca_Reservation> reservations = body.map(
              (dynamic item) => Luca_Reservation.fromJson(item, restaurant_obj: this)
      ).toList();
      reservations.forEach((reservation) async => await reservation.setClient());

      return reservations;

    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant reservations from restaurant id');
    }
  }

  Future<void> setReservations() async {
    reservations = await getReservations();
  }

  static Future<Restaurant> getRestaurantById(int id) async {
    log("restaurant getRestaurantById() ->");

    final response = await ApiClient.post(
      'get_restaurant_by_id',
      body: json.encode({'restaurant_id': id}),
    );

    if (response.statusCode == 200) {
      final restaurant = Restaurant.fromJson(json.decode(response.body));
      await restaurant.setReservations();
      return restaurant;
    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant from restaurant id');
    }
  }

  static Future<Restaurant> getManagerRestaurants(int managerId) async {
    log("restaurant getRestaurantById() ->");

    final response = await ApiClient.post(
      'get_manager_restaurants',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode == 200) {
      final restaurant = Restaurant.fromJson(json.decode(response.body));
      await restaurant.setReservations();
      return restaurant;
    } else {
      throw Exception('${response.statusCode}: Failed to get manager restaurants');
    }
  }
}
