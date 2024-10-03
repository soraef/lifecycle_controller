import 'dart:async';

import 'package:flutter/material.dart';

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
abstract class LifecycleController extends ChangeNotifier {
  /// The [RouteObserver] used to listen to route changes.
  ///
  /// If not provided, [basePageRouteObserver] is used by default.
  late final RouteObserver<PageRoute>? routeObserver;

  /// A base [RouteObserver] that can be shared across multiple controllers.
  ///
  /// This allows for centralized observation of route changes without needing
  /// to pass a [RouteObserver] to each controller individually.
  static RouteObserver<PageRoute> basePageRouteObserver =
      RouteObserver<PageRoute>();

  // Internal timers used for debouncing actions.
  final Map<String, Timer> _debounceTimers = {};
  final Map<VoidCallback, Timer> _debounceCallbackTimers = {};

  // Internal locks used for throttling actions.
  final Map<String, bool> _throttleLocks = {};
  final Map<VoidCallback, bool> _throttleCallbackLocks = {};

  /// Creates a [LifecycleController] with an optional [RouteObserver].
  ///
  /// If [routeObserver] is not provided, [basePageRouteObserver] is used.
  LifecycleController({
    RouteObserver<PageRoute>? routeObserver,
  }) {
    if (routeObserver != null) {
      this.routeObserver = routeObserver;
    } else {
      this.routeObserver = basePageRouteObserver;
    }
  }

  // Indicates whether the controller is currently in a loading state.
  bool _isLoading = false;

  /// Whether the controller is currently loading.
  ///
  /// This can be used to show or hide loading indicators in the UI.
  bool get isLoading => _isLoading;

  /// Whether an error has occurred.
  ///
  /// Returns `true` if [errorMessage] is not `null`.
  bool get isError => _errorMessage != null;

  // The current error message, if any.
  String? _errorMessage;

  /// The current error message.
  ///
  /// This can be used to display error messages in the UI.
  String? get errorMessage => _errorMessage;

  // A list of active stream subscriptions.
  final List<StreamSubscription> _subscriptions = [];

  /// Called when the controller is first initialized.
  ///
  /// Override this method to perform initialization tasks, such as fetching
  /// data or setting up listeners.
  void onInit() {}

