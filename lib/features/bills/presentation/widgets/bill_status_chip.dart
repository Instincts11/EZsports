import 'package:ezsports/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BillStatusChip extends StatelessWidget {
  const BillStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color = status == 'paid' ? AppColors.success : AppColors.finance;
        return Chip(label: Text(status), backgroundColor: color.withOpacity(0.15));
  }
}
