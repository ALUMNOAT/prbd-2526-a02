import 'package:prbd_2526_a02/models/security.dart';

enum Role {
  client, manager
}

class User {
  final int _id;
  final String _email;
  final String _password;
  final String _full_name;
  final Role _role;
  String? _phone;

  User(this._id, this._email, this._password, this._full_name, this._role);

  int get id => _id;


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