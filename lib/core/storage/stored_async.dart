import 'package:flutter_riverpod/flutter_riverpod.dart';

extension StoredAsync<T> on AsyncValue<T> {
  AsyncValue<T> orStored(T? stored) {
    if (hasValue || stored == null) {
      return this;
    }
    return AsyncData<T>(stored);
  }
}
