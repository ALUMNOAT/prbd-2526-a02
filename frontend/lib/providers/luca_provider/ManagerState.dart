import 'dart:convert';
import 'dart:developer';

import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import '../../models/MyService.dart';
import '../../models/myTable.dart';

class ManagerState {
  final User user;
  final Map<int, Restaurant> restaurants;
  final Map<int, MyService> services;
  final Map<int, Reservation> reservations;
  final Map<int, User> clients;
  final Map<int, MyTable> tables;

  ManagerState({
    required this.user,
    required this.restaurants,
    required this.services,
    required this.reservations,
    required this.clients,
    required this.tables,
  });

  ManagerState copyWith({
    User? user,
    final Map<int, Restaurant>? restaurants,
    final Map<int, MyService>? services,
    final Map<int, Reservation>? reservations,
    final Map<int, User>? clients,
    final Map<int, MyTable>? tables,
  }) {
    return ManagerState(
      user: user ?? this.user,
      restaurants: restaurants ?? this.restaurants,
      services: services ?? this.services,
      reservations: reservations ?? this.reservations,
      clients: clients ?? this.clients,
      tables: tables ?? this.tables,
    );
  }

}