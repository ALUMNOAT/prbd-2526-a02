import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/user.dart';
import '../core/services/api_client.dart';

class MyReservation {
  // ATTRIBUTES
  final int id;
  final int clientId;
  final int restaurantId;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;

  // CONSTRUCTOR
  MyReservation({
    required this.id,
    required this.clientId,
    required this.restaurantId,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
  });

  // FACTORY
  factory MyReservation.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colClientId = 'client',
    colRestaurantId = 'restaurant',
    colDatetime = 'datetime',
    colNumberOfGuests = 'number_of_guests',
    colStatus = 'status',
    colSpecialRequests = 'special_requests',
  }) {
    return MyReservation(
      id: json[colId],
      clientId: json[colClientId],
      restaurantId: json[colRestaurantId],
      datetime: DateTime.parse(json[colDatetime].toString()),
      numberOfGuests: json[colNumberOfGuests],
      status: Status.values.byName(json[colStatus]),
      specialRequests: json[colSpecialRequests],
    );
  }

  // COPY WITH
  MyReservation copyWith({
    int? id,
    int? clientId,
    int? restaurantId,
    DateTime? datetime,
    int? numberOfGuests,
    Status? status,
    String? specialRequests,
  }) {
    return MyReservation(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        restaurantId: restaurantId ?? this.restaurantId,
        datetime: datetime ?? this.datetime,
        numberOfGuests: numberOfGuests ?? this.numberOfGuests,
        status: status ?? this.status,
        specialRequests: specialRequests ?? this.specialRequests
    );
  }

  Future<void> complete_reservation() async {
    log("luca_reservation complete_reservation() ->");

    final response = await ApiClient.post(
      'complete_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({'id': id}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }

  Future<void> cancel_reservation() async {
    log("luca_reservation cancel_reservation() ->");

    final response = await ApiClient.post(
      'cancel_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({'id': id}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }
}