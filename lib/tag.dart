// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'note.dart';

part 'tag.freezed.dart';

class TagFactory {}

/// Person tags
@freezed
abstract class PTag with _$PTag {
  factory PTag({String id, String name}) = _PTag;

  static PTag create(String name) {
    // This is not yet saved. Therefore, not having ID yet.
    return PTag(name: name);
  }

  static PTag fromMapEntry(String key, dynamic value) {
    final doc = value as Map<dynamic, dynamic>;
    final name = doc['name'] as String;
    final id = key;
    return PTag(id: id, name: name);
  }
}

@freezed
abstract class EditTagResult with _$EditTagResult {
  const factory EditTagResult.deleted(PTag tag) = Deleted;
  const factory EditTagResult.updated(PTag tag) = Updated;
}

/// Note tags
@freezed
abstract class NTag with _$NTag {
  factory NTag({String id, String name, Timestamp updated}) = _NTag;

  static NTag create(String name) {
    final currentTimestanp = DateTime.now().microsecondsSinceEpoch;
    return NTag(id: '$currentTimestanp', name: name);
  }

  static NTag fromMapEntry(String tagId, dynamic value) {
    final doc = value as Map<dynamic, dynamic>;
    final name = doc['name'] as String;
    final updated = doc['updated'] as Timestamp;
    return NTag(id: tagId, name: name, updated: updated);
  }
}

/// The data stored in NTagsModel.addNoteReplicaInTransaction
/// Information necessary to show one item of note in tagged note list.
/// This instance does not have deleted flag because deleted notes should not
/// have any replica.
@freezed
abstract class NoteReplica with _$NoteReplica {
  factory NoteReplica({
    String id, // noteId
    String personId,
    String content,
    DateTime date,
    @Default(<String>{}) Set<String> tagIds,
    @Default(<String>{}) Set<String> tagPersonIds,
    String documentPath, //  /users/<userId>/persons/<personId>/notes/0
    @Default(<String>[]) List<String> pictureUrls,
    Timestamp updated,
  }) = _NoteReplica;

  static NoteReplica fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data;
    final personId = data['personId'] as String;
    final updated = data['updated'] as Timestamp;
    final tagIds = (data['tagIds'] as List<dynamic>) ?? <dynamic>[];
    final pictureUrls = (data['pictureUrls'] as List<dynamic>) ?? <dynamic>[];
    return NoteReplica(
        id: snapshot.documentID,
        personId: personId,
        updated: updated,
        content: data['content'] as String,
        date: Note.fromDate(data['date'] as String),
        tagIds: tagIds.map((dynamic d) => d as String).toSet(),
        pictureUrls: pictureUrls.map((dynamic d) => d as String).toList(),
        documentPath: (data['document'] as DocumentReference).path);
  }
}
