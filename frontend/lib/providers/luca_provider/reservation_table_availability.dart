import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a02/providers/luca_provider/luca_reservation_provider.dart';
import 'package:prbd_2526_a02/providers/luca_provider/security_provider.dart';

import '../../models/table.dart';
import '../../models/user.dart';

//before login, we don't have a user, therefore our state should be null.
//got it. I'm sad that I have to use AI...
final reservation_table_availability_provider = AsyncNotifierProvider<ReservationTableAvailabilityNotifier, List<Table>?>(
      () => ReservationTableAvailabilityNotifier(),
);

class ReservationTableAvailabilityNotifier extends AsyncNotifier<List<Table>?> {
  @override
  Future<List<Table>?> build() async {
    log('reservation_table_availability build() ->');

    final luca_reservation = ref.watch(luca_reservation_provider).value;

    if(luca_reservation == null) {
      return null;
    }



    final user = await User.getCurrentUser();

    return user;
  }
}