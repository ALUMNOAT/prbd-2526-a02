import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/core/services/api_client.dart';

class Security {
  /// Function returns a JWT token (string)
  static Future<String?> login(String email, String password) async {
    final response = await ApiClient.post(
      'login',
      body: json.encode( /// Function has 2 parameters
          {
            'email': email,
            'password': password
          }),
      anonymous: true,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
    final dynamic body = json.decode(response.body);
    String token = body['token'];
    return token;
  }

  /// Function returns nothing
  static Future<void> reset_database() async {
    final response = await ApiClient.post(
      'reset_database',
      body: json.encode({}), /// Function has no parameters
      anonymous: true,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to reset the database');
    }
    return;
  }

  /// Function returns bool
  static Future<bool> checkEmailAvailable({String? email}) async {
    final response = await ApiClient.post(
      'is_email_available',
      body: json.encode({'email': email}),
      anonymous: true,
    );
    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to validate email\n\n${body['message']}');
    }
    return body;
  }

  /// Function returns bool
  static Future<bool> checkNameAvailable({String? name}) async {
    final response = await ApiClient.post(
      'is_name_available',
      body: json.encode({'name': name}),
      anonymous: true,
    );
    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to validate name\n\n${body['message']}');
    }
    return body;
  }

  /// Function returns nothing (insertion)
  static Future<void> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await ApiClient.post(
      'signup',
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone
      }),
      anonymous: true,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to signup\n\n${response.body}');
    }
  }

  /// Function returns a list
  static Future<List<dynamic>> getClientReservations(String userID) async {
    final response = await ApiClient.get(
      'getclientreservations?userid=$userID',
      anonymous: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to gather reservations');
    }
  }

  /// Function returns void
  static Future<void> annuler_reservation ({
    required int id
}) async {
    final response = await ApiClient.post(
      'clientannulerreservation',
      body: json.encode({
        '_id': id,
      }),
      anonymous: false,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to cancel reservation\n\n${response.body}');
    }
  }

  /// Function returns a list
  static Future<List<dynamic>> getAllClientRestaurantsReservations(String userID) async {
    final response = await ApiClient.get(
      'getclientallrestaurantreservationsandservices?userid=$userID',
      anonymous: false,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to gather restaurant/reservations');
    }
  }

  static Future<void> addReservation({
    required int clientId,
    required int restaurantId,
    required DateTime datetime,
    required int nbConvives,
    String? specialRequests,
  }) async {
    final response = await ApiClient.post(
      'add_reservation',
      body: json.encode({
        'p_client': clientId,
        'p_restaurant': restaurantId,
        'p_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
        'p_guests': nbConvives,
        'p_special_requests': (specialRequests == null || specialRequests.trim().isEmpty)
            ? null
            : specialRequests,
      }),
      anonymous: false,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to add reservation');
    }
  }

  static Future<void> editReservation({
    required int id,
    required DateTime datetime,
    required int nbConvives,
    String? specialRequests
  }) async {
    final response = await ApiClient.post(
      'edit_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({
        'p_id': id,
        'p_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
        'p_guests': nbConvives,
        'p_special_requests': (specialRequests == null || specialRequests.trim().isEmpty)
            ? null
            : specialRequests,
      }),
      anonymous: false,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }
}