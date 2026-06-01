import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

class Manager extends User {
  final List<Restaurant> restaurants = [];

  Manager({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.phone
  }){
    setRestaurants();
  }

  void setRestaurants() async {
    restaurants.addAll(await Restaurant.getRestaurantsByManager(this));
  }
}