import 'dart:convert';
import 'package:prbd_2526_a02/core/services/api_client.dart';
import 'package:prbd_2526_a02/models/user.dart';

class Restaurant {
  late int _id;
  late String _name;
  late String _city;
  late String _phone;
  String? _description;
  double? _rating;
  int? _priceRange;
  late int _slotDuration;

  // (1) using private named parameters require a boilerplate :(
  // only in dart 3.13 can this be bypassed...
  // https://dart.dev/language/constructors#private-named-parameters
  Restaurant({
    int id = 0,
    String name = '',
    String city = '',
    String phone = '',
    String? description,
    double? rating,
    int? priceRange,
    int slotDuration = 0,
  }) {
    _id = id; _name = name; _city = city; _phone = phone;
    _description = description; _rating = rating; _priceRange = priceRange;
    _slotDuration = slotDuration;
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      phone: json['phone'],
      description: json['description'],
      rating: json['rating'],
      priceRange: json['price_range'],
      slotDuration: json['slot_duration'],
    );
  }

  // GET-SET
  int get id => _id;
  set id(int value) {_id = value;}

  String get name => _name;
  set name(String value) {_name = value;}

  String get city => _city;
  set city(String value) {_city = value;}

  String get phone => _phone;
  set phone(String value) {_phone = value;}

  String get description => _description ?? "";
  set description(String value) {_description = value;}

  double get rating => _rating ?? 0;
  set rating(double value) {_rating = value;}

  int get priceRange => _priceRange ?? 0;
  set priceRange(int value) {_priceRange = value;}

  int get slotDuration => _slotDuration;
  set slotDuration(int value) {_slotDuration = value;}


  /*
   * L'utilisation de runtimeType dans la surcharge de l'opérateur == permet de s'assurer
   * que l'objet other est exactement de la même classe que this. Cela évite des comparaisons
   * entre objets d'une classe dérivée ou d'un autre type qui aurait des propriétés similaires.
   */
  @override
  bool operator == (Object other) => identical(this, other) ||
    other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => _id.hashCode;

  static Future<Restaurant> getRestaurantById(int id) async {
    final response = await ApiClient.post(
      'get_restaurant_by_id',
      body: json.encode({'id': id}),
    );
    if (response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get restaurant from id');
    }
  }

  static Future<Restaurant> getRestaurantsByUser(User owner) async {
    final response = await ApiClient.post(
      'get_restaurants_by_user',
      body: json.encode({'user_id': owner.id}),
    );
    if (response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get restaurant from id');
    }
  }
}
