import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/tools/params.dart';
import '../../models/security.dart';

final security_provider = AsyncNotifierProvider<SecurityNotifier, String?>(
  () => SecurityNotifier(),
);

class SecurityNotifier extends AsyncNotifier<String?> {
  // the security provider takes care of the JWT token.
  // it has a login, and a logout, and nothing else.

  @override
  Future<String?> build() async {
    log('security_provider build() ->');
    // the build method is automatically made into a loading state.
    // it searches for the token currently stored in the parameters. if none,
    // then the state is null, just like the token
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }

  // the security_provider talks with the security model. it wait for a token
  // to be returned from the login, which is sent to the API client.
  Future<void> login(String email, String password) async {
    log('security_provider login() -> using $email, $password');

    // the state is loading, waiting for the return of the login.
    state = const AsyncLoading();
    try {
      // the token is returned from the security model login's method.
      var token = await Security.login(email, password);
      Params.setValue('token', token);
      state = AsyncData(token);
    } catch (e) {
      //if an error occured, the state is in error
      state = AsyncError(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  // remove the token from both the parameters, and the security_provider
  void logout() {
    log('security_provider logout() ->');

    Params.clearValue('token');
    state = AsyncData(null);
  }

  // the following code isn't necessary, it will be moved to the user_provider:
  /*
  bool get isLoggedIn => loggedUser != null;

  String? get loggedUser => _getUserFromToken(state.value);

  static String? _getUserFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'];
    } catch (e) {
      return null;
    }
  }

  bool get isManager => _getRoleFromToken(state.value) == 'manager';

  static String? _getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }

  String? get loggedUserName => _getNameFromToken(state.value);

  static String? _getNameFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['name'];
    } catch (e) {
      return null;
    }
  }

  String? get userID => _getIDFromToken(state.value);

  static String? getUserIdFromToken(String? token) {
    return _getIDFromToken(token);
  }

  static String? _getIDFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id']?.toString();
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
    state = const AsyncLoading();
    try {
      await Security.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await login(email, password);
      state = AsyncData(Params.getValue('token'));
    } catch (e) {
      state = AsyncError("Signup failed", StackTrace.current);
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
   */
}
