// ignore_for_file: prefer_constructors_over_static_methods
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'note.freezed.dart';

/// PersonsModel is responsible to manage Firestore queries.
///
/// The deletion is managed as deleted flag. This helps to propagate the
/// deletion to other devices when they come online. I thought about abstracting
/// this with NoteEntry.deleted and NoteEntry.active, however, doing so makes
/// it difficult for other devices to synchronize their internal SQLite.
@freezed
abstract class Note with _$Note {
  // Note ID is unique within a user (not within a person).
  factory Note(
      {String id,
      String content,
      DateTime date,
      // Example: /users/<userId>/persons/<personId>/notes/0
      DocumentReference document, // The document this note belongs to
      @Default(<String>{}) Set<String> tagIds,
      @Default(<String>{}) Set<String> tagPersonIds,
      Timestamp updated,
      @Default(false) bool deleted,
      @Default(<String>[]) List<String> pictureUrls}) = _Note;

  // From Map<String, dynamic>
  static Note fromMapEntry(String id, dynamic value) {
    final doc = value as Map<dynamic, dynamic>;
    final content = doc['content'] as String;
    final d = doc['date'] as String;
    // final tagIds = (doc['tagIds'] as List<String>) ?? <String>[];
    final date = fromDate(d);
    final tagIds = (doc['tagIds'] as List<dynamic>) ?? <dynamic>[];
    final tagPersonIds = (doc['tagPersonIds'] as List<dynamic>) ?? <dynamic>[];
    final pictureUrls = (doc['pictureUrls'] as List<dynamic>) ?? <dynamic>[];
    final updated = (doc['updated'] as Timestamp) ?? Timestamp.now();
    final deleted = (doc['deleted'] as bool) ?? false;
    return Note(
      id: id,
      content: content,
      date: date,
      tagIds: tagIds.map((dynamic d) => d as String).toSet(),
      tagPersonIds: tagPersonIds.map((dynamic d) => d as String).toSet(),
      pictureUrls: pictureUrls.map((dynamic d) => d as String).toList(),
      updated: updated,
      deleted: deleted,
    );
  }

  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  static DateTime fromDate(String dateString) {
    // 2020-02-01
    if (dateString == null) {
      return DateTime.now();
    }
    return DateTime.parse(dateString);
  }

  static String toDate(DateTime dateTime) {
    return _formatter.format(dateTime);
  }

  static final DateTime dateRangeStart = DateTime(1900, 1);
  static final DateTime dateRangeEnd =
      DateTime.now().add(const Duration(days: 365));
}
