import 'dart:convert';
import 'dart:developer';

import 'package:prbd_2526_a02/models/MyRestaurant.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

import '../../models/MyReservation.dart';
import '../../models/MyService.dart';
import '../../models/MyTable.dart';

class ManagerState {
  // ATTRIBUTES
  final User user;
  final Map<int, Restaurant> restaurants;
  final Map<int, MyService> services;
  final Map<int, MyReservation> reservations;
  final Map<int, User> clients;
  final Map<int, MyTable> tables;

  // CONSTRUCTOR
  ManagerState({
    required this.user,
    required this.restaurants,
    required this.services,
    required this.reservations,
    required this.clients,
    required this.tables,
  });

  // COPY WITH
  ManagerState copyWith({
    User? user,
    Map<int, Restaurant>? restaurants,
    Map<int, MyService>? services,
    Map<int, MyReservation>? reservations,
    Map<int, User>? clients,
    Map<int, MyTable>? tables,
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

  static ManagerState? setupManagerState() async {
    final user = await User.getCurrentUser();
    final restaurant = await MyRestaurant.getManagerRestaurants(user.id);
    final services = await MyService.getManagerServices(user.id);
  }
}