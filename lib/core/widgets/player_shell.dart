import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerShell extends StatelessWidget {
  const PlayerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.playerBackground,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF163044))),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              final bool selected = states.contains(WidgetState.selected);
              return AppTextStyles.navLabel.copyWith(
                color: selected ? AppColors.playerAccent : AppColors.playerNavInactive,
              );
            }),
          ),
          child: NavigationBar(
            height: 72,
            backgroundColor: AppColors.playerBackground,
            indicatorColor: AppColors.transparent,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.playerNavInactive),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.playerAccent),
                label: AppStrings.home,
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined, color: AppColors.playerNavInactive),
                selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.playerAccent),
                label: AppStrings.batches,
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined, color: AppColors.playerNavInactive),
                selectedIcon: Icon(Icons.calendar_today, color: AppColors.playerAccent),
                label: AppStrings.schedule,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.playerNavInactive),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.playerAccent),
                label: AppStrings.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
