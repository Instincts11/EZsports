import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionMark {
  const SessionMark({this.here = false, this.skipReason});

  final bool here;
  final String? skipReason;

  bool get skipped => skipReason != null;
}

final todaySessionProvider = StateProvider<SessionMark>((Ref ref) => const SessionMark());

final skippedSessionsProvider = StateProvider<Map<String, String>>((Ref ref) => <String, String>{});
