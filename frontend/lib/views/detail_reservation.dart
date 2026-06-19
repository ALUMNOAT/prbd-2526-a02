import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/core/widgets/dialog_action.dart';
import 'package:prbd_2526_a02/models/reservation.dart';

import '../core/widgets/dialog_box.dart';
import '../providers/clientStateProvider.dart';
import '../providers/currentUserProvider.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ReservationDetailsPage(),
    ),
  );
}

class ReservationDetailsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ReservationDetailsPage> createState() => _ReservationDetailsPage();
}

class _ReservationDetailsPage extends ConsumerState<ReservationDetailsPage> {

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider);

    // On récupère l'objet 'res' passé en argument de mes_reservations.dart (lors qu'on redirige)
    final res = ModalRoute.of(context)!.settings.arguments as Reservation;

    // Pour gérer les couleurs du status
    Color statusColor;
    String statusName;
    switch (res.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusName = 'Confirmée';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusName = 'En Cours';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusName = 'Annulée';
        break;
      default:
        statusColor = Colors.blue;
        statusName = 'Terminée';
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Cette ligne permet de fermer la page actuelle
            // et de revenir à HomeClientPage
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              // 1. On invalide le provider pour forcer un nouvel appel API au prochain watch
              ref.invalidate(clientStateProvider);

              // 2. On rafraîchit la page actuelle avec les nouvelles données
              // (Note : Comme le provider sera invalidé, dès que la page
              // se reconstruit, elle ira chercher la donnée fraîche).
              Navigator.pushReplacementNamed(
                context,
                '/details_reservation',
                arguments: res,
              );
            },
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
                  'mercredi 04/12/2024 16:00',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              res.restoName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              res.restoAddress,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            res.phone ?? 'Non spécifié',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Date : ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(res.datetime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Heure : ${DateFormat('HH:mm', 'fr_FR').format(res.datetime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nombre de convives: ${res.numberOfGuests}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Statut: ',
                          ),
                          Chip(
                            label: Text(
                              statusName,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),

                      if (res.specialRequests != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Demandes spéciales',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          res.specialRequests ?? ' ',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // On n'affiche la ligne de boutons QUE si le statut n'est pas "completed" ni "cancelled"
              if (res.status != 'completed' && res.status != 'cancelled')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        // Si confirmé, onPressed est null (bouton grisé), sinon il est actif
                        onPressed: res.status == 'confirmed'
                            ? null
                            : () async {
                          // Affiche un indicateur de chargement
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            // 1. Récupérer tous les restos pour trouver celui de la réservation
                            final userID = ref.read(currentUserProvider.notifier).userID;
                            final allRestos = await Reservation.getAllClientRestaurantsReservations(userID!);

                            // 2. Trouver le restaurant correspondant à cette réservation
                            final currentResto = allRestos.firstWhere(
                                  (r) => r['resto_name'] == res.restoName,
                              orElse: () => throw Exception("Restaurant non trouvé"),
                            );

                            // 3. Fermer le chargement
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            // 4. Naviguer vers le formulaire de création/modification
                            Navigator.pushNamed(
                              context,
                              '/creation_reservation',
                              arguments: {
                                'restaurant': currentResto,
                                'reservation': res, // <--- C'est cet argument que tu vas récupérer dans ReservationFormPage
                              },
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context); // Fermer le chargement
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impossible de charger le formulaire.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        // Toujours actif ici car on est déjà dans le "if" qui exclut annulé/terminé
                        onPressed: () => _cancel_reservation(context, res),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancel_reservation(BuildContext context, Reservation res) async {
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
      await ref.read(clientStateProvider.notifier).annuler_reservation(id: res.id);

      // On vérifie si on est toujours sur la page avant de naviguer
      if (!context.mounted) return;

      // On ferme la page
      Navigator.pop(context);

    } catch (e) {
      if (!context.mounted) return;
      DialogBox(
        title: 'Impossible d annuler la réservation',
        message: 'Checker votre connection avec la base de données',
        actions: [
          DialogAction(label: 'OK'),
        ],
      ).show(context);
    }
  }
}
