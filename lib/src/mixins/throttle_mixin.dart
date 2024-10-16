import 'dart:async';

import 'package:flutter/widgets.dart';

/// A mixin that provides throttling capabilities for Flutter controllers.
///
/// The [ThrottleMixin] allows controllers to throttle actions, ensuring that they
/// are only executed once within a specified duration.
mixin ThrottleMixin on ChangeNotifier {
  final Map<String, bool> _throttleLocks = {};

  /// Executes an action after a specified [duration], throttling multiple calls.
  ///
  /// [duration] is the delay before the [action] is executed.
  /// [action] is the function to execute after the delay.
  /// [id] is an optional identifier for the throttle timer.
  ///
  /// If [id] is provided, calling [throttle] with the same [id] will prevent the action from executing until the duration has passed.
  /// If [id] is not provided, the [action] itself is used as the identifier.
  ///
  /// ### Example
  ///
  /// ```dart
  /// throttle(
  ///   id: 'search',
  ///   duration: Duration(seconds: 1),
  ///   action: () {
  ///     // Action to perform every 1 second.
  ///   },
  /// );
  /// ```
  void throttle({
    required VoidCallback action,
    required Duration duration,
    required String id,
  }) {
    // Check if the throttle lock is already set
    if (_throttleLocks.containsKey(id) && _throttleLocks[id] == true) {
      return;
    }
    _throttleLocks[id] = true;
    action();
    Timer(duration, () {
      _throttleLocks[id] = false;
    });
  }

  /// Cancels all active throttle timers.
  ///
  /// Use this method to cancel all pending throttle actions.
  void cancelThrottleAll() {
    _throttleLocks.clear();
  }
}
