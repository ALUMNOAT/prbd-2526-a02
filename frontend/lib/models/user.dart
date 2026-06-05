import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/models/security.dart';
import '../core/services/api_client.dart';
import 'enums/role.dart';


class User {
  final int id;
  final String email;
  final String fullName;
  final Role role;
  final String? phone;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      // see Peter Gyarmati's answer :
      // https://stackoverflow.com/questions/27673781/enum-from-string
      role: Role.values.byName(json['role']),
      phone: json['phone'],
    );
  }

  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('get_current_user');

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get current user');
    }
  }

  static Future<User> getUserById(int id) async {
    final response = await ApiClient.post(
      'get_current_user',
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));;
    } else {
      throw Exception('Failed to get current user');
    }
  }


  // ###########
  // VALIDATIONS
  // ###########

  static String? validateName(String? name) {
    final nameRegex = RegExp(
      r"^[A-Za-z]"
    );
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 3) {
      return 'Name must have at least 3 caracters';
    }
    if (!nameRegex.hasMatch(name)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  static Future<String?> validateNameUnicity(String? value) async {
    var res = await Security.checkNameAvailable(name: value?.trim());
    return res ? null: 'Name not available';
  }

  static String? validateEmail(String? email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    var res = await Security.checkEmailAvailable(email: value?.trim());
    return res ? null : 'Email not available';
  }

  static String? validatePassword(String? value) {
    final pasRegex = RegExp(
        r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[,;.:!?/$%&@#])+'
    );
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must have at least 8 caracters';
    }
    if (!pasRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir : 1 chiffre, 1 majuscule, 1 minuscule et 1 caractère spécial.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;
    if (value != password) return 'password do not match';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleanedPhone = value.replaceAll(' ', '');

    // ^(\+32[1-9][0-9]{7,8})  -> Partie +32
    // |                       -> OU
    // (^0[1-9][0-9]{7,8})     -> Partie débutant par 0
    final phoneRegex = RegExp(r'^(\+32[1-9][0-9]{7,8}|0[1-9][0-9]{7,8})$');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Format invalide (ex: 0470123456 ou +32470123456)';
    }
    return null;
  }
}