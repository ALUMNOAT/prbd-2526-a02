import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class MyTable {
  // ATTRIBUTES
  final int id;
  final int restaurantId;
  final int tableNumber;
  final int capacity;

  // CONSTRUCTOR
  MyTable({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
  });

  // FACTORY
  factory MyTable.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colRestaurantId = 'restaurant',
    colTableNumber = 'table_number',
    colCapacity = 'capacity',
  }) {
    return MyTable(
      id: json[colId],
      restaurantId: json[colRestaurantId],
      tableNumber: json[colTableNumber],
      capacity: json[colCapacity],
    );
  }

  // COPY WITH
  MyTable copyWith({
    int? id,
    int? restaurantId,
    int? tableNumber,
    int? capacity,
  }) {
    return MyTable(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyTable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;





  Future<List<MyReservation>> getReservations() async {
    log("mytable getReservations() ->");
    final restaurant = await Restaurant.getRestaurantById(restaurantId);

    final response = await ApiClient.post(
      'get_table_reservations_by_id',
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      List<MyReservation> reservations = body.map(
              (dynamic item) => MyReservation.fromJson(item)
      ).toList();

      reservations.forEach((reservation) async => await reservation.setClient());

      return reservations;

    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant reservations from restaurant id');
    }
  }
}