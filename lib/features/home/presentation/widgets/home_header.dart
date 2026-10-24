import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/brand_mark.dart';
import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';
import 'package:ezsports/features/home/presentation/widgets/date_overlay.dart';
import 'package:ezsports/features/home/providers/home_providers.dart';
import 'package:ezsports/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String academy = ref.watch(homeDashboardProvider).maybeWhen(
      data: (HomeDashboardModel home) => home.academyName,
      orElse: () => '',
    );
    return Row(
      children: <Widget>[
        const BrandMark(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(AppStrings.appName, style: AppTextStyles.brandTitle),
              Text(academy.isEmpty ? 'Academy' : academy, style: AppTextStyles.academySubtitle),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Dates',
          onPressed: () async {
            final HomeDashboardModel latest = await ref.refresh(homeDashboardProvider.future);
            if (!context.mounted) {
              return;
            }
            showCoachDateOverlay(
              context,
              rangeStart: parseApiDate(latest.rangeStart),
              rangeEnd: parseApiDate(latest.rangeEnd),
            );
          },
          icon: const Icon(AppIcons.calendar, color: AppColors.cardBeige),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => showCoachNotifications(context),
          icon: const Icon(AppIcons.notifications, color: AppColors.cardBeige),
        ),
      ],
    );
  }
}
