import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/status.dart';
import 'package:prbd_2526_a02/models/user.dart';
import '../core/services/api_client.dart';

class Luca_Reservation {
  final int id;
  final int client;
  final int restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;

  Luca_Reservation({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
  });

  factory Luca_Reservation.fromJson(
      Map<String, dynamic> json,
      User client,
      Restaurant restaurant) {
    return Luca_Reservation(
      id: json['id'],
      client: json['client'],
      restaurant: json['restaurant'],
      datetime: (json['datetime'] != null)
          ? DateTime.tryParse(json['datetime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      numberOfGuests: json['number_of_guests'],
      status: Status.values.byName(json['status']),
      specialRequests: json['special_requests'],
    );
  }
}