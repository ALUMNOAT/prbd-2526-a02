import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/user.dart';

class Restaurant {
  final int id;
  final String name;
  final String city;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;
  final List<Luca_Reservation> reservations;

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
  String get getPricing {
    return priceRange == null
        ? '?'
        : '€' * priceRange!; // added '!' because we know it's not null here
  }


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
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Luca_Reservation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get restaurant reservations from restaurant id');
    }
  }

  static Future<Restaurant> getRestaurantById(int id) async {
    final response = await ApiClient.post(
      'get_restaurant_by_id',
      body: json.encode({'id': id}),
    );
    if (response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get restaurant from id');
    }
  }

  static Future<List<Restaurant>> getRestaurantsByManager() async {
    final response = await ApiClient.get('get_restaurants_by_manager');
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get restaurant from id');
    }
  }
}
