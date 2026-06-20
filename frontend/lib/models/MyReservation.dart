import 'dart:convert';
import 'dart:developer';
import 'package:prbd_2526_a02/models/MyRestaurant.dart';
import 'package:prbd_2526_a02/models/MyTable.dart';
import 'package:prbd_2526_a02/models/enums/Status.dart';
import '../core/services/api_client.dart';
import 'MyUser.dart';

class MyReservation {
  // ATTRIBUTES
  final int id;
  final int clientId;
  final int restaurantId;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  final bool isVip;
  // OBJECT ATTRIBUTES
  final MyUser? client;
  final MyRestaurant? restaurant;
  final List<MyTable>? tables;


  // CONSTRUCTOR
  MyReservation({
    required this.id,
    required this.clientId,
    required this.restaurantId,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
    required this.isVip,
    this.client,
    this.restaurant,
    this.tables = const [],
  });

  // FACTORY
  factory MyReservation.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colClientId = 'client',
    colRestaurantId = 'restaurant',
    colDatetime = 'datetime',
    colNumberOfGuests = 'number_of_guests',
    colStatus = 'status',
    colSpecialRequests = 'special_requests',
    colIsVip = 'is_vip',
  }) {
    return MyReservation(
      id: json[colId],
      clientId: json[colClientId],
      restaurantId: json[colRestaurantId],
      datetime: DateTime.parse(json[colDatetime].toString()),
      numberOfGuests: json[colNumberOfGuests],
      status: Status.values.byName(json[colStatus]),
      specialRequests: json[colSpecialRequests],
      isVip: json[colIsVip],
    );
  }

  // COPY WITH
  MyReservation copyWith({
    int? id,
    int? clientId,
    int? restaurantId,
    DateTime? datetime,
    int? numberOfGuests,
    Status? status,
    String? specialRequests,
    bool? isVip,
    MyUser? client,
    MyRestaurant? restaurant,
    List<MyTable>? tables,
  }) {
    return MyReservation(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      restaurantId: restaurantId ?? this.restaurantId,
      datetime: datetime ?? this.datetime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      isVip: isVip ?? this.isVip,
      client: client ?? this.client,
      restaurant: restaurant ?? this.restaurant,
      tables: tables ?? this.tables,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyReservation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // GETS
  int compareToTimewise(MyReservation other) {
    int result = -datetime.compareTo(other.datetime);

    if(result == 0) result = id - other.id;

    return result;
  }

  // DATABASE FUNCTIONS
  Future<MyReservation> completeReservation() async {
    final response = await ApiClient.post(
      'complete_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({'id': id}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }

    return copyWith(status: Status.completed);
  }

  Future<MyReservation> cancelReservation() async {
    final response = await ApiClient.post(
      'cancel_reservation', // Correspond au nom de la fonction SQL créée
      body: json.encode({'id': id}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reservation: ${response.body}');
    }

    return copyWith(status: Status.cancelled);
  }

  Future<MyReservation> setupVip() async {
    final response = await ApiClient.post(
      'setup_vip',
      body: json.encode({
        'id': id
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update the vip value: ${response.body}');
    }

    return copyWith(isVip: !isVip);
  }

  Future<MyReservation> confirmReservation(Set<MyTable> tables) async {
    final response = await ApiClient.post(
      'confirm_reservation',
      body: json.encode({
        'reservation_id': id,
        'tables_id': [for(MyTable table in tables) table.id],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to confirm reservation: ${response.body}');
    }

    return copyWith(status: Status.confirmed);
  }

  //TODO: delete this !
  Future<void> addReservationTable(MyTable table) async {
    final response = await ApiClient.post(
      'add_reservation_table', // Correspond au nom de la fonction SQL créée
      body: json.encode({
        'reservation_id': id,
        'table_id': table.id,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to add table reservation: ${response.body}');
    }
  }


  // STATIC FUNCTIONS
  static Future<List<MyReservation>> getManagerReservations(int managerId) async {
    final response = await ApiClient.post(
      'get_manager_reservations',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: Failed to get manager reservations');
    }

    final List<dynamic> body = json.decode(response.body);
    List<MyReservation> reservations = body.map((dynamic item) =>
        MyReservation.fromJson(item)
    ).toList();

    return reservations;
  }
}