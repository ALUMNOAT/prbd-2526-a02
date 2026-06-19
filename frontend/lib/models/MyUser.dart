import 'dart:convert';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/enums/Role.dart';

class MyUser {
  // ATTRIBUTES
  final int id;
  final String email;
  final String fullName;
  final Role role;
  final String? phone;
  // OBJECT ATTRIBUTES


  // CONSTRUCTOR
  MyUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  // FACTORY
  factory MyUser.fromJson(Map<String, dynamic> json, {
    colId = 'id',
    colEmail = 'email',
    colFullName = 'full_name',
    colRole = 'role',
    colPhone = 'phone',
  }) {
    return MyUser(
      id: json[colId],
      email: json[colEmail],
      fullName: json[colFullName],
      role: Role.values.byName(json[colRole]),
      phone: json[colPhone]
    );
  }

  // COPY WITH
  MyUser copyWith({
    int? id,
    String? email,
    String? fullName,
    Role? role,
    String? phone,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }

  // IS EQUAL
  @override
  bool operator == (Object other) => identical(this, other) ||
      other is MyUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;



  // STATIC FUNCTIONS
  static Future<MyUser> getCurrentUser() async {
    final response = await ApiClient.get('get_current_user');

    if (response.statusCode == 200) {
      return MyUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get current user');
    }
  }

  static Future<List<MyUser>> getManagerClients(int managerId) async {
    final response = await ApiClient.post(
      'get_manager_clients',
      body: json.encode({'manager_id': managerId}),
    );

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: Failed to get manager clients');
    }

    final List<dynamic> body = json.decode(response.body);
    List<MyUser> clients = body.map((dynamic item) =>
        MyUser.fromJson(item)
    ).toList();

    return clients;
  }
}