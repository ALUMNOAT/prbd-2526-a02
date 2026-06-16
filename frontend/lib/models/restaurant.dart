class Table {
  final int id;
  final int restaurantId;
  final int tableNumber;
  final int capacity;

  Table({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity
  });

  factory Table.fromJson(Map<String, dynamic> json) => Table(
    id: json['id'],
    restaurantId: json['restaurant'],
    tableNumber: json['table_number'],
    capacity: json['capacity'],
  );
}

class Service {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  Service({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'],
    dayOfWeek: json['day_of_week'],
    startTime: json['start_time'],
    endTime: json['end_time'],
  );
}

class Restaurant {
  final int id;
  final String restoName;
  final String restoAddress;
  final String city;
  final int slotDuration;
  final List<Table> tables;
  final List<Service> services;

  Restaurant({
    required this.id,
    required this.restoName,
    required this.restoAddress,
    required this.city,
    required this.slotDuration,
    required this.tables,
    required this.services
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'],
    restoName: json['resto_name'],
    restoAddress: json['resto_address'],
    city: json['city'],
    slotDuration: json['slot_duration'] ?? 30,
    tables: (json['tables'] as List).map((i) => Table.fromJson(i)).toList(),
    services: (json['services'] as List).map((i) => Service.fromJson(i)).toList(),
  );
}