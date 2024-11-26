import 'dart:async';

import 'package:flutter/material.dart';

mixin EventBusMixin on ChangeNotifier {
  final eventBus = StreamController<Object>.broadcast();
  static final _globalEventBus = StreamController<Object>.broadcast();

  Stream<T> eventStream<T>() {
    return eventBus.stream.where((event) => event is T).cast<T>();
  }

  Stream<T> globalEventStream<T>() {
    return _globalEventBus.stream.where((event) => event is T).cast<T>();
  }

  @protected
  void emit(Object event, {bool global = false}) {
    if (global) {
      _globalEventBus.sink.add(event);
    } else {
      eventBus.sink.add(event);
    }
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.sink.close();
  }
}
