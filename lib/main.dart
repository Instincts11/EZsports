import 'package:ezsports/core/config/app_router.dart';
import 'package:ezsports/core/theme/app_theme.dart';
import 'package:ezsports/core/widgets/mobile_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: EzSportsApp()));
}

class EzSportsApp extends StatelessWidget {
  const EzSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ID Sports',
      theme: AppTheme.coach,
      routerConfig: AppRouter.router,
      builder: (BuildContext context, Widget? child) {
        return MobileViewport(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
