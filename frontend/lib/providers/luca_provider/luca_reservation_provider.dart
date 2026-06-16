import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';

final luca_reservation_provider = AsyncNotifierProvider
    .autoDispose.family<Luca_ReservationNotifier, MyReservation?, int>(
      Luca_ReservationNotifier.new,
);

//
class Luca_ReservationNotifier extends AsyncNotifier<MyReservation?> {
  Luca_ReservationNotifier(this.id);
  final int id;

  @override
  Future<MyReservation?> build() async {
    return null;
  }
}