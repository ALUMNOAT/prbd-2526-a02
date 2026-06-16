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
  final String city;
  final int slotDuration;

  Restaurant({
    required this.id,
    required this.city,
    required this.slotDuration,
  });

      id: json['id'],
      city: json['city'],
    );
  }