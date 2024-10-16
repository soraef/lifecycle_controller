import 'dart:async';

import 'package:flutter/material.dart';

mixin EventBusMixin on ChangeNotifier {
  final eventBus = StreamController<Object>.broadcast();

  Stream<T> eventStream<T>() {
    return eventBus.stream.where((event) => event is T).cast<T>();
  }

  void emit(Object event) {
    eventBus.sink.add(event);
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.sink.close();
  }
}
