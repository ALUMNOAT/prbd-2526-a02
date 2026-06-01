import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/models/user.dart';

class Client extends User {
  final List<Reservation> reservations = [];

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