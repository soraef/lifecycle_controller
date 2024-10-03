import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lifecycle_controller.dart';

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
abstract class LifecycleWidget<T extends LifecycleController>
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

  @override
  LifecycleWidgetState<T> createState() => LifecycleWidgetState<T>();

  /// Builds the loading indicator UI.
  ///
  /// [context] is the build context, and [controller] is the associated controller.
  ///
  /// Override this method to customize the loading UI.
  ///
  /// The default implementation shows a centered [CircularProgressIndicator].
  Widget buildLoading(BuildContext context, T controller) {
    return const Center(child: CircularProgressIndicator());
  }

  /// Builds the error UI.
  ///
  /// [context] is the build context, and [controller] is the associated controller.
  ///
  /// Override this method to customize the error UI.
  ///
  /// The default implementation shows a centered text widget with the error message.
  Widget buildError(BuildContext context, T controller) {
    final errorMessage = context.select<T, String?>(
      (value) => value.errorMessage,
    );
    return Material(child: Center(child: Text(errorMessage ?? 'Error')));
  }
}

/// The state class for [LifecycleWidget], handling lifecycle events and state updates.
///
/// This class manages the [LifecycleController], subscribes to route changes,
/// and handles app lifecycle events.
///
/// You typically do not need to subclass this class.
class LifecycleWidgetState<T extends LifecycleController>
    extends State<LifecycleWidget<T>> with RouteAware, WidgetsBindingObserver {
  /// The associated controller for this widget.
  late final T controller;

  /// Initializes the state and the controller.
  ///
  /// Sets up listeners for app lifecycle events and controller notifications.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = widget.createController();
    controller.addListener(onNotifyListeners);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onInit();
    });
  }

  /// Subscribes to the route observer when dependencies change.
  ///
  /// This allows the controller to respond to route changes.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      controller.routeObserver?.subscribe(
        this,
        ModalRoute.of(context) as PageRoute,
      );
    } catch (_) {}
  }

  /// Cleans up the controller and removes observers when the widget is disposed.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.routeObserver?.unsubscribe(this);
    controller.removeListener(onNotifyListeners);
    controller.onDispose();
    super.dispose();
  }

  /// Called when the controller notifies listeners.
  ///
  /// This method calls [onNotifyListeners] on the widget.
  void onNotifyListeners() {
    widget.onNotifyListeners(context, controller);
  }

  /// Called when the route has been pushed onto the navigator.
  ///
  /// Forwards the event to the controller's [onDidPush] method.
  @override
  void didPush() {
    controller.onDidPush();
  }

  /// Called when a new route has been pushed, and the current route is no longer visible.
  ///
  /// Forwards the event to the controller's [onDidPushNext] method.
  @override
  void didPushNext() {
    controller.onDidPushNext();
  }

  /// Called when the next route has been popped off, and the current route is visible again.
  ///
  /// Forwards the event to the controller's [onDidPopNext] method.
  @override
  void didPopNext() {
    controller.onDidPopNext();
  }

  /// Called when the current route has been popped off the navigator.
  ///
  /// Forwards the event to the controller's [onDidPop] method.
  @override
  void didPop() {
    controller.onDidPop();
  }

  /// Handles app lifecycle state changes and forwards them to the controller.
  ///
  /// This allows the controller to respond to app lifecycle events.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        controller.onInactive();
        break;
      case AppLifecycleState.paused:
        controller.onPaused();
        break;
      case AppLifecycleState.resumed:
        controller.onResumed();
        break;
      case AppLifecycleState.detached:
        controller.onDetached();
        break;
      case AppLifecycleState.hidden:
        controller.onHidden();
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
      child: Builder(
        builder: (context) {
          Widget body = widget.build(context, controller);
          final isLoading = context.select<T, bool>(
            (value) => value.isLoading,
          );
          final errorMessage = context.select<T, String?>(
            (value) => value.errorMessage,
          );

          if (isLoading) {
            body = Stack(
              children: [
                body,
                widget.buildLoading(context, controller),
              ],
            );
          } else if (errorMessage != null) {
            body = widget.buildError(context, controller);
          }

          return body;
        },
      ),
    );
  }
}
