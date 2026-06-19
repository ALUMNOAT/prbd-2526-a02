import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation.dart';
import 'currentUserProvider.dart';

final clientStateProvider = AsyncNotifierProvider<ClientStateNotifier, List<Reservation>>(
      () => ClientStateNotifier(),
);

class ClientStateNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  Future<List<Reservation>> build() async {
    final token = ref.watch(currentUserProvider.select((s) => s.value));
    final userId = CurrentUserNotifier.getUserIdFromToken(token);
    if (userId == null) return Future.value([]);
    // 1. Récupération des données brutes
    final rawData = await Reservation.getClientReservations(userId);
    return rawData.map((e) => Reservation.fromJson(e)).toList();
  }

  Future<void> addReservation({
    required int restaurantId,
    required int clientId,
    required DateTime datetime,
    required int nbConvives,
    String? specialRequests,
  }) async {
    state = const AsyncLoading();
    try {
      await Reservation.addReservation(
        clientId: clientId,
        restaurantId: restaurantId,
        datetime: datetime,
        nbConvives: nbConvives,
        specialRequests: specialRequests,
      );
      ref.invalidateSelf();
    } catch (e) {
      print("ERREUR DÉTAILLÉE : $e");
      state = AsyncError("Adding the reservation failed", StackTrace.current);
    }
  }

  Future<void> annuler_reservation({
    required int id
  }) async {
    state = const AsyncLoading();
    try {
      await Reservation.annuler_reservation(id: id);
      ref.invalidateSelf();
    } catch (e) {
      print("ERREUR DÉTAILLÉE : $e");
      state = AsyncError(
        "Cancelling the reservation $id failed.",
        StackTrace.current,
      );
    }
  }

  Future<void> editReservation({
    required int id,
    required DateTime datetime,
    required int nbConvives,
    required String specialRequests,
  }) async {
    state = const AsyncLoading();
    try {
      await Reservation.editReservation(
        id: id,
        datetime: datetime,
        nbConvives: nbConvives,
        specialRequests: specialRequests,
      );
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncError("Editing the reservation failed", StackTrace.current);
    }
  }
}