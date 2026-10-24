import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/network/api_error.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/attendance/providers/attendance_providers.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/home/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionsSummaryCard extends ConsumerWidget {
  const SessionsSummaryCard({super.key, required this.count, required this.dateLabel, this.session});

  final int count;
  final String dateLabel;
  final SessionModel? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionModel? current = session;
    final bool onPitch = current?.myAttendanceStatus == 'present';
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(AppIcons.calendar, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(dateLabel, style: AppTextStyles.body)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget? pill = current == null
                  ? null
                  : Material(
                      color: onPitch ? AppColors.primary : AppColors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onPitch ? null : () => _checkIn(context, ref, current),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(AppIcons.check, size: 16, color: onPitch ? AppColors.onPrimary : AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                onPitch ? AppStrings.onPitch : 'Check in',
                                style: onPitch ? AppTextStyles.button : AppTextStyles.button.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
              final Widget countAndLabel = Row(
                children: <Widget>[
                  Text('$count', style: AppTextStyles.heroNumber),
                  const SizedBox(width: 10),
                  const Expanded(child: Text(AppStrings.sessionsToday, style: AppTextStyles.title)),
                ],
              );
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    countAndLabel,
                    if (pill != null) ...<Widget>[
                      const SizedBox(height: 10),
                      pill,
                    ],
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Text('$count', style: AppTextStyles.heroNumber),
                  const SizedBox(width: 10),
                  const Expanded(child: Text(AppStrings.sessionsToday, style: AppTextStyles.title)),
                  if (pill != null) pill,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref, SessionModel session) async {
    try {
      await ref.read(attendanceRepositoryProvider).markCoachAttendance(sessionId: session.sessionId, status: 'present');
      ref.invalidate(homeDashboardProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(error, 'Could not check in. Try again.'))),
        );
      }
    }
  }
}
