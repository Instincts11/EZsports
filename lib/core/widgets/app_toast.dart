import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
