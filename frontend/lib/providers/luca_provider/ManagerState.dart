import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/MyRestaurant.dart';
import 'package:prbd_2526_a02/models/MyUser.dart';
import '../../models/MyReservation.dart';
import '../../models/MyService.dart';
import '../../models/MyTable.dart';
import '../../models/enums/Role.dart';
import '../../models/enums/Status.dart';


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
    return getLastReservationFromRestaurant(restaurantId) == null
        ? "Aucune réservations"
        : DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR')
        .format(getLastReservationFromRestaurant(restaurantId)!.datetime);
  }

  bool isTableOccupied(MyTable table, MyService service, DateTime dateTime) {
    final reservations_ = getServiceReservationsOnDateTime(service, dateTime);
    for(var reservation in reservations_) {
      final tables = getReservationTables(reservation.id);
      if(tables.contains(table)) {
        return true;
      }
    }

    return false;
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

  List<MyService> getReservationServices(MyReservation reservation) {
    final services_ = services.where((service) =>
    service.restaurantId == reservation.restaurantId &&
        service.isReservationInService(reservation)
    ).toList();

    return services_;
  }

  List<MyReservation> getRestaurantReservations(int restaurantId) {
    final reservations_ = reservations.where(
            (reservation) => reservation.restaurantId == restaurantId
    ).toList();

    reservations_.sort((a, b) => a.compareToTimewise(b));

    return reservations_;
  }

  List<MyReservation> getServiceReservationsOnDateTime(MyService service, DateTime dateTime) =>
  //https://stackoverflow.com/questions/52978195/comparing-only-dates-of-datetimes-in-dart
      reservations.where((reservation) =>
      reservation.restaurantId == service.restaurantId &&
          DateUtils.isSameDay(reservation.datetime, dateTime) &&
          service.isReservationInService(reservation)
      ).toList();

  List<MyReservation> getConcurrentReservations(MyReservation reservation) {
    final services_ = getReservationServices(reservation);
    final List<MyReservation> concurrentReservations = [];

    for(MyService service in services_) {
      concurrentReservations.addAll(reservations.where((otherReservation) =>
      otherReservation.restaurantId == reservation.restaurantId &&
          DateUtils.isSameDay(otherReservation.datetime, reservation.datetime) &&
          service.isReservationInService(otherReservation)
      ));
    }

    return concurrentReservations;
  }

  List<MyTable> getRestaurantTables(int restaurantId) =>
      tables.where(
          (table) => table.restaurantId == restaurantId
      ).toList();

  List<MyTable> getReservationTables(int reservationId) {
    final List<MyTable> tables_ = [];

    if(reservationTables[reservationId] != null) {
      for(int tablesId in reservationTables[reservationId]!) {
        tables_.addAll(tables.where((table) =>
            table.id == tablesId
        ));
      }
    }

    return tables_;
  }

  List<MyTable> getOccupiedTablesForReservation(MyReservation reservation) {
    final concurrentReservations = getConcurrentReservations(reservation);
    final List<MyTable> tables_ = [];
    for(MyReservation concurrentReservation in concurrentReservations) {
      tables_.addAll(getReservationTables(concurrentReservation.id));
    }
    return tables_;
  }

  List<MyTable> getAvailableTablesForReservation(int reservationId) {
    final reservation = getReservation(reservationId);
    final services = getRestaurantServices(reservation.restaurantId);
    final List<MyTable> tables_ = getRestaurantTables(reservation.restaurantId);

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