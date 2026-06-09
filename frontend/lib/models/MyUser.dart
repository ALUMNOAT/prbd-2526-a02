import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/enums/role.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class MyUser {
  // ATTRIBUTES
  final int id;
  final String email;
  final String fullName;
  final Role role;
  final String? phone;

  // CONSTRUCTOR
  MyUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  // FACTORY
  factory MyUser.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colEmail = 'email',
    colFullName = 'full_name',
    colRole = 'role',
    colPhone = 'phone',
  }) {
    return MyUser(
      id: json[colId],
      email: json[colEmail],
      fullName: json[colFullName],
      role: Role.values.byName(json[colRole]),
      phone: json[colPhone]
    );
  }

  // COPY WITH
  MyUser copyWith({
    int? id,
    String? email,
    String? fullName,
    Role? role,
    String? phone,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyUser && runtimeType == other.runtimeType && id == other.id;

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