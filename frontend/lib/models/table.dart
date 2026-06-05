import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class Table {
  final int id;
  final int restaurant_id;
  final int table_number;
  final int capacity;
  Restaurant? restaurant;
  List<Luca_Reservation> reservations;

  // (1) using private named parameters require a boilerplate :(
  // only in dart 3.13 can this be bypassed... so let's make 'em public :/
  // https://dart.dev/language/constructors#private-named-parameters
  Table({
    required this.id,
    required this.restaurant_id,
    required this.table_number,
    required this.capacity,
    this.restaurant,
    this.reservations = const [],
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      restaurant_id: json['name'],
      table_number: json['city'],
      capacity: json['phone'],
    );
  }

  @override
  bool operator == (Object other) => identical(this, other) ||
      other is Table && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Future<List<Luca_Reservation>> getReservations() async {
    log("table getReservations() ->");
    final restaurant = await Restaurant.getRestaurantById(restaurant_id);

    final response = await ApiClient.post(
      'get_table_reservations_by_id',
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      List<Luca_Reservation> reservations = body.map(
              (dynamic item) => Luca_Reservation.fromJson(item, restaurant_obj: restaurant)
      ).toList();
      reservations.forEach((reservation) async => await reservation.setClient());

      return reservations;

    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant reservations from restaurant id');
    }
  }
}