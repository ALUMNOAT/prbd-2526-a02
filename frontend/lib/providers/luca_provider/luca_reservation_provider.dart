import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final luca_reservation_provider = AsyncNotifierProvider
    .autoDispose.family<Luca_ReservationNotifier, Luca_Reservation, int>(
      Luca_ReservationNotifier.new,
);

//
class Luca_ReservationNotifier extends AsyncNotifier<Luca_Reservation> {
  Luca_ReservationNotifier(this.id);
  final int id;

  @override
  Future<Luca_Reservation> build() async {
    return Luca_Reservation.getReservationFromId(id);
  }
}