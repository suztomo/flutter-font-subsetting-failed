// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$NoteTearOff {
  const _$NoteTearOff();

  _Note call(
      {String id,
      String content,
      DateTime date,
      DocumentReference document,
      Set<String> tagIds = const <String>{},
      Set<String> tagPersonIds = const <String>{},
      Timestamp updated,
      bool deleted = false,
      List<String> pictureUrls = const <String>[]}) {
    return _Note(
      id: id,
      content: content,
      date: date,
      document: document,
      tagIds: tagIds,
      tagPersonIds: tagPersonIds,
      updated: updated,
      deleted: deleted,
      pictureUrls: pictureUrls,
    );
  }
}

// ignore: unused_element
const $Note = _$NoteTearOff();

mixin _$Note {
  String get id;
  String get content;
  DateTime get date;
  DocumentReference get document;
  Set<String> get tagIds;
  Set<String> get tagPersonIds;
  Timestamp get updated;
  bool get deleted;
  List<String> get pictureUrls;

  $NoteCopyWith<Note> get copyWith;
}

abstract class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) then) =
      _$NoteCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String content,
      DateTime date,
      DocumentReference document,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      Timestamp updated,
      bool deleted,
      List<String> pictureUrls});
}

class _$NoteCopyWithImpl<$Res> implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._value, this._then);

  final Note _value;
  // ignore: unused_field
  final $Res Function(Note) _then;

  @override
  $Res call({
    Object id = freezed,
    Object content = freezed,
    Object date = freezed,
    Object document = freezed,
    Object tagIds = freezed,
    Object tagPersonIds = freezed,
    Object updated = freezed,
    Object deleted = freezed,
    Object pictureUrls = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      content: content == freezed ? _value.content : content as String,
      date: date == freezed ? _value.date : date as DateTime,
      document:
          document == freezed ? _value.document : document as DocumentReference,
      tagIds: tagIds == freezed ? _value.tagIds : tagIds as Set<String>,
      tagPersonIds: tagPersonIds == freezed
          ? _value.tagPersonIds
          : tagPersonIds as Set<String>,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
      deleted: deleted == freezed ? _value.deleted : deleted as bool,
      pictureUrls: pictureUrls == freezed
          ? _value.pictureUrls
          : pictureUrls as List<String>,
    ));
  }
}

abstract class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) then) =
      __$NoteCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String content,
      DateTime date,
      DocumentReference document,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      Timestamp updated,
      bool deleted,
      List<String> pictureUrls});
}

class __$NoteCopyWithImpl<$Res> extends _$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(_Note _value, $Res Function(_Note) _then)
      : super(_value, (v) => _then(v as _Note));

  @override
  _Note get _value => super._value as _Note;

  @override
  $Res call({
    Object id = freezed,
    Object content = freezed,
    Object date = freezed,
    Object document = freezed,
    Object tagIds = freezed,
    Object tagPersonIds = freezed,
    Object updated = freezed,
    Object deleted = freezed,
    Object pictureUrls = freezed,
  }) {
    return _then(_Note(
      id: id == freezed ? _value.id : id as String,
      content: content == freezed ? _value.content : content as String,
      date: date == freezed ? _value.date : date as DateTime,
      document:
          document == freezed ? _value.document : document as DocumentReference,
      tagIds: tagIds == freezed ? _value.tagIds : tagIds as Set<String>,
      tagPersonIds: tagPersonIds == freezed
          ? _value.tagPersonIds
          : tagPersonIds as Set<String>,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
      deleted: deleted == freezed ? _value.deleted : deleted as bool,
      pictureUrls: pictureUrls == freezed
          ? _value.pictureUrls
          : pictureUrls as List<String>,
    ));
  }
}

class _$_Note with DiagnosticableTreeMixin implements _Note {
  _$_Note(
      {this.id,
      this.content,
      this.date,
      this.document,
      this.tagIds = const <String>{},
      this.tagPersonIds = const <String>{},
      this.updated,
      this.deleted = false,
      this.pictureUrls = const <String>[]})
      : assert(tagIds != null),
        assert(tagPersonIds != null),
        assert(deleted != null),
        assert(pictureUrls != null);

  @override
  final String id;
  @override
  final String content;
  @override
  final DateTime date;
  @override
  final DocumentReference document;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> tagIds;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> tagPersonIds;
  @override
  final Timestamp updated;
  @JsonKey(defaultValue: false)
  @override
  final bool deleted;
  @JsonKey(defaultValue: const <String>[])
  @override
  final List<String> pictureUrls;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Note(id: $id, content: $content, date: $date, document: $document, tagIds: $tagIds, tagPersonIds: $tagPersonIds, updated: $updated, deleted: $deleted, pictureUrls: $pictureUrls)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Note'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('document', document))
      ..add(DiagnosticsProperty('tagIds', tagIds))
      ..add(DiagnosticsProperty('tagPersonIds', tagPersonIds))
      ..add(DiagnosticsProperty('updated', updated))
      ..add(DiagnosticsProperty('deleted', deleted))
      ..add(DiagnosticsProperty('pictureUrls', pictureUrls));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Note &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality()
                    .equals(other.content, content)) &&
            (identical(other.date, date) ||
                const DeepCollectionEquality().equals(other.date, date)) &&
            (identical(other.document, document) ||
                const DeepCollectionEquality()
                    .equals(other.document, document)) &&
            (identical(other.tagIds, tagIds) ||
                const DeepCollectionEquality().equals(other.tagIds, tagIds)) &&
            (identical(other.tagPersonIds, tagPersonIds) ||
                const DeepCollectionEquality()
                    .equals(other.tagPersonIds, tagPersonIds)) &&
            (identical(other.updated, updated) ||
                const DeepCollectionEquality()
                    .equals(other.updated, updated)) &&
            (identical(other.deleted, deleted) ||
                const DeepCollectionEquality()
                    .equals(other.deleted, deleted)) &&
            (identical(other.pictureUrls, pictureUrls) ||
                const DeepCollectionEquality()
                    .equals(other.pictureUrls, pictureUrls)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(content) ^
      const DeepCollectionEquality().hash(date) ^
      const DeepCollectionEquality().hash(document) ^
      const DeepCollectionEquality().hash(tagIds) ^
      const DeepCollectionEquality().hash(tagPersonIds) ^
      const DeepCollectionEquality().hash(updated) ^
      const DeepCollectionEquality().hash(deleted) ^
      const DeepCollectionEquality().hash(pictureUrls);

  @override
  _$NoteCopyWith<_Note> get copyWith =>
      __$NoteCopyWithImpl<_Note>(this, _$identity);
}

abstract class _Note implements Note {
  factory _Note(
      {String id,
      String content,
      DateTime date,
      DocumentReference document,
      Set<String> tagIds,
      Set<String> tagPersonIds,
      Timestamp updated,
      bool deleted,
      List<String> pictureUrls}) = _$_Note;

  @override
  String get id;
  @override
  String get content;
  @override
  DateTime get date;
  @override
  DocumentReference get document;
  @override
  Set<String> get tagIds;
  @override
  Set<String> get tagPersonIds;
  @override
  Timestamp get updated;
  @override
  bool get deleted;
  @override
  List<String> get pictureUrls;
  @override
  _$NoteCopyWith<_Note> get copyWith;
}
