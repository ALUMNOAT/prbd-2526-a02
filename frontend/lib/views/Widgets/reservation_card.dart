import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/enums/status.dart';
import 'package:prbd_2526_a02/models/luca_reservation.dart';
import 'package:prbd_2526_a02/models/restaurant.dart';
import 'package:prbd_2526_a02/providers/luca_provider/luca_reservation_provider.dart';
import 'package:prbd_2526_a02/providers/luca_provider/restaurant_provider.dart';


class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.luca_reservation,
    required this.luca_reservationNotifier,
    required this.restaurant
  });

  final Luca_Reservation luca_reservation;
  final Luca_ReservationNotifier luca_reservationNotifier;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final Status status = luca_reservation.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          await luca_reservationNotifier.set_current_luca_reservation(luca_reservation);
          await Navigator.pushNamed(
            context,
            '/reservation_details_manager',
            arguments: luca_reservation, // On passe l'objet 'res' complet à la page suivante
          );


          // si on retourne de detail_reservation, la view s'update
          /*if (mounted) {
            setState(() {});
          }*/
        },

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Tooltip(
                message: status.name,
                child: Icon(status.icon, size: 32, color: status.color),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      restaurant.name, // Donnée dynamique
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),



                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.city, // Donnée dynamique
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),



                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR').format(luca_reservation.datetime),
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${luca_reservation.numberOfGuests} convives', // Donnée dynamique
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}