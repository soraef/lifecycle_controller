import 'package:flutter/widgets.dart';

import 'persistent.dart';

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

  /// Retrieves the Persistent for persistence used in onOnceInit.
  ///
  /// By overriding this method to return a Persistent, onOnceInit becomes available.
  /// [InMemoryPersistent] is provided as a default implementation.
  /// This is not persistent across app restarts.
  Persistent? get onceInitPersistent => InMemoryPersistent();

  bool enableInit = true;
  bool enableDispose = true;

  /// Called when the controller is first initialized.
  ///
  /// Override this method to perform initialization tasks, such as fetching
  /// data or setting up listeners.
  @protected
  void onInit() {
    if (onceInitPersistent?.loadBool(onceInitKey) ?? false) {
      onOnceInit();
      onceInitPersistent?.saveBool(onceInitKey, true);
    }
  }

  /// Called when the controller is initialized.
  ///
  /// Override this method to perform initialization tasks, such as fetching
  /// data or setting up listeners.
  void init() {
    onInit();
  }

  /// Called when the controller is disposed.
  /// Override this method to perform cleanup tasks.
  @protected
  void onDispose() {}

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  /// Called when the route has been pushed onto the navigator.
  ///
  /// This method is triggered by the [RouteObserver] when the current route
  /// becomes visible. Override it to perform actions when the screen appears.
  @protected
  void onDidPush() {
    if (routeObserver == null) {
      throw UnimplementedError(
        'routeObserver is not implemented. Please implement it in the controller.',
      );
    }
  }

  /// Called when a new route has been pushed, and the current route is no longer visible.
  ///
  /// This method is triggered when another screen covers the current screen.
  /// Override it to pause animations or other activities that should not
  /// continue when the screen is not visible.
  @protected
  void onDidPushNext() {
    if (routeObserver == null) {
      throw UnimplementedError(
        'routeObserver is not implemented. Please implement it in the controller.',
      );
    }
  }

  /// Called when the next route has been popped off, and the current route is visible again.
  ///
  /// This method is triggered when returning to the current screen from another.
  /// Override it to resume activities paused in [onDidPushNext].
  @protected
  void onDidPopNext() {
    if (routeObserver == null) {
      throw UnimplementedError(
        'routeObserver is not implemented. Please implement it in the controller.',
      );
    }
  }

  /// Called when the current route has been popped off the navigator.
  ///
  /// This method is triggered when the current screen is closed.
  /// Override it to perform cleanup that should occur when the screen is closed.
  @protected
  void onDidPop() {
    if (routeObserver == null) {
      throw UnimplementedError(
        'routeObserver is not implemented. Please implement it in the controller.',
      );
    }
  }

  /// Called when the app transitions to the [AppLifecycleState.inactive] state.
  ///
  /// This state occurs when the app is inactive and not receiving user input.
  @protected
  void onInactive() {}

  /// Called when the app transitions to the [AppLifecycleState.paused] state.
  ///
  /// This state occurs when the app is paused and not visible to the user.
  @protected
  void onPaused() {}

  /// Called when the app transitions to the [AppLifecycleState.resumed] state.
  ///
  /// This state occurs when the app is resumed and visible to the user.
  @protected
  void onResumed() {}

  /// Called when the app transitions to the [AppLifecycleState.detached] state.
  ///
  /// This state occurs when the app is still hosted on a Flutter engine but is
  /// detached from any host views.
  @protected
  void onDetached() {}

  /// Called when the app transitions to the [AppLifecycleState.hidden] state.
  ///
  /// This state occurs when the app is hidden from the user.
  @protected
  void onHidden() {}

  /// Called when the controller is initialized for the first time after the app is installed.
  ///
  /// Default implementation uses [InMemoryPersistent] that is not persistent across app restarts.
  /// To ensure this method is properly processed, you need to override [onceInitPersistent]
  /// and implement persistence logic. Additionally, you may need to override [onceInitKey]
  /// to use a different key for each controller.
  @protected
  void onOnceInit() {
    if (onceInitPersistent == null) {
      throw UnimplementedError(
        'onceInitPersistent is not implemented. Please implement it in the controller.',
      );
    }
  }

  /// The key used to persist whether [onOnceInit] has been called.
  ///
  /// This key is used for persistence, so different controllers should use
  /// different keys.
  @protected
  String get onceInitKey => '__lifecycle_controller_${runtimeType.toString()}';
}
