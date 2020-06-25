import 'dart:collection';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hitomemo/tag.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';
import 'person.dart';

part 'search_engine.freezed.dart';

@freezed
abstract class SearchResult with _$SearchResult {
  factory SearchResult({String personId, String noteId, String noteContent}) =
      _SearchResult;
}

const String noteTableName = 'notes';
const String noteFullTextSearchTableName = 'notes_fts';
const String noteToTagTableName = 'note_tags';
const String noteToPersonTableName = 'person_tags';
const String personTableName = 'persons';

class SearchEngine {
  SearchEngine(this.database, this.userId, this.mecab);

  Database database;

  String userId;

  // Null if this is in unit test
  final Mecab mecab;

  static const String databaseFileSuffix = '_text_search.db';

  static Future<void> onDatabaseInstalled(
      Database db, int oldVersion, int newVersion) async {
    // Because this database is cache of what's stored in Firestore, it's
    // ok to remove tables.

    // When creating the db, create the table https://qiita.com/shikato/items/512db7bf051eddb84600
    // SQLite does not have date-specific type: https://www.sqlite.org/datatype3.html#datetime
    await db.execute('''
    DROP TABLE IF EXISTS $noteTableName 
    ''');
    await db.execute('''
      CREATE TABLE $noteTableName 
          (noteId VARCHAR(256) NOT NULL PRIMARY KEY,
           personId VARCHAR(256) NOT NULL,
           document VARCHAR(256) NOT NULL,
           date VARCHAR(32) NOT NULL,
           updated INTEGER NOT NULL,
           tagIds  VARCHAR(256) NOT NULL,
           tagPersonIds VARCHAR(256) NOT NULL,
           pictureUrls TEXT NOT NULL,
           content TEXT )''');
    // full text search table automatically comes with rowid field
    await db.execute('''
    DROP TABLE IF EXISTS $noteFullTextSearchTableName 
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE $noteFullTextSearchTableName 
          USING fts4(words TEXT )
          ''');

    await db.execute('''
    DROP TABLE IF EXISTS $personTableName 
    ''');
    await db.execute('''
      CREATE TABLE $personTableName 
          (personId VARCHAR(256) NOT NULL PRIMARY KEY,
           updated INTEGER NOT NULL
           )''');

    await db.execute('''
    DROP TABLE IF EXISTS $noteToTagTableName
    ''');
    await db.execute('''
      CREATE TABLE $noteToTagTableName
          (noteId VARCHAR(256) NOT NULL,
           tagId VARCHAR(256) NOT NULL,
           UNIQUE(noteId,tagId) ON CONFLICT REPLACE
           )''');

    await db.execute('''
    DROP TABLE IF EXISTS $noteToPersonTableName
    ''');
    await db.execute('''
      CREATE TABLE $noteToPersonTableName
          (noteId VARCHAR(256) NOT NULL,
           personId VARCHAR(256) NOT NULL,
           UNIQUE(noteId,personId) ON CONFLICT REPLACE
           )''');
  }

  static Future<Database> _openDatabase(String fileName) {
    // History of table schema
    // version
    // 1 : text search
    // 2 : note_tag and person_tag. It had bad primary key constraints
    // 3 : fixed the the table above with primary key
    // 5 : added photoUrls column to note table

    return openDatabase(fileName, version: 5, onUpgrade: onDatabaseInstalled);
  }

  static Future<SearchEngine> create(String userId,
      {bool enableMecab = true}) async {
    final db = await _openDatabase(userId + databaseFileSuffix);
    final mecab = enableMecab ? await initMecabPlatformState() : null;
    return SearchEngine(db, userId, mecab);
  }

  static Future<Mecab> initMecabPlatformState() async {
    final mecab = Mecab();
    try {
      final platformVersion = await MecabDart.platformVersion;
      print('Mecab on $platformVersion');

      // Initialize mecab tagger here
      //   + 1st parameter : dictionary asset folder
      //   + 2nd parameter : additional mecab options
      // This ipadic is in assets directory and specified in pubspec.yaml
      await mecab.init('assets/ipadic', true);
      return mecab;
    } on Exception catch (err) {
      print('Failed to get platform version. $err');
      rethrow;
    }
  }

  /// Opens a new database for different user ID
  Future<void> reopen(String userId) async {
    database = await _openDatabase(userId + databaseFileSuffix);
    this.userId = userId;
  }

