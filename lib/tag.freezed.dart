// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$PTagTearOff {
  const _$PTagTearOff();

  _PTag call({String id, String name}) {
    return _PTag(
      id: id,
      name: name,
    );
  }
}

// ignore: unused_element
const $PTag = _$PTagTearOff();

mixin _$PTag {
  String get id;
  String get name;

  $PTagCopyWith<PTag> get copyWith;
}

abstract class $PTagCopyWith<$Res> {
  factory $PTagCopyWith(PTag value, $Res Function(PTag) then) =
      _$PTagCopyWithImpl<$Res>;
  $Res call({String id, String name});
}

class _$PTagCopyWithImpl<$Res> implements $PTagCopyWith<$Res> {
  _$PTagCopyWithImpl(this._value, this._then);

  final PTag _value;
  // ignore: unused_field
  final $Res Function(PTag) _then;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
    ));
  }
}

abstract class _$PTagCopyWith<$Res> implements $PTagCopyWith<$Res> {
  factory _$PTagCopyWith(_PTag value, $Res Function(_PTag) then) =
      __$PTagCopyWithImpl<$Res>;
  @override
  $Res call({String id, String name});
}

class __$PTagCopyWithImpl<$Res> extends _$PTagCopyWithImpl<$Res>
    implements _$PTagCopyWith<$Res> {
  __$PTagCopyWithImpl(_PTag _value, $Res Function(_PTag) _then)
      : super(_value, (v) => _then(v as _PTag));

  @override
  _PTag get _value => super._value as _PTag;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
  }) {
    return _then(_PTag(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
    ));
  }
}

class _$_PTag with DiagnosticableTreeMixin implements _PTag {
  _$_PTag({this.id, this.name});

  @override
  final String id;
  @override
  final String name;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PTag(id: $id, name: $name)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PTag'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _PTag &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name);

  @override
  _$PTagCopyWith<_PTag> get copyWith =>
      __$PTagCopyWithImpl<_PTag>(this, _$identity);
}

abstract class _PTag implements PTag {
  factory _PTag({String id, String name}) = _$_PTag;

  @override
  String get id;
  @override
  String get name;
  @override
  _$PTagCopyWith<_PTag> get copyWith;
}

class _$EditTagResultTearOff {
  const _$EditTagResultTearOff();

  Deleted deleted(PTag tag) {
    return Deleted(
      tag,
    );
  }

  Updated updated(PTag tag) {
    return Updated(
      tag,
    );
  }
}

// ignore: unused_element
const $EditTagResult = _$EditTagResultTearOff();

mixin _$EditTagResult {
  PTag get tag;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(PTag tag),
    @required Result updated(PTag tag),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(PTag tag),
    Result updated(PTag tag),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result deleted(Deleted value),
    @required Result updated(Updated value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result deleted(Deleted value),
    Result updated(Updated value),
    @required Result orElse(),
  });

  $EditTagResultCopyWith<EditTagResult> get copyWith;
}

abstract class $EditTagResultCopyWith<$Res> {
  factory $EditTagResultCopyWith(
          EditTagResult value, $Res Function(EditTagResult) then) =
      _$EditTagResultCopyWithImpl<$Res>;
  $Res call({PTag tag});

  $PTagCopyWith<$Res> get tag;
}

class _$EditTagResultCopyWithImpl<$Res>
    implements $EditTagResultCopyWith<$Res> {
  _$EditTagResultCopyWithImpl(this._value, this._then);

  final EditTagResult _value;
  // ignore: unused_field
  final $Res Function(EditTagResult) _then;

  @override
  $Res call({
    Object tag = freezed,
  }) {
    return _then(_value.copyWith(
      tag: tag == freezed ? _value.tag : tag as PTag,
    ));
  }

  @override
  $PTagCopyWith<$Res> get tag {
    if (_value.tag == null) {
      return null;
    }
    return $PTagCopyWith<$Res>(_value.tag, (value) {
      return _then(_value.copyWith(tag: value));
    });
  }
}

abstract class $DeletedCopyWith<$Res> implements $EditTagResultCopyWith<$Res> {
  factory $DeletedCopyWith(Deleted value, $Res Function(Deleted) then) =
      _$DeletedCopyWithImpl<$Res>;
  @override
  $Res call({PTag tag});

  @override
  $PTagCopyWith<$Res> get tag;
}

class _$DeletedCopyWithImpl<$Res> extends _$EditTagResultCopyWithImpl<$Res>
    implements $DeletedCopyWith<$Res> {
  _$DeletedCopyWithImpl(Deleted _value, $Res Function(Deleted) _then)
      : super(_value, (v) => _then(v as Deleted));

  @override
  Deleted get _value => super._value as Deleted;

  @override
  $Res call({
    Object tag = freezed,
  }) {
    return _then(Deleted(
      tag == freezed ? _value.tag : tag as PTag,
    ));
  }
}

