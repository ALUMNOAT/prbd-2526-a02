import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/MyRestaurant.dart';
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
  // OBJECT ATTRIBUTES
  final MyRestaurant? restaurant;

  // CONSTRUCTOR
  MyTable({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
    this.restaurant,
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
    MyRestaurant? restaurant,
  }) {
    return MyTable(
        id: id ?? this.id,
        restaurantId: restaurantId ?? this.restaurantId,
        tableNumber: tableNumber ?? this.tableNumber,
        capacity: capacity ?? this.capacity,
        restaurant: restaurant ?? this.restaurant
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyTable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  // STATIC FUNCTIONS
  static Future<List<MyTable>> getManagerTables(int managerId) async {
    final response = await ApiClient.post(
      'get_manager_tables',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: Failed to get manager tables');
    }

    final List<dynamic> body = json.decode(response.body);
    List<MyTable> tables = body.map((dynamic item) =>
        MyTable.fromJson(item)
    ).toList();

    return tables;
  }
}