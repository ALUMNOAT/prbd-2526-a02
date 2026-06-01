import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:prbd_2526_a02/providers/security_provider.dart';

import '../core/tools/params.dart';
import '../models/security.dart';
import '../models/user.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, User>(
      () => UserNotifier(),
);

class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    ref.watch(securityProvider);
    state = AsyncLoading();
    return await User.getCurrentUser();
  }

}