import 'package:flutter/material.dart';

import '../lifecycle_controller.dart';

class LifecycleScope<T extends LifecycleControllerInterface>
    extends LifecycleWidget<T> {
  final T Function() create;
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context, T controller)?
      onNotifyListenersCallback;
  final void Function(BuildContext context, T controller, Object event)?
      onEventCallback;

  const LifecycleScope._({
    super.key,
    required this.create,
    required this.builder,
    this.onNotifyListenersCallback,
    this.onEventCallback,
  });

  @Deprecated('Use LifecycleScope.create instead')
  factory LifecycleScope({
    Key? key,
    required T controller,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      key: key,
      create: () => controller,
      builder: builder,
      onNotifyListenersCallback: onNotifyListeners,
      onEventCallback: onEvent,
    );
  }

  /// Creates the controller to be used in this scope.
  ///
  /// When the widget is initialized, the controller's `onInit` is called.
  /// When the widget is disposed, the controller's `onDispose` is called.
  factory LifecycleScope.create({
    Key? key,
    required T Function() create,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      key: key,
      create: create,
      builder: builder,
      onNotifyListenersCallback: onNotifyListeners,
      onEventCallback: onEvent,
    );
  }

  /// Uses a controller passed externally.
  ///
  /// This controller does not handle initialization or disposal. Therefore,
  /// initialization and disposal need to be managed externally, such as
  /// with a [StatefulWidget].
  ///
  /// ```dart
  /// class _MyPageState extends State<MyPage> {
  ///   late MyController controller;
  ///
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     controller = MyController();
  ///     controller.init();
  ///   }
  ///
  ///   @override
  ///   void dispose() {
  ///     controller.dispose();
  ///     super.dispose();
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return LifecycleScope.value(
  ///       controller: controller,
  ///       builder: (context) => Text('MyPage'),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  factory LifecycleScope.value({
    Key? key,
    required T controller,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    /// Disable init and dispose for the controller
    if (controller is LifecycleMixin) {
      (controller as LifecycleMixin).enableInit = false;
      (controller as LifecycleMixin).enableDispose = false;
    }

    return LifecycleScope._(
      key: key,
      create: () => controller,
      builder: builder,
      onNotifyListenersCallback: onNotifyListeners,
      onEventCallback: onEvent,
    );
  }

  @override
  T createController() {
    return create();
  }

  @override
  Widget build(BuildContext context, T controller) {
    return builder(context);
  }

  @override
  void onNotifyListeners(BuildContext context, T controller) {
    if (onNotifyListenersCallback != null) {
      onNotifyListenersCallback!(context, controller);
    }
  }

  /// Called when an event is emitted.
  @override
  void onEvent(BuildContext context, T controller, Object event) {
    if (onEventCallback != null) {
      onEventCallback!(context, controller, event);
    }
  }
}
