import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final manager_provider = AsyncNotifierProvider<ManagerNotifier, Manager?>(
      () => ManagerNotifier(),
);

//
class ManagerNotifier extends AsyncNotifier<Manager?> {
  @override
  Future<Manager?> build() async {
    final user = ref.watch(user_provider).value;

    if(user == null || user.role != Role.manager) {
      return null;
    }

    return Manager(
        user: user,
        restaurants: await Manager.getRestaurantsByCurrentManager()
    );
  }
}
