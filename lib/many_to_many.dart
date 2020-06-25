import 'dart:collection';

import 'package:quiver/collection.dart';

abstract class ID {
  String get id;
}

abstract class OnDate {
  DateTime get date;

  static int order(OnDate a, OnDate b) {
    if (a.date == null && b.date == null) {
      return 1;
    }
    // Note with null date comes first
    if (a.date == null) {
      return -1;
    }
    if (b.date == null) {
      return 1;
    }
    return -a.date.compareTo(b.date);
  }
}

/// Container
class _C<T extends ID> {
  _C(this.content);
  T content;
  String get id => content.id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _C &&
          runtimeType == other.runtimeType &&
          content.id == other.content.id;

  @override
  int get hashCode => content.id.hashCode;
}

/// Many-to-many map from NTag to note IDs. Or PTag to person IDs.
class IdMap<T extends ID> {
  final SetMultimap<_C<T>, String> _multimap = SetMultimap();
  final SetMultimap<String, _C<T>> _inverse = SetMultimap();

  final Map<String, _C<T>> _keys = {};

  /// Add with association
  void add(String keyId, String value) {
    final c = _keys[keyId];
    if (c == null) {
      throw Exception('$keyId is not present');
    }
    _multimap.add(c, value);
    _inverse.add(value, c);
  }

  /// Add without any association
  void addKey(T key) {
    if (key.id == null) {
      throw Exception('The key does not have ID');
    }
    _keys.putIfAbsent(key.id, () => _C(key));
  }

  UnmodifiableListView<T> get keys {
    final ks = _keys.values.map((c) => c.content);
    return UnmodifiableListView(ks);
  }

  UnmodifiableListView<String> getValues(T key) {
    final kc = _keys[key.id];
    if (kc == null) {
      return UnmodifiableListView([]);
    }
    final values = _multimap[kc];
    return UnmodifiableListView(values);
  }

  UnmodifiableListView<T> getKeys(String value) {
    final keys = _inverse[value];
    return UnmodifiableListView(keys.map((_C<T> c) => c.content));
  }

  void remove(String keyId, String value) {
    final c = _keys[keyId];
    if (c == null) {
      throw Exception('$keyId is not present');
    }

    _multimap.remove(c, value);
    _inverse.remove(value, c);
  }

  void removeKey(T key) {
    final keyId = key.id;
    final c = _keys[keyId];
    if (_multimap.containsKey(c)) {
      throw Exception('$key is still has association.');
    }
    _keys.remove(keyId);
  }

  void updateKey(T k) {
    final container = _keys[k.id];
    if (container == null) {
      throw Exception('The key is not present ${k.id}');
    }
    container.content = k;
  }

  void clear() {
    _multimap.clear();
    _inverse.clear();
    _keys.clear();
  }
}
