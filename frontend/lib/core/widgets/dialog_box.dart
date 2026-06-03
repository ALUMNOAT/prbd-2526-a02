import 'package:flutter/material.dart';

import 'dialog_action.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final String message;
  final List<DialogAction> actions; // Changed from String to DialogAction

  const DialogBox({
    required this.title,
    required this.message,
    required this.actions,
  });

  Future<String?> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions.map((action) {
        if (action.isFilled) {
          return ElevatedButton(
            onPressed: () => Navigator.of(context).pop(action.label),
            style: ElevatedButton.styleFrom(
              backgroundColor: action.color, // Can be red, blue, green...
              foregroundColor: Colors.white,
            ),
            child: Text(action.label),
          );
        }

        return TextButton(
          onPressed: () => Navigator.of(context).pop(action.label),
          style: TextButton.styleFrom(foregroundColor: action.color),
          child: Text(action.label),
        );
      }).toList(),
    );
  }
}