import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/enums/role.dart';
import '../../models/restaurant.dart';
import '../../models/user.dart';
import 'ManagerState.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState?>(
      () => ManagerStateNotifier(),
);

//
class ManagerStateNotifier extends AsyncNotifier<ManagerState?> {
  @override
  Future<ManagerState?> build() async {
    //TODO: implement manager state build(), which hopefully is only called once !
    return null;
  }
}
