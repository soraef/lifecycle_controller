import 'package:flutter/widgets.dart';
import 'package:lifecycle_controller/src/lifecycle_controller_interface.dart';
import 'package:lifecycle_controller/src/mixins/lifecycle_mixin.dart';

import 'mixins/debounce_mixin.dart';
import 'mixins/event_bus_mixin.dart';
import 'mixins/loading_mixin.dart';
import 'mixins/subscription_mixin.dart';
import 'mixins/throttle_mixin.dart';

/// A base class for controllers that manage lifecycle events and state management.
///
/// The [LifecycleController] is designed to separate the business logic from
/// the UI in Flutter applications. It provides a structured way to handle
/// screen lifecycle events, manage local state, handle asynchronous operations,
/// and simplify error handling.
///
/// By extending [LifecycleController], you can manage the state and logic of
/// your screens independently from the UI, making your code more maintainable
/// and testable.
///
/// ### Usage
///
/// ```dart
/// class MyController extends LifecycleController {
///   @override
///   void onInit() {
///     super.onInit();
///     // Initialize your controller here.
///   }
///
///   // Add your custom methods and properties here.
/// }
/// ```
///
/// You can then use this controller in your `LifecycleWidget` to build your UI.
abstract class LifecycleController
    with
        ChangeNotifier,
        LifecycleMixin,
        LoadingMixin,
        SubscriptionMixin,
        DebounceMixin,
        ThrottleMixin,
        EventBusMixin
    implements LifecycleControllerInterface {
  /// Creates a [LifecycleController] with an optional [RouteObserver].
  ///
  /// If [routeObserver] is not provided, [basePageRouteObserver] is used.
  LifecycleController({
    RouteObserver<PageRoute>? routeObserver,
  }) {
    initializeObserver(routeObserver: routeObserver);
  }

  /// Called when the controller is disposed.
  ///
  /// Override this method to perform cleanup tasks, such as cancelling timers
  /// or subscriptions.
  ///
  /// This method also automatically cancels all subscriptions and timers that
  /// were added via [addSubscription] and [debounce].
  @override
  void onDispose() {
    cancelSubscriptionAll();
    cancelDebounceAll();
    cancelThrottleAll();
  }

  static RouteObserver<PageRoute> basePageRouteObserver =
      LifecycleMixin.basePageRouteObserver;
}
