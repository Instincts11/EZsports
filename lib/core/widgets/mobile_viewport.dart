import 'dart:math' as math;

import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class MobileViewport extends StatelessWidget {
  const MobileViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.shortestSide < AppSizes.phoneBreakpoint) {
      return child;
    }

    final double frameHeight = math.min(
      mediaQuery.size.height - AppSizes.phoneFrameMargin,
      AppSizes.phoneHeight,
    );

    return ColoredBox(
      color: AppColors.backgroundAlt,
      child: Center(
        child: Container(
          width: AppSizes.phoneWidth,
          height: frameHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.phoneFrameRadius),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(size: Size(AppSizes.phoneWidth, frameHeight)),
            child: child,
          ),
        ),
      ),
    );
  }
}
