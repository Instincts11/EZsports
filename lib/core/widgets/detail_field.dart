import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailField extends StatelessWidget {
  const DetailField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.accent = AppColors.primary,
    this.maxLines = 1,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final Color accent;
  final int maxLines;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.caption.copyWith(color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: obscure ? 1 : maxLines,
            obscureText: obscure,
            style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w600),
            cursorColor: accent,
            inputFormatters: keyboardType == TextInputType.phone
                ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))]
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF8C8378)),
              filled: true,
              fillColor: AppColors.playerCream,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