class _$Deleted with DiagnosticableTreeMixin implements Deleted {
  const _$Deleted(this.tag) : assert(tag != null);

  @override
  final PTag tag;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditTagResult.deleted(tag: $tag)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EditTagResult.deleted'))
      ..add(DiagnosticsProperty('tag', tag));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Deleted &&
            (identical(other.tag, tag) ||
                const DeepCollectionEquality().equals(other.tag, tag)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(tag);

  @override
  $DeletedCopyWith<Deleted> get copyWith =>
      _$DeletedCopyWithImpl<Deleted>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(PTag tag),
    @required Result updated(PTag tag),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return deleted(tag);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(PTag tag),
    Result updated(PTag tag),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (deleted != null) {
      return deleted(tag);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result deleted(Deleted value),
    @required Result updated(Updated value),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return deleted(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result deleted(Deleted value),
    Result updated(Updated value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (deleted != null) {
      return deleted(this);
    }
    return orElse();
  }
}

abstract class Deleted implements EditTagResult {
  const factory Deleted(PTag tag) = _$Deleted;

  @override
  PTag get tag;
  @override
  $DeletedCopyWith<Deleted> get copyWith;
}

abstract class $UpdatedCopyWith<$Res> implements $EditTagResultCopyWith<$Res> {
  factory $UpdatedCopyWith(Updated value, $Res Function(Updated) then) =
      _$UpdatedCopyWithImpl<$Res>;
  @override
  $Res call({PTag tag});

  @override
  $PTagCopyWith<$Res> get tag;
}

class _$UpdatedCopyWithImpl<$Res> extends _$EditTagResultCopyWithImpl<$Res>
    implements $UpdatedCopyWith<$Res> {
  _$UpdatedCopyWithImpl(Updated _value, $Res Function(Updated) _then)
      : super(_value, (v) => _then(v as Updated));

  @override
  Updated get _value => super._value as Updated;

  @override
  $Res call({
    Object tag = freezed,
  }) {
    return _then(Updated(
      tag == freezed ? _value.tag : tag as PTag,
    ));
  }
}

class _$Updated with DiagnosticableTreeMixin implements Updated {
  const _$Updated(this.tag) : assert(tag != null);

  @override
  final PTag tag;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditTagResult.updated(tag: $tag)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EditTagResult.updated'))
      ..add(DiagnosticsProperty('tag', tag));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Updated &&
            (identical(other.tag, tag) ||
                const DeepCollectionEquality().equals(other.tag, tag)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(tag);

  @override
  $UpdatedCopyWith<Updated> get copyWith =>
      _$UpdatedCopyWithImpl<Updated>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(PTag tag),
    @required Result updated(PTag tag),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return updated(tag);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(PTag tag),
    Result updated(PTag tag),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updated != null) {
      return updated(tag);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result deleted(Deleted value),
    @required Result updated(Updated value),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return updated(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result deleted(Deleted value),
    Result updated(Updated value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updated != null) {
      return updated(this);
    }
    return orElse();
  }
}

abstract class Updated implements EditTagResult {
  const factory Updated(PTag tag) = _$Updated;

  @override
  PTag get tag;
  @override
  $UpdatedCopyWith<Updated> get copyWith;
}

class _$NTagTearOff {
  const _$NTagTearOff();

  _NTag call({String id, String name, Timestamp updated}) {
    return _NTag(
      id: id,
      name: name,
      updated: updated,
    );
  }
}

// ignore: unused_element
const $NTag = _$NTagTearOff();

mixin _$NTag {
  String get id;
  String get name;
  Timestamp get updated;

  $NTagCopyWith<NTag> get copyWith;
}

abstract class $NTagCopyWith<$Res> {
  factory $NTagCopyWith(NTag value, $Res Function(NTag) then) =
      _$NTagCopyWithImpl<$Res>;
  $Res call({String id, String name, Timestamp updated});
}

class _$NTagCopyWithImpl<$Res> implements $NTagCopyWith<$Res> {
  _$NTagCopyWithImpl(this._value, this._then);

  final NTag _value;
  // ignore: unused_field
  final $Res Function(NTag) _then;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object updated = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
    ));
  }
}

abstract class _$NTagCopyWith<$Res> implements $NTagCopyWith<$Res> {
  factory _$NTagCopyWith(_NTag value, $Res Function(_NTag) then) =
      __$NTagCopyWithImpl<$Res>;
  @override
  $Res call({String id, String name, Timestamp updated});
}

class __$NTagCopyWithImpl<$Res> extends _$NTagCopyWithImpl<$Res>
    implements _$NTagCopyWith<$Res> {
  __$NTagCopyWithImpl(_NTag _value, $Res Function(_NTag) _then)
      : super(_value, (v) => _then(v as _NTag));

  @override
  _NTag get _value => super._value as _NTag;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object updated = freezed,
  }) {
    return _then(_NTag(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
    ));
  }
}

