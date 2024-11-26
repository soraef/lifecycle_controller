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
  @protected
  Future<T?> debounce<T>({
    required String id,
    required Duration duration,
    required FutureOr<T> Function() action,
  }) async {
    Completer<T?> completer = Completer<T?>();

    if (_debounceTimers.containsKey(id)) {
      _debounceTimers[id]?.cancel();
      completer.complete(null);
    }

    _debounceTimers[id] = Timer(duration, () async {
      final result = await action();
      _debounceTimers.remove(id);
      completer.complete(result);
    });

    return completer.future;
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
