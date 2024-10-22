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
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? errorBuilder;

  const LifecycleScope._({
    super.key,
    required this.create,
    required this.builder,
    this.onNotifyListenersCallback,
    this.onEventCallback,
    this.loadingBuilder,
    this.errorBuilder,
  });

  factory LifecycleScope({
    required T controller,
    required Widget Function(BuildContext context) builder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? errorBuilder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      create: () => controller,
      builder: builder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
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
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      builder: builder,
    );
  }

  factory LifecycleScope.create({
    required T Function() create,
    required Widget Function(BuildContext context) builder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? errorBuilder,
    void Function(BuildContext context, T controller)? onNotifyListeners,
    void Function(BuildContext context, T controller, Object event)? onEvent,
  }) {
    return LifecycleScope._(
      create: create,
      builder: builder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
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

  @override
  Widget buildLoading(BuildContext context, T controller) {
    return loadingBuilder != null
        ? loadingBuilder!(context)
        : super.buildLoading(context, controller);
  }

  @override
  Widget buildError(BuildContext context, T controller) {
    return errorBuilder != null
        ? errorBuilder!(context)
        : super.buildError(context, controller);
  }
}
