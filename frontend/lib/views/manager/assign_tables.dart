import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a02/models/MyReservation.dart';
import 'package:prbd_2526_a02/models/MyTable.dart';
import 'package:prbd_2526_a02/providers/luca_provider/ManagerState.dart';
import 'package:prbd_2526_a02/providers/luca_provider/ManagerStateProvider.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AssignTablesPage(),
    ),
  );
}

class AssignTablesPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AssignTablesPage> createState() => _AssignTablesState();
}

class _AssignTablesState extends ConsumerState<AssignTablesPage> {
  int tableCount = 0;

  final Set<MyTable> selectedTable = {};
  @override
  Widget build(BuildContext context) {
    final managerState = ref.watch(managerStateProvider);
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final reservation = ModalRoute.of(context)!.settings.arguments as MyReservation;

    return managerState.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text(err.toString()),
      data: (manager) {
        if (manager == null) {
          return Text("No manager found");
        }

        return data(context, theme, simulatedTime, reservation, manager);
      },
    );
  }

  Scaffold data(
      BuildContext context,
      ThemeData theme, DateTime simulatedTime,
      MyReservation reservation,
      ManagerState manager)
  {
    final restaurant = manager.getRestaurant(reservation.restaurantId);
    final tables = manager.getRestaurantTables(reservation.restaurantId);
    final services = manager.getReservationServices(reservation);
    final occupiedTables = manager.getOccupiedTablesForReservation(reservation);
    final isEnoughTable = tableCount >= reservation.numberOfGuests;

    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {Navigator.pop(context);},
      ),
      title: const Text('Assigner des tables'),
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
      child: Column(
        children: [
          //RESERVATION INFO
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${reservation.numberOfGuests} convives'),
                    Text(DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR').format(reservation.datetime),),
                  ],
                ),
              ),
            ),
          ),

          //TOTAL CURRENT CAPACITY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: isEnoughTable
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacité totale: $tableCount places',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✓ Capacité suffisante pour 4 convives',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //TITLE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sélectionnez les tables disponibles',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          //TABLES LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                for(var table in tables)
                  occupiedTables.contains(table)
                    ? occupiedTableCard(table)
                    : tableCard(table),
              ],
            ),
          ),

          //CONFIRM RESERVATION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Confirmer la réservation'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Card tableCard(MyTable table) {
    bool isChecked = selectedTable.contains(table);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: (newValue) {
          selectedTable.contains(table)
              ? selectedTable.remove(table)
              : selectedTable.add(table);

          updateTableCount(); //updates value
          setState(() {});    //updates UI;
        },

        title: Text('Table ${table.tableNumber}'),
        subtitle: Text('Capacité: ${table.capacity} personnes',),
        secondary: const Icon(Icons.table_restaurant),
      ),
    );
  }

  Card occupiedTableCard(MyTable table) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade100,
      child: CheckboxListTile(
        value: false,
        onChanged: null,
        title: Text(
          'Table ${table.tableNumber}',
          style: TextStyle(
            color: Colors.grey.shade600,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          'Occupée pour ce service',
          style: TextStyle(
            color: Colors.red.shade300,
          ),
        ),
        secondary: Icon(
          Icons.table_restaurant,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void updateTableCount() {
    tableCount = 0;
    for(MyTable table in selectedTable) {
      tableCount += table.capacity;
    }
  }
}
