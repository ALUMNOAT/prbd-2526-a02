import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a02/providers/clientStateProvider.dart';

import '../models/reservation.dart';
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
      home: ReservationFormPage(),
    ),
  );
}

class ReservationFormPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ReservationFormPage> createState() => _ReservationFormPage();
}

final DateTime _simulatedReference = DateTime(2024, 12, 4, 16, 0);

class _ReservationFormPage extends ConsumerState<ReservationFormPage> {
  late ValidatingTextEditingController _demandeController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  int _numConvives = 2;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime(
        _simulatedReference.year,
        _simulatedReference.month,
        _simulatedReference.day
    );

    _demandeController = ValidatingTextEditingController(
      validator: Reservation.validateDemande,
    );
    _demandeController.onAfterValidated = () => setState(() {});

  }

  @override
  void dispose() {
    _demandeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      // On vérifie si on a bien reçu une réservation (mode édition)
      if (args != null && args.containsKey('reservation')) {
        final res = args['reservation'];
        final DateTime dt = DateTime.parse(res['datetime']);
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        _numConvives = res['number_of_guests'];
        _demandeController.text = res['special_requests'] ?? '';
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider);
    final securityNotifier = ref.read(currentUserProvider.notifier);
    final userID = securityNotifier.userID;

    // 1. Récupération sécurisée des arguments
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args = (routeArgs is Map<String, dynamic>) ? routeArgs : {};

    final bool isEdit = args.containsKey('reservation');

    // 2. Détermination propre des données du restaurant
    // Si c'est une édition, on prend args['restaurant'], sinon on prend args directement
    final restaurantData = isEdit ? args['restaurant'] : args;

    final slots = _generateSlots(restaurantData);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(isEdit ? 'Modifier la réservation' : 'Nouvelle réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/creation_reservation',
                arguments: args,
            ),
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
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  restaurantData['resto_name'] ?? 'Restaurant inconnu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2024, 1, 1),
                              lastDate: DateTime(2025, 12, 31),
                            );

                            // 3. UPDATE THE STATE
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Date'),
                                      Text(
                                        DateFormat('EEEE dd/MM/yyyy', 'fr_FR').format(_selectedDate),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const Divider(),
                // 1. On calcule les créneaux une seule fois pour décider quoi afficher
                Builder(
                  builder: (context) {
                    if (slots.isEmpty) {
                      // SI VIDE : On affiche uniquement le message d'alerte orange
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Le restaurant est fermé ce jour-là.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // SI NON VIDE : On affiche le titre et la liste des créneaux
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Créneaux disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: slots.map((slot) {
                              final isSelected = _selectedTime == slot;
                              final timeString =
                                  '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';

                              return InkWell(
                                onTap: () => setState(() => _selectedTime = slot),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      timeString,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Nombre de convives'),
                  subtitle: Text('$_numConvives'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _numConvives > 1
                            ? () => setState(() => _numConvives--)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _numConvives < 10
                            ? () => setState(() => _numConvives++)
                            : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Surréservation (capacité)',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _demandeController,
                  decoration: InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    border: OutlineInputBorder(),
                    hintText: 'Allergies, préférences...',
                    errorText: _demandeController.errorText,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: (slots.isEmpty || _selectedTime == null)
                    ? null
                    : () => _submitForm(context, args, isEdit),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(isEdit ? 'Enregistrer les modifications' : 'Créer la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TimeOfDay> _generateSlots(Map<String, dynamic> res) {
    final List<TimeOfDay> allSlots = [];

    // 1. Sécurité : vérifie si 'services' existe et n'est pas null
    final dynamic servicesData = res['services'];
    if (servicesData == null || servicesData is! List) {
      return []; // Retourne une liste vide si aucune donnée de service n'est trouvée
    }

    final int dayOfWeek = _selectedDate.weekday;
    final int slotDuration = res['slot_duration'] ?? 30;

    // 2. Filtrage sécurisé
    final List services = servicesData.where((s) => s['day_of_week'] == dayOfWeek).toList();

    for (var service in services) {
      final startParts = service['start_time'].split(':');
      final endParts = service['end_time'].split(':');

      DateTime current = DateTime(2000, 1, 1, int.parse(startParts[0]), int.parse(startParts[1]));
      final DateTime end = DateTime(2000, 1, 1, int.parse(endParts[0]), int.parse(endParts[1]));

      while (current.isBefore(end)) {
        allSlots.add(TimeOfDay(hour: current.hour, minute: current.minute));
        current = current.add(Duration(minutes: slotDuration));
      }
    }
    return allSlots;
  }

  Future<void> _submitForm(BuildContext context, Map<String, dynamic> args, bool isEdit) async {
    if (!await _validateForm() || _selectedTime == null) return;

    final notifier = ref.read(clientStateProvider.notifier);

    final fullDatetime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute
    );

    try {
      if (isEdit) {
        // Appelle ta méthode de modification ici
        await notifier.editReservation(
          id: args['reservation']['id'],
          datetime: fullDatetime,
          nbConvives: _numConvives,
          specialRequests: _demandeController.text,
        );
      } else {
        // Ta méthode de création actuelle
        final userID = ref.read(currentUserProvider.notifier).userID;
        await notifier.addReservation(
          clientId: int.parse(userID!),
          restaurantId: isEdit ? args['restaurant']['id'] : args['id'],
          datetime: fullDatetime,
          nbConvives: _numConvives,
          specialRequests: _demandeController.text,
        );
      }
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/homeClient', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réservation : $e')),
        );
      }
    }
  }

  Future<bool> _validateForm() async {
    await _demandeController.validateAndWait();
    return _isFormValid;
  }

  bool get _isFormValid =>
          _demandeController.isValid == true;


}