  String _splitWordsByMecab(String noteContent) {
    if (mecab == null) {
      return noteContent;
    }

    var ret = '';

    final tokens = mecab.parse(noteContent);
    for (final item in tokens) {
      final token = item as TokenNode;
      final surface = token.surface;
      if (token.features.length < 3) {
        continue;
      }
      // https://taku910.github.io/mecab/
      final hinshi = token.features[0] as String;
      if (hinshi == '名詞') {
        ret += ' $surface';
      }
    }
    return ret;
  }

  Future<void> indexNote(Person person, Note note) async {
    final words = _splitWordsByMecab(note.content);

    await database.transaction((txn) async {
      await txn.rawInsert('''
          INSERT OR REPLACE INTO $personTableName
            ( personId, updated )
          VALUES(
            ?,
            ?
          )
          ''', <dynamic>[person.id, person.updated.millisecondsSinceEpoch]);

      // Many-to-many relationship
      await txn.rawDelete(
          '''DELETE FROM $noteToTagTableName where noteId = ?''',
          <String>[note.id]);
      await txn.rawDelete(
          '''DELETE FROM $noteToPersonTableName where noteId = ?''',
          <String>[note.id]);

      if (!note.deleted) {
        for (final tagId in note.tagIds) {
          await txn.rawInsert('''
            INSERT OR REPLACE INTO $noteToTagTableName
              ( noteId, tagId )
            VALUES(
              ?,
              ?
            )''', <String>[note.id, tagId]);
        }
        for (final personId in note.tagPersonIds) {
          await txn.rawInsert('''
            INSERT OR REPLACE INTO $noteToPersonTableName
              ( noteId, personId )
            VALUES(
              ?,
              ?
            )''', <String>[note.id, personId]);
        }

        await txn.rawInsert('''
          INSERT OR REPLACE INTO $noteTableName
            ( noteId, personId, content, updated, document, date, tagIds,
              tagPersonIds, pictureUrls )
          VALUES(
            ?, ?, ?, ?, ?, ?, ?, ?, ?
          )
          ''', <dynamic>[
          note.id,
          person.id,
          note.content,
          note.updated.millisecondsSinceEpoch,
          note.document.path,
          Note.toDate(note.date),
          note.tagIds.join(','),
          note.tagPersonIds.join(','),
          note.pictureUrls.join(',')
        ]);

        // rowid is a FTS table's special field that can be used in upsert
        // https://stackoverflow.com/a/37594803/975074
        await txn
            .rawInsert('''INSERT OR REPLACE INTO $noteFullTextSearchTableName
           ( rowid, words ) VALUES(?, ?) ''', <String>[note.id, words]);
      } else {
        // deleted
        await txn.rawDelete('''DELETE FROM $noteTableName where noteId = ?''',
            <String>[note.id]);
        await txn.rawDelete(
            '''DELETE FROM $noteFullTextSearchTableName where rowid = ?''',
            <String>[note.id]);
      }
    });
    return;
  }

  /// Updates the last update time of the person on current timestamp.
  Future<void> updatePersonTimestamp(Person person) async {
    await database.transaction((txn) async {
      await txn.rawInsert('''
          INSERT OR REPLACE INTO $personTableName
            ( personId, updated )
          VALUES(
            ?,
            ?
          )
          ''', <dynamic>[
        person.id,
        (person.updated ?? Timestamp.now()).millisecondsSinceEpoch
      ]);
    });
    return;
  }

  // Person ID and NoteID
  Future<UnmodifiableListView<SearchResult>> searchByNote(
      String targetText) async {
    final queryText = targetText.length >= 3
        ? '$targetText*' // prefix match
        : targetText;

    final list = await database.rawQuery('''
    SELECT n.noteId noteId, n.personId personId, n.content content
    FROM $noteTableName n
    INNER JOIN $noteFullTextSearchTableName f ON n.noteId = f.rowid
    WHERE f.words MATCH ?
    ''', <String>[queryText]);

    final results = list
        .map((m) => SearchResult(
              noteId: m['noteId'] as String,
              personId: m['personId'] as String,
              noteContent: m['content'] as String,
            ))
        .toList();

    return UnmodifiableListView(results);
  }

  /// Map of person ID to their last indexed time.
  Future<UnmodifiableMapView<String, DateTime>>
      lastUpdateTimesByPerson() async {
    final list = await database.rawQuery('''
    SELECT p.personId, p.updated FROM $personTableName p
    ''');

    final ret = <String, DateTime>{};
    for (final row in list) {
      final personId = row['personId'] as String;
      final lastUpdatedEpochMillis = row['updated'] as int;
      final lastUpdate =
          DateTime.fromMillisecondsSinceEpoch(lastUpdatedEpochMillis);
      ret[personId] = lastUpdate;
    }
    return UnmodifiableMapView(ret);
  }

