extension type LifecycleKey(String value) implements String {
  factory LifecycleKey.unique() => LifecycleKey('${_uniqueId++}');

  static int _uniqueId = 0;
}
