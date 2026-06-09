import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class MyRestaurant {
  // ATTRIBUTES
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;

  // CONSTRUCTOR
  MyRestaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.description,
    this.rating,
    this.priceRange,
    required this.slotDuration,
  });

  // FACTORY
  factory MyRestaurant.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colName = 'name',
    colAddress = 'address',
    colCity = 'city',
    colPhone = 'phone',
    colDescription = 'description',
    colRating = 'rating',
    colPriceRange = 'price_range',
    colSlotDuration = 'slot_duration'
  }) {
    return MyRestaurant(
      id: json[colId],
      name: json[colName],
      address: json[colAddress],
      city: json[colCity],
      phone: json[colPhone],
      description: json[colDescription],
      rating: json[colRating],
      priceRange: json[colPriceRange],
      slotDuration: json[colSlotDuration],
    );
  }

  // COPY WITH
  MyRestaurant copyWith({
    int? id,
    String? name,
    String? address,
    String? city,
    String? phone,
    String? description,
    double? rating,
    int? priceRange,
    int? slotDuration,
  }) {
    return MyRestaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      priceRange: priceRange ?? this.priceRange,
      slotDuration: slotDuration ?? this.slotDuration,

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
      other is MyRestaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  Future<List<MyReservation>> getReservations() async {
    log("restaurant getReservations() ->");

    final response = await ApiClient.post(
      'get_restaurant_reservations_by_id',
      body: json.encode({'restaurant_id': id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      List<MyReservation> reservations = body.map(
              (dynamic item) => MyReservation.fromJson(item, restaurant_obj: this)
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

  static Future<MyRestaurant> getRestaurantById(int id) async {
    log("restaurant getRestaurantById() ->");

    final response = await ApiClient.post(
      'get_restaurant_by_id',
      body: json.encode({'restaurant_id': id}),
    );

    if (response.statusCode == 200) {
      final restaurant = MyRestaurant.fromJson(json.decode(response.body));
      await restaurant.setReservations();
      return restaurant;
    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant from restaurant id');
    }
  }

  static Future<MyRestaurant> getManagerRestaurants(int managerId) async {
    log("restaurant getRestaurantById() ->");

    final response = await ApiClient.post(
      'get_manager_restaurants',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode == 200) {
      final restaurant = MyRestaurant.fromJson(json.decode(response.body));
      await restaurant.setReservations();
      return restaurant;
    } else {
      throw Exception('${response.statusCode}: Failed to get manager restaurants');
    }
  }
}
