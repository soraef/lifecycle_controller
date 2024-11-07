import 'dart:async';

import 'package:flutter/widgets.dart';

/// A mixin that provides subscription management for Flutter controllers.
///
/// The [SubscriptionMixin] helps manage stream subscriptions, allowing automatic
/// cancellation when the controller is disposed.
mixin SubscriptionMixin on ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];

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
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Adds a [StreamSubscription] to the controller for automatic cancellation.
  ///
  /// The subscription will be cancelled when [onDispose] is called.
  ///
  /// ### Example
  ///
  /// ```dart
  /// listen<T>(
  ///   myStream,
  ///   (value) {
  ///     // Handle event
  ///   },
  /// );
  /// ```
  StreamSubscription<T> listen<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    addSubscription(subscription);
    return subscription;
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
}
