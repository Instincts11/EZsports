import 'package:ezsports/features/home/data/home_repository.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider<HomeRepository>((Ref ref) {
  return HomeRepository();
});

final homeDashboardProvider = FutureProvider.autoDispose<HomeDashboardModel>((Ref ref) {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});
