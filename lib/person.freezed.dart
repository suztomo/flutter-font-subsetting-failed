// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$PersonTearOff {
  const _$PersonTearOff();

  _Person call(
      {String id,
      String name,
      String phoneticName,
      Timestamp updated,
      List<DocumentReference> notes = const <DocumentReference>[],
      String pictureGcsPath,
      String familyId}) {
    return _Person(
      id: id,
      name: name,
      phoneticName: phoneticName,
      updated: updated,
      notes: notes,
      pictureGcsPath: pictureGcsPath,
      familyId: familyId,
    );
  }
}

// ignore: unused_element
const $Person = _$PersonTearOff();

mixin _$Person {
  String get id;
  String get name;
  String get phoneticName;
  Timestamp get updated;
  List<DocumentReference> get notes;
  String get pictureGcsPath;
  String get familyId;

  $PersonCopyWith<Person> get copyWith;
}

abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String name,
      String phoneticName,
      Timestamp updated,
      List<DocumentReference> notes,
      String pictureGcsPath,
      String familyId});
}

class _$PersonCopyWithImpl<$Res> implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  final Person _value;
  // ignore: unused_field
  final $Res Function(Person) _then;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object phoneticName = freezed,
    Object updated = freezed,
    Object notes = freezed,
    Object pictureGcsPath = freezed,
    Object familyId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      phoneticName: phoneticName == freezed
          ? _value.phoneticName
          : phoneticName as String,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
      notes: notes == freezed ? _value.notes : notes as List<DocumentReference>,
      pictureGcsPath: pictureGcsPath == freezed
          ? _value.pictureGcsPath
          : pictureGcsPath as String,
      familyId: familyId == freezed ? _value.familyId : familyId as String,
    ));
  }
}

abstract class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) then) =
      __$PersonCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String name,
      String phoneticName,
      Timestamp updated,
      List<DocumentReference> notes,
      String pictureGcsPath,
      String familyId});
}

class __$PersonCopyWithImpl<$Res> extends _$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(_Person _value, $Res Function(_Person) _then)
      : super(_value, (v) => _then(v as _Person));

  @override
  _Person get _value => super._value as _Person;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object phoneticName = freezed,
    Object updated = freezed,
    Object notes = freezed,
    Object pictureGcsPath = freezed,
    Object familyId = freezed,
  }) {
    return _then(_Person(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      phoneticName: phoneticName == freezed
          ? _value.phoneticName
          : phoneticName as String,
      updated: updated == freezed ? _value.updated : updated as Timestamp,
      notes: notes == freezed ? _value.notes : notes as List<DocumentReference>,
      pictureGcsPath: pictureGcsPath == freezed
          ? _value.pictureGcsPath
          : pictureGcsPath as String,
      familyId: familyId == freezed ? _value.familyId : familyId as String,
    ));
  }
}

class _$_Person with DiagnosticableTreeMixin implements _Person {
  _$_Person(
      {this.id,
      this.name,
      this.phoneticName,
      this.updated,
      this.notes = const <DocumentReference>[],
      this.pictureGcsPath,
      this.familyId})
      : assert(notes != null);

