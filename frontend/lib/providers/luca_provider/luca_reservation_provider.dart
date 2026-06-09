import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/manager.dart';
import 'package:prbd_2526_a02/providers/luca_provider/user_provider.dart';

import '../../models/restaurant.dart';
import '../../models/user.dart';

final luca_reservation_provider = AsyncNotifierProvider
    .autoDispose.family<Luca_ReservationNotifier, MyReservation, int>(
      Luca_ReservationNotifier.new,
);

//
class Luca_ReservationNotifier extends AsyncNotifier<MyReservation> {
  Luca_ReservationNotifier(this.id);
  final int id;

  @override
  Future<MyReservation> build() async {
    return MyReservation.getReservationFromId(id);
  }
}