import 'package:flutter/material.dart';

void showErrorSnackbar(
  BuildContext context,
  String message, {
  Object? details,
}) {
  final text = details == null ? message : '$message: $details';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade700,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}