  @override
  final String id;
  @override
  final String name;
  @override
  final String phoneticName;
  @override
  final Timestamp updated;
  @JsonKey(defaultValue: const <DocumentReference>[])
  @override
  final List<DocumentReference> notes;
  @override
  final String pictureGcsPath;
  @override
  final String familyId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Person(id: $id, name: $name, phoneticName: $phoneticName, updated: $updated, notes: $notes, pictureGcsPath: $pictureGcsPath, familyId: $familyId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Person'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('phoneticName', phoneticName))
      ..add(DiagnosticsProperty('updated', updated))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('pictureGcsPath', pictureGcsPath))
      ..add(DiagnosticsProperty('familyId', familyId));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Person &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.phoneticName, phoneticName) ||
                const DeepCollectionEquality()
                    .equals(other.phoneticName, phoneticName)) &&
            (identical(other.updated, updated) ||
                const DeepCollectionEquality()
                    .equals(other.updated, updated)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.pictureGcsPath, pictureGcsPath) ||
                const DeepCollectionEquality()
                    .equals(other.pictureGcsPath, pictureGcsPath)) &&
            (identical(other.familyId, familyId) ||
                const DeepCollectionEquality()
                    .equals(other.familyId, familyId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(phoneticName) ^
      const DeepCollectionEquality().hash(updated) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(pictureGcsPath) ^
      const DeepCollectionEquality().hash(familyId);

  @override
  _$PersonCopyWith<_Person> get copyWith =>
      __$PersonCopyWithImpl<_Person>(this, _$identity);
}

abstract class _Person implements Person {
  factory _Person(
      {String id,
      String name,
      String phoneticName,
      Timestamp updated,
      List<DocumentReference> notes,
      String pictureGcsPath,
      String familyId}) = _$_Person;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phoneticName;
  @override
  Timestamp get updated;
  @override
  List<DocumentReference> get notes;
  @override
  String get pictureGcsPath;
  @override
  String get familyId;
  @override
  _$PersonCopyWith<_Person> get copyWith;
}

class _$FamilyTearOff {
  const _$FamilyTearOff();

  _Family call({String id, Set<String> memberIds = const <String>{}}) {
    return _Family(
      id: id,
      memberIds: memberIds,
    );
  }
}

// ignore: unused_element
const $Family = _$FamilyTearOff();

mixin _$Family {
  String get id;
  Set<String> get memberIds;

  $FamilyCopyWith<Family> get copyWith;
}

abstract class $FamilyCopyWith<$Res> {
  factory $FamilyCopyWith(Family value, $Res Function(Family) then) =
      _$FamilyCopyWithImpl<$Res>;
  $Res call({String id, Set<String> memberIds});
}

class _$FamilyCopyWithImpl<$Res> implements $FamilyCopyWith<$Res> {
  _$FamilyCopyWithImpl(this._value, this._then);

  final Family _value;
  // ignore: unused_field
  final $Res Function(Family) _then;

  @override
  $Res call({
    Object id = freezed,
    Object memberIds = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      memberIds:
          memberIds == freezed ? _value.memberIds : memberIds as Set<String>,
    ));
  }
}

abstract class _$FamilyCopyWith<$Res> implements $FamilyCopyWith<$Res> {
  factory _$FamilyCopyWith(_Family value, $Res Function(_Family) then) =
      __$FamilyCopyWithImpl<$Res>;
  @override
  $Res call({String id, Set<String> memberIds});
}

class __$FamilyCopyWithImpl<$Res> extends _$FamilyCopyWithImpl<$Res>
    implements _$FamilyCopyWith<$Res> {
  __$FamilyCopyWithImpl(_Family _value, $Res Function(_Family) _then)
      : super(_value, (v) => _then(v as _Family));

  @override
  _Family get _value => super._value as _Family;

  @override
  $Res call({
    Object id = freezed,
    Object memberIds = freezed,
  }) {
    return _then(_Family(
      id: id == freezed ? _value.id : id as String,
      memberIds:
          memberIds == freezed ? _value.memberIds : memberIds as Set<String>,
    ));
  }
}

class _$_Family with DiagnosticableTreeMixin implements _Family {
  _$_Family({this.id, this.memberIds = const <String>{}})
      : assert(memberIds != null);

  @override
  final String id;
  @JsonKey(defaultValue: const <String>{})
  @override
  final Set<String> memberIds;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Family(id: $id, memberIds: $memberIds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Family'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('memberIds', memberIds));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Family &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.memberIds, memberIds) ||
                const DeepCollectionEquality()
                    .equals(other.memberIds, memberIds)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(memberIds);

  @override
  _$FamilyCopyWith<_Family> get copyWith =>
      __$FamilyCopyWithImpl<_Family>(this, _$identity);
}

abstract class _Family implements Family {
  factory _Family({String id, Set<String> memberIds}) = _$_Family;

  @override
  String get id;
  @override
  Set<String> get memberIds;
  @override
  _$FamilyCopyWith<_Family> get copyWith;
}

class _$EditPersonResultTearOff {
  const _$EditPersonResultTearOff();

  Deleted deleted(Person person) {
    return Deleted(
      person,
    );
  }

  Updated updated(Person person) {
    return Updated(
      person,
    );
  }
}

// ignore: unused_element
const $EditPersonResult = _$EditPersonResultTearOff();

mixin _$EditPersonResult {
  Person get person;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(Person person),
    @required Result updated(Person person),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(Person person),
    Result updated(Person person),
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

  $EditPersonResultCopyWith<EditPersonResult> get copyWith;
}

abstract class $EditPersonResultCopyWith<$Res> {
  factory $EditPersonResultCopyWith(
          EditPersonResult value, $Res Function(EditPersonResult) then) =
      _$EditPersonResultCopyWithImpl<$Res>;
  $Res call({Person person});

