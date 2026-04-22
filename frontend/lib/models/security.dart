import 'dart:convert';

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

}