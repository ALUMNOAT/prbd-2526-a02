import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a02/providers/luca_provider/security_provider.dart';

import '../../models/user.dart';

//before login, we don't have a user, therefore our state should be null.
//got it. I'm sad that I have to use AI...
final user_provider = AsyncNotifierProvider<UserNotifier, User?>(
      () => UserNotifier(),
);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    log('user_provider build() ->');
    // since the build() method is a promise (a Future user will be given), the
    // Riverpod library automatically puts the state in a loading state.
    // the following code is not necessary, but doesn't break anything.
    // state = AsyncLoading();

    // ref.watch(...) observes the securityProvider object from the
    // security_provider.dart file, and any changes triggers a rebuild
    // of the UserState, which is stored in the userProvider.
    final security = ref.watch(security_provider);

    // 'token' is the JWT returned after login, and if its value is null, no
    // login occurred.
    final token = security.value;

    log('  -> user_provider attempting to return user now: ');
    if(token == null) {
      log('    -> the token is null !');
      return null;
    } else {
      log('    -> calling User.getCurrentUser()');
    }
    log('@@@@@@@@@@@@@@@@@@@ this is reached ! @@@@@@@@@@@@@@@@@@@@@@@@@@');

    final user = await User.getCurrentUser();

    log('################### this is never reached ? #######################');

    return user;
  }
}