  $PersonCopyWith<$Res> get person;
}

class _$EditPersonResultCopyWithImpl<$Res>
    implements $EditPersonResultCopyWith<$Res> {
  _$EditPersonResultCopyWithImpl(this._value, this._then);

  final EditPersonResult _value;
  // ignore: unused_field
  final $Res Function(EditPersonResult) _then;

  @override
  $Res call({
    Object person = freezed,
  }) {
    return _then(_value.copyWith(
      person: person == freezed ? _value.person : person as Person,
    ));
  }

  @override
  $PersonCopyWith<$Res> get person {
    if (_value.person == null) {
      return null;
    }
    return $PersonCopyWith<$Res>(_value.person, (value) {
      return _then(_value.copyWith(person: value));
    });
  }
}

abstract class $DeletedCopyWith<$Res>
    implements $EditPersonResultCopyWith<$Res> {
  factory $DeletedCopyWith(Deleted value, $Res Function(Deleted) then) =
      _$DeletedCopyWithImpl<$Res>;
  @override
  $Res call({Person person});

  @override
  $PersonCopyWith<$Res> get person;
}

class _$DeletedCopyWithImpl<$Res> extends _$EditPersonResultCopyWithImpl<$Res>
    implements $DeletedCopyWith<$Res> {
  _$DeletedCopyWithImpl(Deleted _value, $Res Function(Deleted) _then)
      : super(_value, (v) => _then(v as Deleted));

  @override
  Deleted get _value => super._value as Deleted;

  @override
  $Res call({
    Object person = freezed,
  }) {
    return _then(Deleted(
      person == freezed ? _value.person : person as Person,
    ));
  }
}

class _$Deleted with DiagnosticableTreeMixin implements Deleted {
  const _$Deleted(this.person) : assert(person != null);

  @override
  final Person person;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditPersonResult.deleted(person: $person)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EditPersonResult.deleted'))
      ..add(DiagnosticsProperty('person', person));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Deleted &&
            (identical(other.person, person) ||
                const DeepCollectionEquality().equals(other.person, person)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(person);

  @override
  $DeletedCopyWith<Deleted> get copyWith =>
      _$DeletedCopyWithImpl<Deleted>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(Person person),
    @required Result updated(Person person),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return deleted(person);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(Person person),
    Result updated(Person person),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (deleted != null) {
      return deleted(person);
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

abstract class Deleted implements EditPersonResult {
  const factory Deleted(Person person) = _$Deleted;

  @override
  Person get person;
  @override
  $DeletedCopyWith<Deleted> get copyWith;
}

abstract class $UpdatedCopyWith<$Res>
    implements $EditPersonResultCopyWith<$Res> {
  factory $UpdatedCopyWith(Updated value, $Res Function(Updated) then) =
      _$UpdatedCopyWithImpl<$Res>;
  @override
  $Res call({Person person});

  @override
  $PersonCopyWith<$Res> get person;
}

class _$UpdatedCopyWithImpl<$Res> extends _$EditPersonResultCopyWithImpl<$Res>
    implements $UpdatedCopyWith<$Res> {
  _$UpdatedCopyWithImpl(Updated _value, $Res Function(Updated) _then)
      : super(_value, (v) => _then(v as Updated));

  @override
  Updated get _value => super._value as Updated;

  @override
  $Res call({
    Object person = freezed,
  }) {
    return _then(Updated(
      person == freezed ? _value.person : person as Person,
    ));
  }
}

class _$Updated with DiagnosticableTreeMixin implements Updated {
  const _$Updated(this.person) : assert(person != null);

  @override
  final Person person;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditPersonResult.updated(person: $person)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EditPersonResult.updated'))
      ..add(DiagnosticsProperty('person', person));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Updated &&
            (identical(other.person, person) ||
                const DeepCollectionEquality().equals(other.person, person)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(person);

  @override
  $UpdatedCopyWith<Updated> get copyWith =>
      _$UpdatedCopyWithImpl<Updated>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result deleted(Person person),
    @required Result updated(Person person),
  }) {
    assert(deleted != null);
    assert(updated != null);
    return updated(person);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result deleted(Person person),
    Result updated(Person person),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updated != null) {
      return updated(person);
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

abstract class Updated implements EditPersonResult {
  const factory Updated(Person person) = _$Updated;

  @override
  Person get person;
  @override
  $UpdatedCopyWith<Updated> get copyWith;
}
