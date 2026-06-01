import 'dart:convert';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

enum Status {
  pending, confirmed, cancelled, completed
}

class Reservation {
  final int id;
  final User client;
  final Restaurant restaurant;
  DateTime datetime;
  int numberOfGuests;
  Status status;
  String? specialRequest;

  // (1) using private named parameters require a boilerplate :(
  // only in dart 3.13 can this be bypassed... so let's make 'em public :/
  // https://dart.dev/language/constructors#private-named-parameters
  Reservation({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequest,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      client: json['client'], // welp, that won't do...
      restaurant: json['restaurant'], //neither here
      datetime: json['datetime'],
      numberOfGuests: json['number_of_guests'],
      status: Status.values.byName(json['status']),
      specialRequest: json['special_requests'],
    );
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

  static Future<List<Restaurant>> getRestaurantsByManager(User owner) async {
    final response = await ApiClient.post(
      'get_restaurants_by_manager',
      body: json.encode({'user_id': owner.id}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get restaurant from id');
    }
  }
}
