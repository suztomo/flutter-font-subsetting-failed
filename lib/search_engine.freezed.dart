// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'search_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SearchResultTearOff {
  const _$SearchResultTearOff();

  _SearchResult call({String personId, String noteId, String noteContent}) {
    return _SearchResult(
      personId: personId,
      noteId: noteId,
      noteContent: noteContent,
    );
  }
}

// ignore: unused_element
const $SearchResult = _$SearchResultTearOff();

mixin _$SearchResult {
  String get personId;
  String get noteId;
  String get noteContent;

  $SearchResultCopyWith<SearchResult> get copyWith;
}

abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
          SearchResult value, $Res Function(SearchResult) then) =
      _$SearchResultCopyWithImpl<$Res>;
  $Res call({String personId, String noteId, String noteContent});
}

class _$SearchResultCopyWithImpl<$Res> implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  final SearchResult _value;
  // ignore: unused_field
  final $Res Function(SearchResult) _then;

  @override
  $Res call({
    Object personId = freezed,
    Object noteId = freezed,
    Object noteContent = freezed,
  }) {
    return _then(_value.copyWith(
      personId: personId == freezed ? _value.personId : personId as String,
      noteId: noteId == freezed ? _value.noteId : noteId as String,
      noteContent:
          noteContent == freezed ? _value.noteContent : noteContent as String,
    ));
  }
}

abstract class _$SearchResultCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(
          _SearchResult value, $Res Function(_SearchResult) then) =
      __$SearchResultCopyWithImpl<$Res>;
  @override
  $Res call({String personId, String noteId, String noteContent});
}

class __$SearchResultCopyWithImpl<$Res> extends _$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(
      _SearchResult _value, $Res Function(_SearchResult) _then)
      : super(_value, (v) => _then(v as _SearchResult));

  @override
  _SearchResult get _value => super._value as _SearchResult;

  @override
  $Res call({
    Object personId = freezed,
    Object noteId = freezed,
    Object noteContent = freezed,
  }) {
    return _then(_SearchResult(
      personId: personId == freezed ? _value.personId : personId as String,
      noteId: noteId == freezed ? _value.noteId : noteId as String,
      noteContent:
          noteContent == freezed ? _value.noteContent : noteContent as String,
    ));
  }
}

class _$_SearchResult implements _SearchResult {
  _$_SearchResult({this.personId, this.noteId, this.noteContent});

  @override
  final String personId;
  @override
  final String noteId;
  @override
  final String noteContent;

  @override
  String toString() {
    return 'SearchResult(personId: $personId, noteId: $noteId, noteContent: $noteContent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SearchResult &&
            (identical(other.personId, personId) ||
                const DeepCollectionEquality()
                    .equals(other.personId, personId)) &&
            (identical(other.noteId, noteId) ||
                const DeepCollectionEquality().equals(other.noteId, noteId)) &&
            (identical(other.noteContent, noteContent) ||
                const DeepCollectionEquality()
                    .equals(other.noteContent, noteContent)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(personId) ^
      const DeepCollectionEquality().hash(noteId) ^
      const DeepCollectionEquality().hash(noteContent);

  @override
  _$SearchResultCopyWith<_SearchResult> get copyWith =>
      __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);
}

abstract class _SearchResult implements SearchResult {
  factory _SearchResult({String personId, String noteId, String noteContent}) =
      _$_SearchResult;

  @override
  String get personId;
  @override
  String get noteId;
  @override
  String get noteContent;
  @override
  _$SearchResultCopyWith<_SearchResult> get copyWith;
}
