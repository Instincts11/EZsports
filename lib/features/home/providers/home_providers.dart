import 'package:ezsports/core/network/api_endpoints.dart';
import 'package:ezsports/core/storage/response_cache.dart';
import 'package:ezsports/core/storage/stored_async.dart';
import 'package:ezsports/features/home/data/home_repository.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider<HomeRepository>((Ref ref) {
  return HomeRepository();
});

final homeDashboardProvider = FutureProvider<HomeDashboardModel>((Ref ref) {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});

AsyncValue<HomeDashboardModel> watchHomeDashboard(WidgetRef ref) {
  return ref.watch(homeDashboardProvider).orStored(
        ResponseCache.map(ApiEndpoints.home, HomeDashboardModel.fromJson),
      );
}
