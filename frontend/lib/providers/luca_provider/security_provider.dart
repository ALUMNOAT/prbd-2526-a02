import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // the build method builds the state, so this is good
    return Params.getValue('token');
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
}
