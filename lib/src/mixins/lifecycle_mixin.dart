import 'package:flutter/widgets.dart';

/// A mixin that provides lifecycle management capabilities for Flutter controllers.
///
/// The [LifecycleMixin] manages route lifecycle events by leveraging a [RouteObserver].
/// It provides hooks such as [onInit], [onDispose], and route-related events that can
/// be overridden by controllers to handle specific tasks during the widget's lifecycle.
mixin LifecycleMixin on ChangeNotifier {
  /// The [RouteObserver] used to listen to route changes.
  ///
  /// If not provided, [basePageRouteObserver] is used by default.
  RouteObserver<PageRoute>? routeObserver;

  /// A base [RouteObserver] that can be shared across multiple controllers.
  ///
  /// This allows for centralized observation of route changes without needing
  /// to pass a [RouteObserver] to each controller individually.
  static RouteObserver<PageRoute> basePageRouteObserver =
      RouteObserver<PageRoute>();

  /// Initializes the route observer for the controller.
  ///
  /// If [routeObserver] is not provided, the default [basePageRouteObserver] is used.
  void initializeObserver({RouteObserver<PageRoute>? routeObserver}) {
    if (routeObserver != null) {
      this.routeObserver = routeObserver;
    } else {
      this.routeObserver = basePageRouteObserver;
    }
  }

  /// Called when the controller is first initialized.
  ///
  /// Override this method to perform initialization tasks, such as fetching
  /// data or setting up listeners.
  void onInit() {}

  /// Called when the controller is disposed.
  /// Override this method to perform cleanup tasks.
  void onDispose() {}

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
  /// This state occurs when the app is paused and not visible to the user.
  void onPaused() {}

  /// Called when the app transitions to the [AppLifecycleState.resumed] state.
  ///
  /// This state occurs when the app is resumed and visible to the user.
  void onResumed() {}

  /// Called when the app transitions to the [AppLifecycleState.detached] state.
  ///
  /// This state occurs when the app is still hosted on a Flutter engine but is
  /// detached from any host views.
  void onDetached() {}

  /// Called when the app transitions to the [AppLifecycleState.hidden] state.
  ///
  /// This state occurs when the app is hidden from the user.
  void onHidden() {}
}
