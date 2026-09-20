import 'package:ezsports/features/bills/data/bills_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final billsRepositoryProvider = Provider<BillsRepository>((Ref ref) {
  return BillsRepository();
});
