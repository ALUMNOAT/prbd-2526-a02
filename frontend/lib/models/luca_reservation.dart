import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/user.dart';
import '../core/services/api_client.dart';

class Luca_Reservation {
  final int id;
  final int client_id;
  final int restaurant_id;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  User? client;
  Restaurant? restaurant;

  Luca_Reservation({
    required this.id,
    required this.client_id,
    required this.restaurant_id,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
    this.client,
    this.restaurant,
  });

  factory Luca_Reservation.fromJson(
      Map<String, dynamic> json,
      {
        User? client_obj,
        Restaurant? restaurant_obj
      }) {
    return Luca_Reservation(
      id: json['id'],
      client_id: json['client'],
      restaurant_id: json['restaurant'],
      datetime: (json['datetime'] != null)
          ? DateTime.tryParse(json['datetime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      numberOfGuests: json['number_of_guests'],
      status: Status.values.byName(json['status']),
      specialRequests: json['special_requests'],
      client: client_obj,
      restaurant: restaurant_obj,
    );
  }

  Future<User> getClient() async {
    return await User.getUserById(client_id);
  }

  Future<void> setClient() async {
    client = await getClient();
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

  //STATIC
  static Future<Luca_Reservation> getReservationFromId(int reservationId) async {
    final response = await ApiClient.post(
      'get_reservation_by_id',
      body: json.encode({'reservation_id': reservationId}),
    );

    if (response.statusCode == 200) {
      final reservation = Luca_Reservation.fromJson(json.decode(response.body));

      // not optimal :
      reservation.restaurant = await Restaurant.getRestaurantById(reservation.restaurant_id);
      reservation.client = await User.getUserById(reservation.client_id);

      return reservation;
    } else {
      throw Exception('${response.statusCode}: Failed to get restaurant from restaurant id');
    }
  }
}