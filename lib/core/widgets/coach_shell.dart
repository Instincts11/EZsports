import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachShell extends StatelessWidget {
  const CoachShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.navBorder)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.navLabel.copyWith(color: AppColors.primary);
              }
              return AppTextStyles.navLabel.copyWith(color: AppColors.navInactive);
            }),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final NavigationBar bar = NavigationBar(
                height: 72,
                backgroundColor: AppColors.background,
                indicatorColor: AppColors.transparent,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: navigationShell.goBranch,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(AppIcons.home, color: AppColors.navInactive),
                    selectedIcon: Icon(AppIcons.home, color: AppColors.primary),
                    label: AppStrings.home,
                  ),
                  NavigationDestination(
                    icon: Icon(AppIcons.batches, color: AppColors.navInactive),
                    selectedIcon: Icon(AppIcons.batches, color: AppColors.primary),
                    label: AppStrings.batches,
                  ),
                  NavigationDestination(
                    icon: Icon(AppIcons.players, color: AppColors.navInactive),
                    selectedIcon: Icon(AppIcons.players, color: AppColors.primary),
                    label: AppStrings.players,
                  ),
                  NavigationDestination(
                    icon: Icon(AppIcons.sessions, color: AppColors.navInactive),
                    selectedIcon: Icon(AppIcons.sessions, color: AppColors.primary),
                    label: AppStrings.sessions,
                  ),
                  NavigationDestination(
                    icon: Icon(AppIcons.profile, color: AppColors.navInactive),
                    selectedIcon: Icon(AppIcons.profile, color: AppColors.primary),
                    label: AppStrings.profile,
                  ),
                ],
              );
              if (constraints.maxWidth >= 360) {
                return bar;
              }
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: SizedBox(width: 360, height: 72, child: bar),
              );
            },
          ),
        ),
      ),
    );
  }
}
