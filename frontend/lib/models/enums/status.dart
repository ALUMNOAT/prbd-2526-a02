//https://dart.dev/language/enums

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status {
  pending(icon: Icons.pending, color: Colors.orange),
  confirmed(icon: Icons.check_circle, color: Colors.green),
  cancelled(icon: Icons.cancel, color: Colors.red),
  complete(icon: Icons.event_available, color: Colors.blue);

  const Status({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}