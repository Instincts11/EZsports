import 'package:flutter/material.dart';

class AdminMenuTile extends StatelessWidget {
  const AdminMenuTile({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), onTap: onTap);
  }
}