  /// Called when the controller is disposed.
  ///
  /// Override this method to perform cleanup tasks, such as cancelling timers
  /// or subscriptions.
  ///
  /// This method also automatically cancels all subscriptions and timers that
  /// were added via [addSubscription] and [debounce].
  void onDispose() {
    cancelSubscriptionAll();
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    for (var timer in _debounceCallbackTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _debounceCallbackTimers.clear();
  }

  /// Called when the route has been pushed onto the navigator.
  ///
  /// This method is triggered by the [RouteObserver] when the current route
  /// becomes visible. Override it to perform actions when the screen appears.
  void onDidPush() {}

  /// Called when a new route has been pushed, and the current route is no longer visible.
  ///
  /// This method is triggered when another screen covers the current screen.
  /// Override it to pause animations or other activities that should not
  /// continue when the screen is not visible.
  void onDidPushNext() {}

  /// Called when the next route has been popped off, and the current route is visible again.
  ///
  /// This method is triggered when returning to the current screen from another.
  /// Override it to resume activities paused in [onDidPushNext].
  void onDidPopNext() {}

  /// Called when the current route has been popped off the navigator.
  ///
  /// This method is triggered when the current screen is closed.
  /// Override it to perform cleanup that should occur when the screen is closed.
  void onDidPop() {}

  /// Called when the app transitions to the [AppLifecycleState.inactive] state.
  ///
  /// This state occurs when the app is inactive and not receiving user input.
  void onInactive() {}

  /// Called when the app transitions to the [AppLifecycleState.paused] state.
  ///
  /// This state occurs when the app is not visible to the user.
  void onPaused() {}

  /// Called when the app transitions to the [AppLifecycleState.resumed] state.
  ///
  /// This state occurs when the app is visible and responding to user input.
  void onResumed() {}

  /// Called when the app transitions to the [AppLifecycleState.detached] state.
  ///
  /// This state occurs when the app is still hosted on a flutter engine but is
  /// detached from any host views.
  void onDetached() {}

  /// Called when the app is hidden from the user.
  ///
  /// This is a custom state not provided by Flutter's [AppLifecycleState].
  /// Override it if you have specific actions to perform when the app is hidden.
  void onHidden() {}

  /// Sets the controller to a loading state and notifies listeners.
  ///
  /// Use this method to indicate that a loading operation has started.
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  /// Removes the loading state from the controller and notifies listeners.
  ///
  /// Use this method to indicate that a loading operation has completed.
  void endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Displays an error message and notifies listeners.
  ///
  /// [message] is the error message to display.
  ///
  /// Use this method to handle errors in asynchronous operations.
  void showError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the current error message and notifies listeners.
  ///
  /// Use this method to remove the error state after handling it.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Executes an asynchronous task with automatic loading and error handling.
  ///
  /// [task] is the asynchronous function to execute.
  ///
  /// This method will:
  /// - Set the loading state before starting the task.
  /// - Clear the loading state after the task completes.
  /// - If an error occurs, it will display the error message using [showError].
  ///
  /// If the controller is already in a loading state, the task will not be executed.
  ///
  /// ### Example
  ///
  /// ```dart
  /// await asyncRun(() async {
  ///   final data = await fetchData();
  ///   // Process data
  /// });
  /// ```
  Future<void> asyncRun(Future<void> Function() task) async {
    if (_isLoading) {
      return;
    }
    startLoading();
    try {
      await task();
    } catch (e) {
      showError(e.toString());
    } finally {
      endLoading();
    }
  }

  /// Adds a [StreamSubscription] to the controller for automatic cancellation.
  ///
  /// The subscription will be cancelled when [onDispose] is called.
  ///
  /// ### Example
  ///
  /// ```dart
  /// final subscription = myStream.listen((event) {
  ///   // Handle event
  /// });
  /// addSubscription(subscription);
  /// ```
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancels a specific [StreamSubscription] and removes it from the list.
  ///
  /// [subscription] is the subscription to cancel.
  ///
  /// Use this method to manually cancel a subscription before the controller is disposed.
  Future<void> cancelSubscription(StreamSubscription subscription) async {
    await subscription.cancel();
    _subscriptions.remove(subscription);
  }

  /// Cancels all active [StreamSubscription]s.
  ///
  /// This method is called automatically in [onDispose], but can be called
  /// manually if needed.
  Future<void> cancelSubscriptionAll() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Executes an action after a specified [duration], debouncing multiple calls.
  ///
  /// [duration] is the delay before the [action] is executed.
  /// [action] is the function to execute after the delay.
  /// [id] is an optional identifier for the debounce timer.
  ///
  /// If [id] is provided, calling [debounce] with the same [id] will reset the timer.
  /// If [id] is not provided, the [action] itself is used as the identifier.
  ///
  /// ### Example
  ///
  /// ```dart
  /// debounce(Duration(seconds: 1), () {
  ///   // Action to perform after 1 second of no new calls to debounce.
  /// });
  /// ```
  void debounce(Duration duration, VoidCallback action, {String? id}) {
    if (id != null) {
      if (_debounceTimers.containsKey(id)) {
        _debounceTimers[id]?.cancel();
      }
      _debounceTimers[id] = Timer(duration, () {
        action();
        _debounceTimers.remove(id);
      });
    } else {
      if (_debounceCallbackTimers.containsKey(action)) {
        _debounceCallbackTimers[action]?.cancel();
      }
      _debounceCallbackTimers[action] = Timer(duration, () {
        action();
        _debounceCallbackTimers.remove(action);
      });
    }
  }

  /// Executes an action after a specified [duration], throttling multiple calls.
  ///
  /// [duration] is the delay before the [action] is executed.
  /// [action] is the function to execute after the delay.
  /// [id] is an optional identifier for the throttle lock.
  ///
  /// If [id] is provided, calling [throttle] with the same [id] will prevent the action from executing until the duration has passed.
  /// If [id] is not provided, the [action] itself is used as the identifier.
  ///
  /// ### Example
  ///
  /// ```dart
  /// throttle(Duration(seconds: 1), () {
  ///  // Action to perform every 1 second.
  /// });
  /// ```
  void throttle(Duration duration, VoidCallback action, {String? id}) {
    if (id != null) {
      if (_throttleLocks.containsKey(id) && _throttleLocks[id] == true) {
        return;
      }
      _throttleLocks[id] = true;
      action();
      Timer(duration, () {
        _throttleLocks[id] = false;
      });
    } else {
      if (_throttleCallbackLocks.containsKey(action) &&
          _throttleCallbackLocks[action] == true) {
        return;
      }
      _throttleCallbackLocks[action] = true;
      action();
      Timer(duration, () {
        _throttleCallbackLocks[action] = false;
      });
    }
  }
}
