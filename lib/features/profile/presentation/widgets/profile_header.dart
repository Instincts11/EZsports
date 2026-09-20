import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(name));
  }
}
