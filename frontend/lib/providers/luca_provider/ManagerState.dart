import 'dart:async';

import 'package:prbd_2526_a02/models/MyRestaurant.dart';
import 'package:prbd_2526_a02/models/MyUser.dart';
import '../../models/MyReservation.dart';
import '../../models/MyService.dart';
import '../../models/MyTable.dart';
import '../../models/enums/role.dart';
import '../../models/enums/status.dart';


class ManagerState {
  // OBJECT ATTRIBUTES
  final MyUser user;
  final List<MyRestaurant> restaurants;
  final List<MyService> services;
  final List<MyReservation> reservations;
  final List<MyUser> clients;
  final List<MyTable> tables;
  final Map<int, List<int>> reservationTables;


  // CONSTRUCTOR
  ManagerState({
    required this.user,
    required this.restaurants,
    required this.services,
    required this.reservations,
    required this.clients,
    required this.tables,
    required this.reservationTables,
  });

  // COPY WITH
  ManagerState copyWith({
    MyUser? user,
    List<MyRestaurant>? restaurants,
    List<MyService>? services,
    List<MyReservation>? reservations,
    List<MyUser>? clients,
    List<MyTable>? tables,
    Map<int, List<int>>? reservationTables,
  }) {
    return ManagerState(
      user: user ?? this.user,
      restaurants: restaurants ?? this.restaurants,
      services: services ?? this.services,
      reservations: reservations ?? this.reservations,
      clients: clients ?? this.clients,
      tables: tables ?? this.tables,
      reservationTables: reservationTables ?? this.reservationTables,
    );
  }

  // GETS
  int pendingCount(int restaurantId) =>
      reservations.where((reservation) =>
      reservation.restaurantId == restaurantId &&
      reservation.status == Status.pending
      ).toList().length;

  String? getLastReservationDateFromRestaurant(int restaurantId) {
    return getLastReservationFromRestaurant(restaurantId)?.datetime.toString();
  }

  MyRestaurant getRestaurant(int restaurantId) =>
      restaurants.where(
              (restaurant) => restaurant.id == restaurantId
      ).toList()[0];

  MyRestaurant getRestaurantFromReservation(int reservationId) =>
      restaurants.where(
              (restaurant) => restaurant.id == getReservation(reservationId).restaurantId
      ).toList()[0];

  MyReservation getReservation(int reservationId) =>
      reservations.where(
              (reservation) => reservation.id == reservationId
      ).toList()[0];

  MyReservation? getLastReservationFromRestaurant(int restaurantId) {
    var restaurantReservation = reservations.where(
            (reservation) => reservation.restaurantId == restaurantId
    ).toList();

    restaurantReservation.sort((a, b) =>
      a.datetime.isAfter(b.datetime) ? 0 : 1
    );

    return restaurantReservation.isNotEmpty
        ? restaurantReservation[0]
        : null;
  }

  MyUser getClient(int clientId) =>
      clients.where(
              (client) => client.id == clientId
      ).toList()[0];

  MyUser getClientFromReservation(int reservationId) =>
      clients.where(
              (client) => client.id == getReservation(reservationId).clientId
      ).toList()[0];

  List<MyRestaurant> getRestaurantsOrderByLastReservation() {
    restaurants.sort((a, b) {
      var aLast = getLastReservationFromRestaurant(a.id);
      var bLast = getLastReservationFromRestaurant(b.id);

      if (aLast == null) {return 1;}
      else if (bLast == null) {return 0;}
      return aLast.datetime.isAfter(bLast.datetime) ? 0 : 1;
    });

    return restaurants;
  }

  List<MyService> getRestaurantServices(int restaurantId) =>
      services.where(
              (service) => service.restaurantId == restaurantId
      ).toList();

  List<MyReservation> getRestaurantReservations(int restaurantId) =>
      reservations.where(
              (reservation) => reservation.restaurantId == restaurantId
      ).toList();

  List<MyTable> getRestaurantTables(int restaurantId) =>
      tables.where(
          (table) => table.restaurantId == restaurantId
      ).toList();

  List<MyTable> getReservationTables(int reservationId) {
    final List<MyTable> tables_ = [];

    if(reservationTables[reservationId] != null) {
      for(int tablesId in reservationTables[reservationId]!) {
        tables_.add(tables[tablesId]);
      }
    }

    return tables_;
  }



  // STATIC
  static Future<ManagerState?> setupManagerState({MyUser? givenUser}) async {
    final user = givenUser ?? await MyUser.getCurrentUser();

    if(user.role != Role.manager) {
      return null;
    }

    //The calls are all called at the same time.
    final restaurantsFuture = MyRestaurant.getManagerRestaurants(user.id);
    final servicesFuture = MyService.getManagerServices(user.id);
    final reservationsFuture = MyReservation.getManagerReservations(user.id);
    final clientsFuture = MyUser.getManagerClients(user.id);
    final tablesFuture = MyTable.getManagerTables(user.id);
    final reservationTablesFuture = MyTable.getManagerReservationTables(user.id);

    //the results are then awaited here
    final managerState = ManagerState(
        user: user,
        restaurants: await restaurantsFuture,
        services: await servicesFuture,
        reservations: await reservationsFuture,
        clients: await clientsFuture,
        tables: await tablesFuture,
        reservationTables: await reservationTablesFuture
    );

    return managerState;
  }
}