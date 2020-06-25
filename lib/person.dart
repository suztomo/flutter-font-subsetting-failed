import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'person.freezed.dart';

@freezed
abstract class Person with _$Person {
  factory Person({
    String id,
    String name,
    String phoneticName,
    Timestamp updated, // Timestamp is better than DateTime for timezone
    @Default(<DocumentReference>[]) List<DocumentReference> notes,
    String pictureGcsPath,
    String familyId, // person ID of the family head, if this person belongs
  }) = _Person;

/*
Freezed does not support concrete methods yet
https://github.com/rrousselGit/freezed/issues/83
  Person addNote(Note note) {
    return copyWith(notes: [note, ...notes]);
  }

  Person removeNote(Note note) {
    return copyWith(notes: notes.where((Note n) => n.id != note.id).toList());
  }
  */
}

@freezed
abstract class Family with _$Family {
  factory Family({
    String id, // person ID of the family head, if this person belongs
    /// The member of this family. This should not include the family head
    @Default(<String>{}) Set<String> memberIds,
  }) = _Family;
}

@freezed
abstract class EditPersonResult with _$EditPersonResult {
  const factory EditPersonResult.deleted(Person person) = Deleted;
  const factory EditPersonResult.updated(Person person) = Updated;
}
