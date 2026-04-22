import 'dart:ui';

class DialogAction {
  final String label;
  final Color? color;
  final bool isFilled;

  DialogAction({
    required this.label,
    this.color,
    this.isFilled = false
  });
}