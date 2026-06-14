import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
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

  Future<MyReservation?> completeReservation(MyReservation reservation) async {
    state = const AsyncLoading();
    try {
      final completedReservation = await reservation.completeReservation();
      final manager = state.value!;
      manager.reservations.remove(reservation);
      manager.reservations.add(completedReservation);
      state = AsyncData(manager);
      return completedReservation;
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
      return null;
    }
  }

  Future<void> cancelReservation(MyReservation reservation) async {
    state = const AsyncLoading();
    final manager = state.value!;

    try {
      reservation.cancelReservation();
      manager.reservations.remove(reservation);
      manager.reservationTables.remove(reservation.id);

      reservation = reservation.copyWith(status: Status.cancelled);
      manager.reservations.add(reservation);
      state = AsyncData(manager);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}
