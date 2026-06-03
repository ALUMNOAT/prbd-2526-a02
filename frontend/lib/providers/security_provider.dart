import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:prbd_2526_a02/providers/manager_provider.dart';
import 'package:prbd_2526_a02/providers/user_provider.dart';

import '../core/tools/params.dart';
import '../models/security.dart';
import '../models/user.dart';



final securityProvider = AsyncNotifierProvider<SecurityNotifier, String?>(
      () => SecurityNotifier(),
);

class SecurityNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    log("security_provider build() ->");
    // pour que le state soit initialisée de manière synchrone
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      var token = await Security.login(email, password);
      Params.setValue('token', token);
      state = AsyncData(token);

    } catch (e) {
      state = AsyncError(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  void logout() {
    Params.clearValue('token');
    state = AsyncData(null);
  }

  String? get userID => _getIDFromToken(state.value);
  int get userIdInt => int.parse(_getIDFromToken(state.value) ?? '0');

  String? get loggedUserName => _getNameFromToken(state.value);

  bool get isLoggedIn => loggedUser != null;

  String? get loggedUser => _getUserFromToken(state.value);

  bool get isManager => _getRoleFromToken(state.value) == 'manager';


  static String? _getIDFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id']?.toString();
    } catch (e) {
      return null;
    }
  }

  static String? _getNameFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['name'];
    } catch (e) {
      return null;
    }
  }

  static String? _getUserFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'];
    } catch (e) {
      return null;
    }
  }

  static String? _getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }


  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await Security.signup(name: name, email: email, password: password, phone: phone);
      await login(email, password);
      state = AsyncValue.data(Params.getValue('token'));
    } catch (e) {
      state = AsyncValue.error("Signup failed", StackTrace.current);
    }
  }

  Future<void> reset_database() async {
    // We don't set state = AsyncLoading() here because we don't want
    // to "log out" the user visually while the DB is resetting.
    try {
      await Security.reset_database();
    } catch (e) {
      state = AsyncError(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  Future<void> annuler_reservation({
    required int id
  }) async {
    try {
      await Security.annuler_reservation(id: id);
    } catch (e) {
      state = AsyncError(
          "Cancelling the reservation $id failed.",
          StackTrace.current,
      );
    }
  }


}