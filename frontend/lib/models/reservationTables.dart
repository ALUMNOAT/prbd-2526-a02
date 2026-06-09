import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';
import 'package:prbd_2526_a02/models/MyTable.dart';


import '../core/services/api_client.dart';

class ReservationTables {
  final MyReservation reservation;
  final List<MyTable>? tables;

  ReservationTables({
    required this.reservation,
    this.tables,
  });

  /*static Future<List<MyTable>?> getTablesByReservationId(int reservationId) async {
    final response = await ApiClient.post(
      'get_tables_by_reservations_id',
      body: json.encode({'reservation_id': reservationId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      List<MyTable> tables = body.map(
              (dynamic item) => MyTable.fromJson(item)
      ).toList();

      restaurants.forEach(
              (restaurant) async =>
          restaurant.reservations = await restaurant.getReservations()
      );

      return restaurants;
    } else {
      throw Exception('Failed to get restaurants of current manager');
    }
  }*/
}