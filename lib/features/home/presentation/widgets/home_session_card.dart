import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:flutter/material.dart';

class HomeSessionCard extends StatelessWidget {
  const HomeSessionCard({super.key, required this.session, required this.onOpenRoster});

  final SessionModel session;
  final VoidCallback onOpenRoster;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: <Widget>[
                _IconRow(icon: AppIcons.calendar, text: session.dateLabel),
                const SizedBox(height: 12),
                _IconRow(icon: AppIcons.clock, text: session.timeRange, subtitle: session.batchName),
                if (session.ground.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _IconRow(icon: AppIcons.location, text: session.ground),
                ],
                if (session.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(session.note, style: AppTextStyles.body),
                ],
                if (session.meetingPoint.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text('Meet at ${session.meetingPoint}', style: AppTextStyles.muted),
                ],
                if (session.focus.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(session.focus, style: AppTextStyles.body),
                ],
                if (session.kit.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text('Kit: ${session.kit}', style: AppTextStyles.muted),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: <Widget>[
                const Icon(AppIcons.people, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('${session.studentCount} players', style: AppTextStyles.title)),
                TextButton(
                  onPressed: onOpenRoster,
                  child: const Row(
                    children: <Widget>[
                      Text(AppStrings.openRoster, style: AppTextStyles.link),
                      Icon(AppIcons.chevron, color: AppColors.primary),
                    ],
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

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.text, this.subtitle});

  final IconData icon;
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(text, style: AppTextStyles.title),
              if (subtitle != null) Text(subtitle!, style: AppTextStyles.muted),
            ],
          ),
        ),
      ],
    );
  }
}
