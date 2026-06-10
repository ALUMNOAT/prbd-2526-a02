import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/providers/luca_provider/security_provider.dart';

import '../../models/MyUser.dart';
import '../../models/enums/role.dart';
import 'ManagerState.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState?>(
      () => ManagerStateNotifier(),
);

//
class ManagerStateNotifier extends AsyncNotifier<ManagerState?> {
  @override
  Future<ManagerState?> build() async {
    //TODO: implement manager state build(), which hopefully is only called once !
    final security = ref.watch(security_provider);
    final token = security.value;


    if(token == null) {
      return null;
    }

    final user = await MyUser.getCurrentUser();

    if(user.role != Role.manager) {
      return null;
    }

    return await ManagerState.setupManagerState(givenUser: user);
  }
}