class _$_NTag with DiagnosticableTreeMixin implements _NTag {
  _$_NTag({this.id, this.name, this.updated});

  @override
  final String id;
  @override
  final String name;
  @override
  final Timestamp updated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NTag(id: $id, name: $name, updated: $updated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NTag'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('updated', updated));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NTag &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.updated, updated) ||
                const DeepCollectionEquality().equals(other.updated, updated)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(updated);

  @override
  _$NTagCopyWith<_NTag> get copyWith =>
      __$NTagCopyWithImpl<_NTag>(this, _$identity);
}

abstract class _NTag implements NTag {
  factory _NTag({String id, String name, Timestamp updated}) = _$_NTag;

  @override
  String get id;
  @override
  String get name;
  @override
  Timestamp get updated;
  @override
  _$NTagCopyWith<_NTag> get copyWith;
}

class _$NoteReplicaTearOff {
  const _$NoteReplicaTearOff();

  _NoteReplica call(
      {String id,
      String personId,
      String content,
      DateTime date,
      Set<String> tagIds = const <String>{},
      Set<String> tagPersonIds = const <String>{},
      String documentPath,
      List<String> pictureUrls = const <String>[],
      Timestamp updated}) {
    return _NoteReplica(
      id: id,
      personId: personId,
      content: content,
      date: date,
      tagIds: tagIds,
      tagPersonIds: tagPersonIds,
      documentPath: documentPath,
      pictureUrls: pictureUrls,
      updated: updated,
    );
  }
}

// ignore: unused_element
const $NoteReplica = _$NoteReplicaTearOff();

mixin _$NoteReplica {
  String get id;
  String get personId;
  String get content;
  DateTime get date;
  Set<String> get tagIds;
  Set<String> get tagPersonIds;
  String get documentPath;
  List<String> get pictureUrls;
  Timestamp get updated;

  $NoteReplicaCopyWith<NoteReplica> get copyWith;
}

abstract class $NoteReplicaCopyWith<$Res> {
  factory $NoteReplicaCopyWith(
          NoteReplica value, $Res Function(NoteReplica) then) =
      _$NoteReplicaCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String personId,
      String content,
      DateTime date,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      String documentPath,
      List<String> pictureUrls,
      Timestamp updated});
}

class _$NoteReplicaCopyWithImpl<$Res> implements $NoteReplicaCopyWith<$Res> {
  _$NoteReplicaCopyWithImpl(this._value, this._then);

  final NoteReplica _value;
  // ignore: unused_field
  final $Res Function(NoteReplica) _then;

  @override
  $Res call({
    Object id = freezed,
    Object personId = freezed,
    Object content = freezed,
    Object date = freezed,
    Object tagIds = freezed,
    Object tagPersonIds = freezed,
    Object documentPath = freezed,
    Object pictureUrls = freezed,
    Object updated = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      personId: personId == freezed ? _value.personId : personId as String,
      content: content == freezed ? _value.content : content as String,
      date: date == freezed ? _value.date : date as DateTime,
      tagIds: tagIds == freezed ? _value.tagIds : tagIds as Set<String>,
      tagPersonIds: tagPersonIds == freezed
          ? _value.tagPersonIds
          : tagPersonIds as Set<String>,
      documentPath: documentPath == freezed
          ? _value.documentPath
          : documentPath as String,
      pictureUrls: pictureUrls == freezed
          ? _value.pictureUrls
          : pictureUrls as List<String>,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
    ));
  }
}

abstract class _$NoteReplicaCopyWith<$Res>
    implements $NoteReplicaCopyWith<$Res> {
  factory _$NoteReplicaCopyWith(
          _NoteReplica value, $Res Function(_NoteReplica) then) =
      __$NoteReplicaCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String personId,
      String content,
      DateTime date,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      String documentPath,
      List<String> pictureUrls,
      Timestamp updated});
}

