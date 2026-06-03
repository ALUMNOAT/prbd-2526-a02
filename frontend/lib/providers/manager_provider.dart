import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/user_provider.dart';

import '../models/user.dart';

final managerProvider = AsyncNotifierProvider<ManagerNotifier, Manager?>(
      () => ManagerNotifier(),
);

class ManagerNotifier extends AsyncNotifier<Manager?> {
  @override
  Future<Manager?> build() async {
    log('manager_provider build() ->');
    //not necessary, but not bad per se
    //state = AsyncLoading();

    final user = ref.watch(userProvider).value;

    log('-> in the manager_provider, user name is  = ${user?.fullName}');


    if(user == null || user.role != Role.manager) {
      return null;
    }

    return Manager(
        user: user,
        restaurants: await Manager.getRestaurantsByCurrentManager()
    );
  }
}
