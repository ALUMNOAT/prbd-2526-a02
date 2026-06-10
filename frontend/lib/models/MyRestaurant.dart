import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/MyService.dart';
import 'package:prbd_2526_a02/models/MyTable.dart';
import 'package:prbd_2526_a02/models/reservation.dart';
import 'package:prbd_2526_a02/models/user.dart';

import 'enums/status.dart';

class MyRestaurant {
  // ATTRIBUTES
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;
  // OBJECT ATTRIBUTES
  final List<MyService> services;
  final List<MyReservation> reservations;
  final List<MyTable> tables;

  // CONSTRUCTOR
  MyRestaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.description,
    this.rating,
    this.priceRange,
    required this.slotDuration,
    this.services = const [],
    this.reservations = const [],
    this.tables = const [],
  });

  // FACTORY
  factory MyRestaurant.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colName = 'name',
    colAddress = 'address',
    colCity = 'city',
    colPhone = 'phone',
    colDescription = 'description',
    colRating = 'rating',
    colPriceRange = 'price_range',
    colSlotDuration = 'slot_duration'
  }) {
    return MyRestaurant(
      id: json[colId],
      name: json[colName],
      address: json[colAddress],
      city: json[colCity],
      phone: json[colPhone],
      description: json[colDescription],
      rating: json[colRating],
      priceRange: json[colPriceRange],
      slotDuration: json[colSlotDuration],
    );
  }

  // COPY WITH
  MyRestaurant copyWith({
    int? id,
    String? name,
    String? address,
    String? city,
    String? phone,
    String? description,
    double? rating,
    int? priceRange,
    int? slotDuration,
    List<MyService>? services,
    List<MyReservation>? reservations,
    List<MyTable>? tables,
  }) {
    return MyRestaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      priceRange: priceRange ?? this.priceRange,
      slotDuration: slotDuration ?? this.slotDuration,
      services: services ?? this.services,
      reservations: reservations ?? this.reservations,
      tables: tables ?? this.tables,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyRestaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  // GETS
  String get euroPricing => priceRange == null
      ? '?'
      : '€' * priceRange!;



  // STATIC FUNCTIONS
  static Future<List<MyRestaurant>> getManagerRestaurants(int managerId) async {
    final response = await ApiClient.post(
      'get_manager_restaurants',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: Failed to get manager restaurants');
    }

    final List<dynamic> body = json.decode(response.body);
    List<MyRestaurant> restaurants = body.map((dynamic item) =>
        MyRestaurant.fromJson(item)
    ).toList();

    return restaurants;
  }
}
