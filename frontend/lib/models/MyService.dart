import 'package:flutter/material.dart';

class MyService {
  // ATTRIBUTES
  final int id;
  final int restaurantId;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  // CONSTRUCTOR
  MyService({
    required this.id,
    required this.restaurantId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // FACTORY
  factory MyService.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colRestaurantId = 'restaurant',
    colDayOfWeek = 'day_of_week',
    colStartTime = 'start_time',
    colEndTime = 'end_time'
  }) {
    //https://stackoverflow.com/questions/53382971/how-to-convert-string-to-timeofday-in-flutter
    // ^how to convert time string into TimeOfDay
    // TODO: convert !
    return MyService(
      id: json[colId],
      restaurantId: json[colRestaurantId],
      dayOfWeek: json[colDayOfWeek], //<-- convert here
      startTime: json[colStartTime], //<-- convert here
      endTime: json[colEndTime],
    );
  }

  // COPY WITH
  MyService copyWith({
    final int? id,
    final int? restaurantId,
    final int? dayOfWeek,
    final TimeOfDay? startTime,
    final TimeOfDay? endTime,
  }) {
    return MyService(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyService && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;




}