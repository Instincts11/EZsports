import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/core/widgets/fee_due_badge.dart';
import 'package:ezsports/core/widgets/initials_avatar.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudentModel player = ref.watch(playerByIdProvider(playerId)) ?? ref.watch(demoPlayersProvider).first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/players'),
          icon: const Icon(AppIcons.back, color: AppColors.primary),
        ),
        title: Row(
          children: <Widget>[
            const Text(AppStrings.player, style: AppTextStyles.titleOnDark),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBeige,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(AppStrings.viewOnly, style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: <Widget>[
          CreamCard(
            color: AppColors.cardBeige,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    InitialsAvatar(initials: player.initials, size: 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${player.firstName} ${player.lastName}.', style: AppTextStyles.title),
                          const SizedBox(height: 6),
                          const Text(AppStrings.academyName, style: AppTextStyles.muted),
                          if (player.feeDue) ...<Widget>[
                            const SizedBox(height: 8),
                            const FeeDueBadge(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(AppIcons.calendar, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(player.batchName, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: AppIcons.players, label: AppStrings.firstName, value: player.firstName),
          _InfoRow(icon: AppIcons.profile, label: AppStrings.lastName, value: player.lastName),
          _InfoRow(icon: AppIcons.calendar, label: AppStrings.dob, value: player.dob.isEmpty ? '-' : player.dob),
          _InfoRow(icon: AppIcons.gender, label: AppStrings.gender, value: player.gender.isEmpty ? '-' : player.gender),
          _InfoRow(icon: AppIcons.phone, label: AppStrings.mobile, value: player.parentMobile),
          _InfoRow(icon: AppIcons.emergency, label: AppStrings.emergency, value: player.emergency.isEmpty ? '-' : player.emergency),
          const SizedBox(height: 8),
          CreamCard(
            color: AppColors.cardBeige,
            child: Row(
              children: <Widget>[
                const Icon(AppIcons.calendar, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(AppStrings.attendanceThisMonth, style: AppTextStyles.muted),
                      Text('${player.attended} of ${player.totalSessions} sessions', style: AppTextStyles.title),
                    ],
                  ),
                ),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: player.totalSessions == 0 ? 0 : player.attended / player.totalSessions,
                    color: AppColors.primary,
                    backgroundColor: AppColors.card,
                    strokeWidth: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.navInactive),
          const SizedBox(width: 12),
          SizedBox(width: 90, child: Text(label, style: AppTextStyles.fieldLabel)),
          Expanded(child: Text(value, style: AppTextStyles.fieldValue)),
        ],
      ),
    );
  }
}
