import 'dart:async';

import 'package:flutter/widgets.dart';

/// A mixin that provides debouncing capabilities for Flutter controllers.
///
/// The [DebounceMixin] allows controllers to debounce actions, ensuring that they
/// are only executed after a specified duration of inactivity.
mixin DebounceMixin on ChangeNotifier {
  final Map<String, Timer> _debounceTimers = {};

  /// Executes an action after a specified [duration], debouncing multiple calls.
  ///
  /// [id] is the identifier for the debounce timer.
  /// [duration] is the delay before the [action] is executed.
  /// [action] is the function to execute after the delay.
  ///
  /// ### Example
  ///
  /// ```dart
  /// debounce(
  ///   id: 'saveText',
  ///   duration: Duration(seconds: 1),
  ///   action: () {
  ///     // Action to perform after 1 second of no new calls to debounce.
  ///   },
  /// );
  /// ```
  void debounce({
    required String id,
    required Duration duration,
    required VoidCallback action,
  }) {
    if (_debounceTimers.containsKey(id)) {
      _debounceTimers[id]?.cancel();
    }
    _debounceTimers[id] = Timer(duration, () {
      action();
      _debounceTimers.remove(id);
    });
  }

  /// Cancels all active debounce timers.
  ///
  /// Use this method to cancel all pending debounce actions.
  void cancelDebounceAll() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }

    _debounceTimers.clear();
  }
}
