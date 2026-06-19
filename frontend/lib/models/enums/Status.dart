//https://dart.dev/language/enums

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status {
  pending('En attente', Icons.pending, Colors.orange),
  confirmed('Confirmée', Icons.check_circle, Colors.green),
  cancelled('Annulée', Icons.cancel, Colors.red),
  completed('Terminée', Icons.event_available, Colors.blue);

  const Status(
    this.frenchName,
    this.iconData,
    this.color,
  );

  final String frenchName;
  final IconData iconData;
  final Color color;
}