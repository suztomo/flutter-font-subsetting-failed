// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'hitomemo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SearchCriteriaTearOff {
  const _$SearchCriteriaTearOff();

  _SearchCriteria call({String text = ''}) {
    return _SearchCriteria(
      text: text,
    );
  }
}

// ignore: unused_element
const $SearchCriteria = _$SearchCriteriaTearOff();

mixin _$SearchCriteria {
  String get text;

  $SearchCriteriaCopyWith<SearchCriteria> get copyWith;
}

abstract class $SearchCriteriaCopyWith<$Res> {
  factory $SearchCriteriaCopyWith(
          SearchCriteria value, $Res Function(SearchCriteria) then) =
      _$SearchCriteriaCopyWithImpl<$Res>;
  $Res call({String text});
}

class _$SearchCriteriaCopyWithImpl<$Res>
    implements $SearchCriteriaCopyWith<$Res> {
  _$SearchCriteriaCopyWithImpl(this._value, this._then);

  final SearchCriteria _value;
  // ignore: unused_field
  final $Res Function(SearchCriteria) _then;

  @override
  $Res call({
    Object text = freezed,
  }) {
    return _then(_value.copyWith(
      text: text == freezed ? _value.text : text as String,
    ));
  }
}

abstract class _$SearchCriteriaCopyWith<$Res>
    implements $SearchCriteriaCopyWith<$Res> {
  factory _$SearchCriteriaCopyWith(
          _SearchCriteria value, $Res Function(_SearchCriteria) then) =
      __$SearchCriteriaCopyWithImpl<$Res>;
  @override
  $Res call({String text});
}

class __$SearchCriteriaCopyWithImpl<$Res>
    extends _$SearchCriteriaCopyWithImpl<$Res>
    implements _$SearchCriteriaCopyWith<$Res> {
  __$SearchCriteriaCopyWithImpl(
      _SearchCriteria _value, $Res Function(_SearchCriteria) _then)
      : super(_value, (v) => _then(v as _SearchCriteria));

  @override
  _SearchCriteria get _value => super._value as _SearchCriteria;

  @override
  $Res call({
    Object text = freezed,
  }) {
    return _then(_SearchCriteria(
      text: text == freezed ? _value.text : text as String,
    ));
  }
}

class _$_SearchCriteria
    with DiagnosticableTreeMixin
    implements _SearchCriteria {
  _$_SearchCriteria({this.text = ''}) : assert(text != null);

  @JsonKey(defaultValue: '')
  @override
  final String text;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchCriteria(text: $text)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchCriteria'))
      ..add(DiagnosticsProperty('text', text));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SearchCriteria &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(text);

  @override
  _$SearchCriteriaCopyWith<_SearchCriteria> get copyWith =>
      __$SearchCriteriaCopyWithImpl<_SearchCriteria>(this, _$identity);
}

abstract class _SearchCriteria implements SearchCriteria {
  factory _SearchCriteria({String text}) = _$_SearchCriteria;

  @override
  String get text;
  @override
  _$SearchCriteriaCopyWith<_SearchCriteria> get copyWith;
}
