import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:flutter/material.dart';

class SessionsSummaryCard extends StatelessWidget {
  const SessionsSummaryCard({super.key, required this.count, required this.dateLabel});

  final int count;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
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
              final Widget pill = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(AppIcons.check, size: 16, color: AppColors.onPrimary),
                    SizedBox(width: 6),
                    Text(AppStrings.onPitch, style: AppTextStyles.button),
                  ],
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
                    const SizedBox(height: 10),
                    pill,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Text('$count', style: AppTextStyles.heroNumber),
                  const SizedBox(width: 10),
                  const Expanded(child: Text(AppStrings.sessionsToday, style: AppTextStyles.title)),
                  pill,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
