// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'person_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$PersonListSearchCriteriaTearOff {
  const _$PersonListSearchCriteriaTearOff();

  _PersonListSearchCriteria call(
      {Set<String> personIdsHigh = const <String>{},
      Set<String> personIdsLow = const <String>{}}) {
    return _PersonListSearchCriteria(
      personIdsHigh: personIdsHigh,
      personIdsLow: personIdsLow,
    );
  }
}

// ignore: unused_element
const $PersonListSearchCriteria = _$PersonListSearchCriteriaTearOff();

mixin _$PersonListSearchCriteria {
  Set<String> get personIdsHigh;
  Set<String> get personIdsLow;

  $PersonListSearchCriteriaCopyWith<PersonListSearchCriteria> get copyWith;
}

abstract class $PersonListSearchCriteriaCopyWith<$Res> {
  factory $PersonListSearchCriteriaCopyWith(PersonListSearchCriteria value,
          $Res Function(PersonListSearchCriteria) then) =
      _$PersonListSearchCriteriaCopyWithImpl<$Res>;
  $Res call({Set<String> personIdsHigh, Set<String> personIdsLow});
}

class _$PersonListSearchCriteriaCopyWithImpl<$Res>
    implements $PersonListSearchCriteriaCopyWith<$Res> {
  _$PersonListSearchCriteriaCopyWithImpl(this._value, this._then);

  final PersonListSearchCriteria _value;
  // ignore: unused_field
  final $Res Function(PersonListSearchCriteria) _then;

  @override
  $Res call({
    Object personIdsHigh = freezed,
    Object personIdsLow = freezed,
  }) {
    return _then(_value.copyWith(
      personIdsHigh: personIdsHigh == freezed
          ? _value.personIdsHigh
          : personIdsHigh as Set<String>,
      personIdsLow: personIdsLow == freezed
          ? _value.personIdsLow
          : personIdsLow as Set<String>,
    ));
  }
}

abstract class _$PersonListSearchCriteriaCopyWith<$Res>
    implements $PersonListSearchCriteriaCopyWith<$Res> {
  factory _$PersonListSearchCriteriaCopyWith(_PersonListSearchCriteria value,
          $Res Function(_PersonListSearchCriteria) then) =
      __$PersonListSearchCriteriaCopyWithImpl<$Res>;
  @override
  $Res call({Set<String> personIdsHigh, Set<String> personIdsLow});
}

class __$PersonListSearchCriteriaCopyWithImpl<$Res>
    extends _$PersonListSearchCriteriaCopyWithImpl<$Res>
    implements _$PersonListSearchCriteriaCopyWith<$Res> {
  __$PersonListSearchCriteriaCopyWithImpl(_PersonListSearchCriteria _value,
      $Res Function(_PersonListSearchCriteria) _then)
      : super(_value, (v) => _then(v as _PersonListSearchCriteria));

  @override
  _PersonListSearchCriteria get _value =>
      super._value as _PersonListSearchCriteria;

  @override
  $Res call({
    Object personIdsHigh = freezed,
    Object personIdsLow = freezed,
  }) {
    return _then(_PersonListSearchCriteria(
      personIdsHigh: personIdsHigh == freezed
          ? _value.personIdsHigh
          : personIdsHigh as Set<String>,
      personIdsLow: personIdsLow == freezed
          ? _value.personIdsLow
          : personIdsLow as Set<String>,
    ));
  }
}

class _$_PersonListSearchCriteria
    with DiagnosticableTreeMixin
    implements _PersonListSearchCriteria {
  _$_PersonListSearchCriteria(
      {this.personIdsHigh = const <String>{},
      this.personIdsLow = const <String>{}})
      : assert(personIdsHigh != null),
        assert(personIdsLow != null);

  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> personIdsHigh;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> personIdsLow;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PersonListSearchCriteria(personIdsHigh: $personIdsHigh, personIdsLow: $personIdsLow)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PersonListSearchCriteria'))
      ..add(DiagnosticsProperty('personIdsHigh', personIdsHigh))
      ..add(DiagnosticsProperty('personIdsLow', personIdsLow));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _PersonListSearchCriteria &&
            (identical(other.personIdsHigh, personIdsHigh) ||
                const DeepCollectionEquality()
                    .equals(other.personIdsHigh, personIdsHigh)) &&
            (identical(other.personIdsLow, personIdsLow) ||
                const DeepCollectionEquality()
                    .equals(other.personIdsLow, personIdsLow)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(personIdsHigh) ^
      const DeepCollectionEquality().hash(personIdsLow);

  @override
  _$PersonListSearchCriteriaCopyWith<_PersonListSearchCriteria> get copyWith =>
      __$PersonListSearchCriteriaCopyWithImpl<_PersonListSearchCriteria>(
          this, _$identity);
}

abstract class _PersonListSearchCriteria implements PersonListSearchCriteria {
  factory _PersonListSearchCriteria(
      {Set<String> personIdsHigh,
      Set<String> personIdsLow}) = _$_PersonListSearchCriteria;

  @override
  Set<String> get personIdsHigh;
  @override
  Set<String> get personIdsLow;
  @override
  _$PersonListSearchCriteriaCopyWith<_PersonListSearchCriteria> get copyWith;
}
