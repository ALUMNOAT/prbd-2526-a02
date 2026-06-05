import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final luca_reservation_provider = AsyncNotifierProvider<Luca_ReservationNotifier, Luca_Reservation?>(
      () => Luca_ReservationNotifier(),
);

//
class Luca_ReservationNotifier extends AsyncNotifier<Luca_Reservation?> {
  @override
  Future<Luca_Reservation?> build() async {
    return null;
  }

  Future<void> set_current_luca_reservation(Luca_Reservation luca_reservation) async {
    log("luca_reservation_provider set_current_luca_reservation() ->");
    await luca_reservation.setClient();
    state = AsyncData(luca_reservation);
  }
}