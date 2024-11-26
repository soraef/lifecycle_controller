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

  factory LifecycleScope({
    required T controller,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      create: () => controller,
      builder: builder,
      onNotifyListenersCallback: onNotifyListeners,
      onEventCallback: onEvent,
    );
  }

  factory LifecycleScope.value({
    required T controller,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? errorBuilder,
  }) {
    return LifecycleScope._(
      create: () => controller,
      onNotifyListenersCallback: onNotifyListeners,
      onEventCallback: onEvent,
      builder: builder,
    );
  }

  factory LifecycleScope.create({
    required T Function() create,
    required Widget Function(BuildContext context) builder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      create: create,
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

  /// Called when event is emitted.
  @override
  void onEvent(BuildContext context, T controller, Object event) {
    if (onEventCallback != null) {
      onEventCallback!(context, controller, event);
    }
  }
}