  final _noteReplicaFields = '''
      n.noteId noteId,
      n.personId personId,
      n.content content,
      n.date date,
      n.tagIds tagIds,
      n.tagPersonIds tagPersonIds,
      n.pictureUrls pictureUrls,
      n.document document,
      n.updated updated''';

  NoteReplica convertToReplica(Map<String, dynamic> m) {
    final tagIdsStr = m['tagIds'] as String;
    final tagIds =
        tagIdsStr.isEmpty ? <String>{} : tagIdsStr.split(',').toSet();

    final tagPersonIdsStr = m['tagPersonIds'] as String;
    final tagPersonIds = tagPersonIdsStr.isEmpty
        ? <String>{}
        : tagPersonIdsStr.split(',').toSet();
    final pictureUrlsStr = m['pictureUrls'] as String;
    final pictureUrls = pictureUrlsStr.isEmpty
        ? <String>[]
        : pictureUrlsStr.split(',').toList();

    final lastUpdatedEpochMillis = m['updated'] as int;
    return NoteReplica(
        id: m['noteId'] as String,
        personId: m['personId'] as String,
        content: m['content'] as String,
        date: Note.fromDate(m['date'] as String),
        tagIds: tagIds,
        tagPersonIds: tagPersonIds,
        pictureUrls: pictureUrls,
        documentPath: m['document'] as String,
        updated: Timestamp.fromMillisecondsSinceEpoch(lastUpdatedEpochMillis));
  }

  Future<UnmodifiableListView<NoteReplica>> searchNoteByTag(
      String tagId) async {
    final list = await database.rawQuery('''
    SELECT
      $_noteReplicaFields
    FROM $noteTableName n
    INNER JOIN $noteToTagTableName t ON n.noteId = t.noteId
    WHERE t.tagId = ?
    ORDER BY date DESC, updated DESC
    ''', <String>[tagId]);

    final results = list.map(convertToReplica).toList();

    return UnmodifiableListView(results);
  }

  Future<UnmodifiableListView<NoteReplica>> searchNoteByPersonTag(
      String personId) async {
    final list = await database.rawQuery('''
    SELECT
      $_noteReplicaFields
    FROM $noteTableName n
    INNER JOIN $noteToPersonTableName p ON n.noteId = p.noteId
    WHERE p.personId = ?
    ORDER BY date DESC, updated DESC
    ''', <String>[personId]);

    final results = list.map(convertToReplica).toList();
    return UnmodifiableListView(results);
  }

  Future<UnmodifiableListView<NoteReplica>> searchNoteByFamily(
      String personId, Family family) async {
    if (family == null) {
      return UnmodifiableListView([]);
    }

    final personIds = {...family.memberIds}
      ..add(family.id)
      ..remove(personId);
    return searchNoteByPersons(personIds);
  }

  Future<UnmodifiableListView<NoteReplica>> searchNoteByPersons(
      Set<String> personIds) async {
    final questionParams =
        List.generate(personIds.length, (_) => '?').join(',');

    final list = await database.rawQuery('''
    SELECT
      $_noteReplicaFields
    FROM $noteTableName n
    WHERE n.personId in ($questionParams)
    ORDER BY n.date DESC, n.updated DESC
    ''', personIds.toList(growable: false));

    final results = list.map(convertToReplica).toList();

    return UnmodifiableListView(results);
  }

  String buildWhereClause(DateTime startCursor, String text) {
    var ret = startCursor == null
        ? 'n.date >= 0 '
        : 'n.date <= "${Note.toDate(startCursor)}" ';
    if (text.isNotEmpty) {
      // Should I use wakachigaki table?
      ret += ' AND n.content like ?';
    }

    return ret;
  }

  Future<UnmodifiableListView<NoteReplica>> searchNotes(
      {DateTime startCursor,
      int count,
      String text,
      Set<String> orPersonIds}) async {
    final noteCriteria = buildWhereClause(startCursor, text);

    // How to make IN queries using set
    // https://github.com/tekartik/sqflite/issues/15
    final whereClause = 'WHERE ( $noteCriteria ) OR n.personId IN '
        '( ${orPersonIds.map((_) => '?').join(', ')} )';
    final q = '''
    SELECT
      $_noteReplicaFields
    FROM $noteTableName n
    $whereClause
    ORDER BY n.date DESC, n.updated DESC
    LIMIT $count
    ''';
    final list =
        await database.rawQuery(q, <String>['%$text%', ...orPersonIds]);

    final results = list.map(convertToReplica).toList();
    return UnmodifiableListView(results);
  }
}
