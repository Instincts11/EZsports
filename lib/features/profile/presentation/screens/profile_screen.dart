import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BatchModel> batches = ref.watch(demoBatchesProvider);
    final int players = batches.fold(0, (int sum, BatchModel batch) => sum + batch.studentCount);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                const _InitialsBadge(initials: 'RN'),
                const SizedBox(height: 12),
                const Text('R. Nair', style: AppTextStyles.displayName),
                const SizedBox(height: 4),
                const Text(AppStrings.academyName, style: AppTextStyles.academySubtitle),
                TextButton(
                  onPressed: () => context.push('/profile/details'),
                  child: const Text('Edit', style: AppTextStyles.link),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _DetailRow(label: 'Academy', value: AppStrings.academyName),
                const _DetailRow(label: 'Role', value: 'Head coach'),
                const _DetailRow(label: 'Since', value: 'Jan 2022'),
                const SizedBox(height: 8),
                const Text('Upcoming fixtures', style: AppTextStyles.title),
                const SizedBox(height: 8),
                const _FixtureLine('Sun 13 Sep · Kochi United · lineup set'),
                const _FixtureLine('Sat 20 Sep · Academy Cup · lineup open'),
                const _FixtureLine('30 Aug · Harbour FC · 2–1, sheet unsigned'),
                const SizedBox(height: 8),
                const Text('This week', style: AppTextStyles.title),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Expanded(child: _WeekStat(label: 'Sessions', value: '10')),
                    const SizedBox(width: 8),
                    const Expanded(child: _WeekStat(label: 'Open rolls', value: '1')),
                    const SizedBox(width: 8),
                    Expanded(child: _WeekStat(label: 'Players', value: '$players')),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Contact', style: AppTextStyles.title),
                const SizedBox(height: 8),
                const _DetailRow(label: 'Mobile', value: '+91 98460 11820'),
                const _DetailRow(label: 'Email', value: 'rnair@esperanza.academy'),
                const SizedBox(height: 8),
                const Text('Sunday plan', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text('On the pitch from 6:40 AM. Cones out before Weekend Morning. Mark Weekend Evening attendance before you leave.', style: AppTextStyles.body),
                const SizedBox(height: 12),
                const Text('Watch today', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text('Ishant Jay jogs only. Diya P is a trial in bib 16. Eight Weekend Evening fees are still open for 10 Sep.', style: AppTextStyles.body),
                const SizedBox(height: 12),
                const Text('Saturday parent chat', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text('12 Sep, 9:15 AM, Pitch B shed. Kochi Youth friendly on 27 Sep. Confirm who is staying after training.', style: AppTextStyles.body),
                const SizedBox(height: 16),
                const Text('Account', style: AppTextStyles.title),
                const _ChevronRow(label: 'Notifications'),
                const _ChevronRow(label: 'Change password'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text(AppStrings.logout, style: TextStyle(fontWeight: FontWeight.w700)),
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

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Text(initials, style: AppTextStyles.displayName.copyWith(fontSize: 28)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Text(label, style: AppTextStyles.muted.copyWith(color: const Color(0xFF8A8178))),
          const Spacer(),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          const Icon(AppIcons.chevron, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _FixtureLine extends StatelessWidget {
  const _FixtureLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTextStyles.body),
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: AppTextStyles.caption.copyWith(color: const Color(0xFF8A8178))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}
