// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifecycle_controller/src/lifecycle_controller_interface.dart';
import 'package:lifecycle_controller/src/mixins/lifecycle_mixin.dart';
import 'package:provider/provider.dart';

import 'lifecycle_controller.dart';
import 'mixins/event_bus_mixin.dart';

/// A base class for stateful widgets that integrate with [LifecycleController].
///
/// The [LifecycleWidget] provides a structured way to build widgets that have
/// associated controllers for managing state and lifecycle events.
///
/// By extending [LifecycleWidget], you can separate your UI code from your
/// business logic, making your code more maintainable and testable.
///
/// ### Usage
///
/// ```dart
/// class MyWidget extends LifecycleWidget<MyController> {
///   @override
///   MyController createController() {
///     return MyController();
///   }
///
///   @override
///   Widget build(BuildContext context, MyController controller) {
///     // Build your UI here, using the controller for state.
///     return Scaffold(
///       appBar: AppBar(title: Text('My Widget')),
///       body: Center(child: Text('Hello, world!')),
///     );
///   }
/// }
/// ```
abstract class LifecycleWidget<T extends LifecycleControllerInterface>
    extends StatefulWidget {
  /// Creates a [LifecycleWidget].
  const LifecycleWidget({super.key});

  /// Creates the [LifecycleController] associated with this widget.
  ///
  /// This method must be implemented by subclasses to provide the specific
  /// controller instance.
  T createController();

  /// Builds the main view for this widget.
  ///
  /// [context] is the build context, and [controller] is the associated controller.
  ///
  /// This method must be implemented by subclasses to build the UI.
  Widget build(BuildContext context, T controller);

  /// Called when the controller notifies listeners.
  ///
  /// [context] is the build context, and [controller] is the associated controller.
  ///
  /// Override this method to perform actions when the controller's state changes.
  void onNotifyListeners(BuildContext context, T controller) {}

  /// Called when event is emitted.
  void onEvent(BuildContext context, T controller, Object event) {}

  @override
  LifecycleWidgetState<T> createState() => LifecycleWidgetState<T>();
}

/// The state class for [LifecycleWidget], handling lifecycle events and state updates.
///
/// This class manages the [LifecycleController], subscribes to route changes,
/// and handles app lifecycle events.
///
/// You typically do not need to subclass this class.
class LifecycleWidgetState<T extends LifecycleControllerInterface>
    extends State<LifecycleWidget<T>> with RouteAware, WidgetsBindingObserver {
  /// The associated controller for this widget.
  late final T controller;

  StreamSubscription<Object>? _eventSubscription;
  StreamSubscription<Object>? _globalEventSubscription;

  /// Initializes the state and the controller.
  ///
  /// Sets up listeners for app lifecycle events and controller notifications.
  @override
  void initState() {
    super.initState();
    controller = widget.createController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller is LifecycleMixin &&
          (controller as LifecycleMixin).enableInit) {
        (controller as LifecycleMixin).onInit();
      }
    });

    controller.addListener(onNotifyListeners);

    if (controller is EventBusMixin) {
      _eventSubscription =
          (controller as EventBusMixin).eventStream<Object>().listen(onEvent);
      _globalEventSubscription = (controller as EventBusMixin)
          .globalEventStream<Object>()
          .listen(onEvent);
    }
  }

  @override
  void didUpdateWidget(LifecycleWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// Subscribes to the route observer when dependencies change.
  ///
  /// This allows the controller to respond to route changes.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      if (controller is LifecycleMixin) {
        (controller as LifecycleMixin)
            .routeObserver
            ?.subscribe(this, ModalRoute.of(context) as PageRoute);
      }
    } catch (_) {}
  }

  /// Cleans up the controller and removes observers when the widget is disposed.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel();
    _globalEventSubscription?.cancel();
    controller.removeListener(onNotifyListeners);

    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).routeObserver?.unsubscribe(this);
      if ((controller as LifecycleMixin).enableDispose) {
        (controller as LifecycleMixin).onDispose();
      }
    }
    super.dispose();
  }

  /// Called when the controller notifies listeners.
  ///
  /// This method calls [onNotifyListeners] on the widget.
  void onNotifyListeners() {
    widget.onNotifyListeners(context, controller);
  }

  void onEvent(Object event) {
    widget.onEvent(context, controller, event);
  }

  /// Called when the route has been pushed onto the navigator.
  ///
  /// Forwards the event to the controller's [onDidPush] method.
  @override
  void didPush() {
    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).onDidPush();
    }
  }

  /// Called when a new route has been pushed, and the current route is no longer visible.
  ///
  /// Forwards the event to the controller's [onDidPushNext] method.
  @override
  void didPushNext() {
    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).onDidPushNext();
    }
  }

  /// Called when the next route has been popped off, and the current route is visible again.
  ///
  /// Forwards the event to the controller's [onDidPopNext] method.
  @override
  void didPopNext() {
    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).onDidPopNext();
    }
  }

  /// Called when the current route has been popped off the navigator.
  ///
  /// Forwards the event to the controller's [onDidPop] method.
  @override
  void didPop() {
    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).onDidPop();
    }
  }

  /// Handles app lifecycle state changes and forwards them to the controller.
  ///
  /// This allows the controller to respond to app lifecycle events.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (controller is LifecycleMixin) {
          (controller as LifecycleMixin).onInactive();
        }
        break;
      case AppLifecycleState.paused:
        if (controller is LifecycleMixin) {
          (controller as LifecycleMixin).onPaused();
        }
        break;
      case AppLifecycleState.resumed:
        if (controller is LifecycleMixin) {
          (controller as LifecycleMixin).onResumed();
        }
        break;
      case AppLifecycleState.detached:
        if (controller is LifecycleMixin) {
          (controller as LifecycleMixin).onDetached();
        }
        break;
      case AppLifecycleState.hidden:
        if (controller is LifecycleMixin) {
          (controller as LifecycleMixin).onHidden();
        }
        break;
    }
  }

  /// Builds the widget tree and handles loading and error states.
  ///
  /// This method uses a [ChangeNotifierProvider] to provide the controller
  /// to the widget tree. It also listens to the controller's [isLoading]
  /// and [errorMessage] properties to display loading and error UIs.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Builder(builder: (context) {
        return widget.build(context, controller);
      }),
    );
  }
}
