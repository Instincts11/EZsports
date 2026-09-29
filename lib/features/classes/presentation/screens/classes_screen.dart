import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/classes/presentation/widgets/class_session_card.dart';
import 'package:ezsports/features/classes/providers/classes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String filter = ref.watch(sessionFilterProvider);
    final List<SessionModel> sessions = ref
        .watch(demoSessionsProvider)
        .where((SessionModel session) => session.status == filter)
        .toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: <Widget>[
          const Text(AppStrings.sessions, style: AppTextStyles.pageTitle),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(AppIcons.calendar, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(AppStrings.dateRange, style: AppTextStyles.bodyOnDark),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: AppStrings.upcoming,
                  selected: filter == 'upcoming',
                  onTap: () => ref.read(sessionFilterProvider.notifier).state = 'upcoming',
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppStrings.ongoing,
                  selected: filter == 'ongoing',
                  onTap: () => ref.read(sessionFilterProvider.notifier).state = 'ongoing',
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppStrings.previous,
                  selected: filter == 'previous',
                  onTap: () => ref.read(sessionFilterProvider.notifier).state = 'previous',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Nothing in this view for the selected range.', style: AppTextStyles.muted),
            )
          else
            ...sessions.map(
              (SessionModel session) => ClassSessionCard(
                session: session,
                onViewPlayers: () => context.go('/sessions/${session.sessionId}/attendance'),
              ),
            ),
          if (filter == 'upcoming' && sessions.isNotEmpty) ...<Widget>[
            const CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('End of this range · 06 Sep – 15 Sep', style: AppTextStyles.title),
                  SizedBox(height: 4),
                  Text('Next range starts 16 Sep', style: AppTextStyles.muted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppColors.primary : AppColors.cardBeige),
        ),
        child: Text(
          label,
          style: selected ? AppTextStyles.button : AppTextStyles.bodyOnDark,
        ),
      ),
    );
  }
}
