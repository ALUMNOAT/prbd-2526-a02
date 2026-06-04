import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/luca_provider/restaurant_provider.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.restaurantNotifier
  });

  final Restaurant restaurant;
  final RestaurantNotifier restaurantNotifier;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"),
          child: ListTile(
          leading: const Icon(Icons.restaurant, size: 40),
          title: Text(restaurant.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(restaurant.city),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    restaurant.getPricing,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Dernière réservation: mer. 04/12/2024',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.pending, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    '2 demandes en attente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      )
    );
  }
}