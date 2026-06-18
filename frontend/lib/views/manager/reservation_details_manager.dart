import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/MyTable.dart';
import 'package:prbd_2526_a02/providers/luca_provider/ManagerState.dart';
import 'package:prbd_2526_a02/providers/luca_provider/ManagerStateProvider.dart';

import '../../core/widgets/dialog_action.dart';
import '../../core/widgets/dialog_box.dart';
import '../../models/MyRestaurant.dart';
import '../../models/MyUser.dart';
import '../../models/enums/Status.dart';
import '../../models/MyReservation.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ReservationDetailsManagerPage(),
    ),
  );
}

class ReservationDetailsManagerPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ReservationDetailsManagerPage> createState() => _ReservationDetailsManagerState();
}

class _ReservationDetailsManagerState extends ConsumerState<ReservationDetailsManagerPage> {
  @override
  Widget build(BuildContext context) {
    final reservation = ModalRoute.of(context)!.settings.arguments as MyReservation;
    final managerState = ref.watch(managerStateProvider);
    final managerStateNotifier = ref.watch(managerStateProvider.notifier);


    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return managerState.when(
      error: (err, stack) => Text(err.toString()),
      loading: () => const CircularProgressIndicator(),
      data: (manager) => Data(
        theme: theme,
        simulatedTime: simulatedTime,
        manager: manager!,
        reservation: manager.getReservation(reservation.id),
        managerNotifier: managerStateNotifier,
      ),
    );
  }
}

class Data extends StatelessWidget {
  Data({
    super.key,
    required this.theme,
    required this.simulatedTime,
    required this.manager,
    required this.reservation,
    required this.managerNotifier,
  });

  final ThemeData theme;
  final DateTime simulatedTime;
  final ManagerState manager;
  final MyReservation reservation;
  final ManagerStateNotifier managerNotifier;

  @override
  Widget build(BuildContext context) {
    final MyUser client = manager.getClientFromReservation(reservation.id);
    final MyRestaurant restaurant = manager.getRestaurantFromReservation(reservation.id);
    final Status status = reservation.status;
    final List<MyTable> tables = manager.getReservationTables(reservation.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text('Détails de la réservation'),

        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //INFO CLIENT
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations client',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text('Nom: ${client.fullName}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 20),
                          SizedBox(width: 8),
                          Text('Email: ${client.email}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            (client.phone == null ? 'null' : client.phone!),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //RESERVATION DETAILS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //TITLE
                      const Text(
                        'Détails de la réservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      //RESTAURANT NAME/INFO
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      //DIVIDER
                      const Divider(),
                      const SizedBox(height: 16),

                      //DATE
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Date : ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(reservation.datetime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      //TIME
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                              'heure : ${DateFormat('HH:mm', 'fr_FR').format(reservation.datetime)}'
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      //GUEST_COUNT
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text('Nombre de convives: ${reservation.numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      //STATUS
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          Chip(
                            label:  Text(
                              status.frenchName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: status.color,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      //DIVIDER
                      const Divider(),
                      const SizedBox(height: 8),

                      //SPECIAL REQUESTS
                      Text(
                        'Demandes spéciales',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '${reservation.specialRequests}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //ASSIGNED TABLE
              const Text(
                'Tables assignées',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if(tables.isNotEmpty)
                Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(MyTable table in tables)
                        tableRow(table),
                    ],
                  ),
                ),
              ),
              if(tables.isEmpty)
                Text('Aucune table assignée'),
              const SizedBox(height: 24),

              //COMPLETE RESERVATION BUTTON
              if(status == Status.confirmed)
                ElevatedButton.icon(
                  onPressed: () {
                    completeReservation(context);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Marquer comme terminée'),
                ),
              if(status == Status.confirmed)
                const SizedBox(height: 8),

              //CANCEL RESERVATION BUTTON
              if(status == Status.pending ||
                  status == Status.confirmed)
                OutlinedButton.icon(
                  onPressed: () {
                    cancelReservation(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
              ),
              if(status == Status.pending ||
                  status == Status.confirmed)
                const SizedBox(height: 8),

              //ASSIGN TABLES BUTTON
              if(status == Status.pending)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/assign_table',
                        arguments: reservation
                    );
                  },
                  icon: const Icon(Icons.table_restaurant_rounded),
                  label: const Text('Confirmer et assigner tables'),
                )
            ],
          ),
        ),
      ),
    );
  }

  Padding tableRow(MyTable table) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.table_restaurant, size: 20),
          const SizedBox(width: 8),
          Text('Table ${table.tableNumber}'),
          const SizedBox(width: 16),
          Text(
            '(${table.capacity} places)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void completeReservation(BuildContext context) async {
    final confirm = await DialogBox(
      title: 'Compléter la réservation',
      message: 'Voulez-vous marquer cette réservation comme terminée ? ',
      actions: [
        DialogAction(label: 'Non'),
        DialogAction(label: 'Oui', color: Colors.red, isFilled: true),
      ],
    ).show(context);

    if (confirm != 'Oui') return;

    try {
      managerNotifier.completeReservation(reservation);

      // On vérifie si on est toujours sur la page avant de naviguer
      if (!context.mounted) return;

      // On ferme la page
      //Navigator.pop(context);

    } catch (e) {
      if (!context.mounted) return;
      DialogBox(
        title: 'Impossible de compléter la réservation',
        message: 'Vérifiez votre connection avec la base de données',
        actions: [
          DialogAction(label: 'OK'),
        ],
      ).show(context);
    }
  }

  void cancelReservation(BuildContext context) async {
    final confirm = await DialogBox(
      title: 'Annuler la réservation',
      message: 'Êtes-vous sûr de vouloir annuler cette réservation ? ',
      actions: [
        DialogAction(label: 'Non'),
        DialogAction(label: 'Oui', color: Colors.red, isFilled: true),
      ],
    ).show(context);

    if (confirm != 'Oui') return;

    try {
      managerNotifier.cancelReservation(reservation);

      // On vérifie si on est toujours sur la page avant de naviguer
      if (!context.mounted) return;

      // On ferme la page
      //Navigator.pop(context);

    } catch (e) {
      if (!context.mounted) return;
      DialogBox(
        title: 'Impossible d''annuler la réservation',
        message: 'Vérifiez votre connection avec la base de données',
        actions: [
          DialogAction(label: 'OK'),
        ],
      ).show(context);
    }
  }
}