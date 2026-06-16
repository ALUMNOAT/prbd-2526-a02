//https://dart.dev/language/enums

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status {
  pending('En attente', Icons.pending, Colors.orange),
  confirmed('Confirmé', Icons.check_circle, Colors.green),
  cancelled('Annulée', Icons.cancel, Colors.red),
  completed('Terminée', Icons.event_available, Colors.blue);

  const Status(
    this.french_name,
    this.iconData,
    this.color,
  );

  final String french_name;
  final IconData iconData;
  final Color color;
}