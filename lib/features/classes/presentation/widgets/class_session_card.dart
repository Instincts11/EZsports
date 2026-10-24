import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:flutter/material.dart';

class ClassSessionCard extends StatelessWidget {
  const ClassSessionCard({super.key, required this.session, required this.onViewPlayers});

  final SessionModel session;
  final VoidCallback onViewPlayers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CreamCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 72,
              child: Column(
                children: <Widget>[
                  Text(session.dayNumber, style: AppTextStyles.sessionDate),
                  Text(session.monthLabel, style: AppTextStyles.caption),
                  Text(session.weekdayLabel, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  const Icon(AppIcons.calendar, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(session.timeRange, style: AppTextStyles.title),
                  Text(session.batchName, style: AppTextStyles.muted),
                  if (session.ground.isNotEmpty) Text(session.ground, style: AppTextStyles.body),
                  if (session.note.isNotEmpty) Text(session.note, style: AppTextStyles.muted),
                  if (session.meetingPoint.isNotEmpty) Text('Meet at ${session.meetingPoint}', style: AppTextStyles.muted),
                  if (session.focus.isNotEmpty) Text(session.focus, style: AppTextStyles.body),
                  if (session.kit.isNotEmpty) Text('Kit: ${session.kit}', style: AppTextStyles.muted),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(AppIcons.people, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${session.studentCount} players',
                          style: AppTextStyles.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onViewPlayers,
                    child: const Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            AppStrings.viewPlayers,
                            style: AppTextStyles.link,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(AppIcons.forward, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
