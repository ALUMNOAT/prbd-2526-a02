import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/MyRestaurant.dart';

import '../core/services/api_client.dart';

class MyService {
  // ATTRIBUTES
  final int id;
  final int restaurantId;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  // OBJECT ATTRIBUTES
  final MyRestaurant? restaurant;


  // CONSTRUCTOR
  MyService({
    required this.id,
    required this.restaurantId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.restaurant,
  });

  // FACTORY
  factory MyService.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colRestaurantId = 'restaurant',
    colDayOfWeek = 'day_of_week',
    colStartTime = 'start_time',
    colEndTime = 'end_time'
  }) {
    return MyService(
      id: json[colId],
      restaurantId: json[colRestaurantId],
      dayOfWeek: json[colDayOfWeek],
      startTime: stringToTimeOfDay(json[colStartTime]),
      endTime: stringToTimeOfDay(json[colEndTime]),
    );
  }

  // COPY WITH
  MyService copyWith({
    final int? id,
    final int? restaurantId,
    final int? dayOfWeek,
    final TimeOfDay? startTime,
    final TimeOfDay? endTime,
    final MyRestaurant? restaurant,

  }) {
    return MyService(
        id: id ?? this.id,
        restaurantId: restaurantId ?? this.restaurantId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        restaurant: restaurant ?? this.restaurant,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyService && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  // STATIC FUNCTIONS
  static Future<List<MyService>> getManagerServices(int managerId) async {
    final response = await ApiClient.post(
      'get_manager_services',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: Failed to get manager services');
    }

    final List<dynamic> body = json.decode(response.body);
    List<MyService> services = body.map((dynamic item) =>
        MyService.fromJson(item)
    ).toList();

    return services;
  }

  static TimeOfDay stringToTimeOfDay(String tod) {
    //https://stackoverflow.com/questions/53382971/how-to-convert-string-to-timeofday-in-flutter
    final timeList = tod.split(":");
    return TimeOfDay(
        hour: int.parse(timeList[0]),
        minute: int.parse(timeList[1])
    );
  }
}