import 'dart:convert';

mixin Persistent {
  void saveString(String key, String value);
  String? loadString(String key);

  void saveBool(String key, bool value) {
    final stringValue = value ? 'true' : 'false';
    saveString(key, stringValue);
  }

  bool? loadBool(String key) {
    final stringValue = loadString(key);
    if (stringValue == 'true') {
      return true;
    } else if (stringValue == 'false') {
      return false;
    }
    return null;
  }

  void saveInt(String key, int value) {
    saveString(key, value.toString());
  }

  int? loadInt(String key) {
    final stringValue = loadString(key);
    if (stringValue == null) {
      return null;
    }
    return int.tryParse(stringValue);
  }

  void saveDouble(String key, double value) {
    saveString(key, value.toString());
  }

  double? loadDouble(String key) {
    final stringValue = loadString(key);
    if (stringValue == null) {
      return null;
    }
    return double.tryParse(stringValue);
  }

  void saveJsonMap(String key, Map<String, dynamic> value) {
    saveString(key, jsonEncode(value));
  }

  Map<String, dynamic>? loadJsonMap(String key) {
    final stringValue = loadString(key);
    if (stringValue == null) {
      return null;
    }
    return jsonDecode(stringValue);
  }

  void saveJsonList(String key, List<dynamic> value) {
    saveString(key, jsonEncode(value));
  }

  List<dynamic>? loadJsonList(String key) {
    final stringValue = loadString(key);
    if (stringValue == null) {
      return null;
    }
    return jsonDecode(stringValue);
  }
}

/// A default implementation of [Persistent] that is not persistent across app restarts.
///
/// If you need persistent data across app restarts, you should implement your own Persistent.
class InMemoryPersistent with Persistent {
  final Map<String, String> _data = {};

  @override
  void saveString(String key, String value) {
    _data[key] = value;
  }

  @override
  String? loadString(String key) => _data[key];
}