class __$NoteReplicaCopyWithImpl<$Res> extends _$NoteReplicaCopyWithImpl<$Res>
    implements _$NoteReplicaCopyWith<$Res> {
  __$NoteReplicaCopyWithImpl(
      _NoteReplica _value, $Res Function(_NoteReplica) _then)
      : super(_value, (v) => _then(v as _NoteReplica));

  @override
  _NoteReplica get _value => super._value as _NoteReplica;

  @override
  $Res call({
    Object id = freezed,
    Object personId = freezed,
    Object content = freezed,
    Object date = freezed,
    Object tagIds = freezed,
    Object tagPersonIds = freezed,
    Object documentPath = freezed,
    Object pictureUrls = freezed,
    Object updated = freezed,
  }) {
    return _then(_NoteReplica(
      id: id == freezed ? _value.id : id as String,
      personId: personId == freezed ? _value.personId : personId as String,
      content: content == freezed ? _value.content : content as String,
      date: date == freezed ? _value.date : date as DateTime,
      tagIds: tagIds == freezed ? _value.tagIds : tagIds as Set<String>,
      tagPersonIds: tagPersonIds == freezed
          ? _value.tagPersonIds
          : tagPersonIds as Set<String>,
      documentPath: documentPath == freezed
          ? _value.documentPath
          : documentPath as String,
      pictureUrls: pictureUrls == freezed
          ? _value.pictureUrls
          : pictureUrls as List<String>,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
    ));
  }
}

class _$_NoteReplica with DiagnosticableTreeMixin implements _NoteReplica {
  _$_NoteReplica(
      {this.id,
      this.personId,
      this.content,
      this.date,
      this.tagIds = const <String>{},
      this.tagPersonIds = const <String>{},
      this.documentPath,
      this.pictureUrls = const <String>[],
      this.updated})
      : assert(tagIds != null),
        assert(tagPersonIds != null),
        assert(pictureUrls != null);

  @override
  final String id;
  @override
  final String personId;
  @override
  final String content;
  @override
  final DateTime date;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> tagIds;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> tagPersonIds;
  @override
  final String documentPath;
  @JsonKey(defaultValue: const <String>[])
  @override
  final List<String> pictureUrls;
  @override
  final Timestamp updated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteReplica(id: $id, personId: $personId, content: $content, date: $date, tagIds: $tagIds, tagPersonIds: $tagPersonIds, documentPath: $documentPath, pictureUrls: $pictureUrls, updated: $updated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteReplica'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('personId', personId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('tagIds', tagIds))
      ..add(DiagnosticsProperty('tagPersonIds', tagPersonIds))
      ..add(DiagnosticsProperty('documentPath', documentPath))
      ..add(DiagnosticsProperty('pictureUrls', pictureUrls))
      ..add(DiagnosticsProperty('updated', updated));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NoteReplica &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.personId, personId) ||
                const DeepCollectionEquality()
                    .equals(other.personId, personId)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality()
                    .equals(other.content, content)) &&
            (identical(other.date, date) ||
                const DeepCollectionEquality().equals(other.date, date)) &&
            (identical(other.tagIds, tagIds) ||
                const DeepCollectionEquality().equals(other.tagIds, tagIds)) &&
            (identical(other.tagPersonIds, tagPersonIds) ||
                const DeepCollectionEquality()
                    .equals(other.tagPersonIds, tagPersonIds)) &&
            (identical(other.documentPath, documentPath) ||
                const DeepCollectionEquality()
                    .equals(other.documentPath, documentPath)) &&
            (identical(other.pictureUrls, pictureUrls) ||
                const DeepCollectionEquality()
                    .equals(other.pictureUrls, pictureUrls)) &&
            (identical(other.updated, updated) ||
                const DeepCollectionEquality().equals(other.updated, updated)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(personId) ^
      const DeepCollectionEquality().hash(content) ^
      const DeepCollectionEquality().hash(date) ^
      const DeepCollectionEquality().hash(tagIds) ^
      const DeepCollectionEquality().hash(tagPersonIds) ^
      const DeepCollectionEquality().hash(documentPath) ^
      const DeepCollectionEquality().hash(pictureUrls) ^
      const DeepCollectionEquality().hash(updated);

  @override
  _$NoteReplicaCopyWith<_NoteReplica> get copyWith =>
      __$NoteReplicaCopyWithImpl<_NoteReplica>(this, _$identity);
}

abstract class _NoteReplica implements NoteReplica {
  factory _NoteReplica(
      {String id,
      String personId,
      String content,
      DateTime date,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      String documentPath,
      List<String> pictureUrls,
      Timestamp updated}) = _$_NoteReplica;

  @override
  String get id;
  @override
  String get personId;
  @override
  String get content;
  @override
  DateTime get date;
  @override
  Set<String> get tagIds;
  @override
  Set<String> get tagPersonIds;
  @override
  String get documentPath;
  @override
  List<String> get pictureUrls;
  @override
  Timestamp get updated;
  @override
  _$NoteReplicaCopyWith<_NoteReplica> get copyWith;
}
