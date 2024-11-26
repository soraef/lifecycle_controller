import 'dart:async';

import 'package:flutter/widgets.dart';

/// This mixin prevents a method that has been called once from being called again
mixin LockerMixin on ChangeNotifier {
  Map<String, bool> _lockerStates = {};

  /// Lock a method.
  @protected
  Future<T?> lock<T>({
    required String id,
    required FutureOr<T> Function() action,
  }) async {
    if (isLocked(id)) {
      return null;
    }
    _lockerStates = {..._lockerStates, id: true};
    notifyListeners();

    final result = await action();

    _lockerStates = {..._lockerStates, id: false};
    notifyListeners();
    return result;
  }

  /// Check if a method is locked.
  bool isLocked(String id) =>
      _lockerStates.containsKey(id) && _lockerStates[id] == true;
}
