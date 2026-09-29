import 'package:ezsports/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

final class AppTextStyles {
  AppTextStyles._();

  static const TextStyle brandTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.textOnDark,
  );
  static const TextStyle academySubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
  static const TextStyle pageTitle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w600,
    height: 1.05,
    color: AppColors.textOnDark,
    fontFamily: 'serif',
  );
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle titleOnDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyOnDark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDark,
  );
  static const TextStyle muted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle heroNumber = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    height: 1,
    color: AppColors.textPrimary,
  );
  static const TextStyle sessionDate = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static const TextStyle link = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle fieldValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );
  static const TextStyle displayName = TextStyle(
    fontFamily: 'serif',
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.1,
    color: AppColors.textOnDark,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.textOnDark,
  );
  static const TextStyle playerLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.playerAccent,
  );
}
