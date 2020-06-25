import 'dart:collection';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:pedantic/pedantic.dart';

import 'login_user_model.dart';
import 'note.dart';
import 'note_tags_model.dart';
import 'person_model_romaji.dart';
import 'search_engine.dart';

/// Maintains person information including notes.
// https://console.firebase.google.com/u/0/project/suztomo-hitomemo/database
class PersonsModel extends ChangeNotifier {
  PersonsModel(this._firestore, this._connectivity) {
    _firestore.settings(persistenceEnabled: true);
  }
  final Firestore _firestore;
  final Connectivity _connectivity;
  FirebaseUser _firebaseUser;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  LoginUserModel _loginUserModel;
  NoteTagRepository noteTagsModel;

  CollectionReference _personsCollection;

  DocumentReference _userReference;

  DocumentReference personIndexReference;

  FirebaseUser get loginUser => _firebaseUser;

  SearchEngine _searchEngine;

  // familyId to set of persons
  final Map<String, Set<String>> _families = {};

  Future<SearchEngine> get searchEngine async {
    if (_searchEngine == null || _searchEngine.userId != _firebaseUser.uid) {
      return _searchEngine = await SearchEngine.create(_firebaseUser.uid);
    }
    return _searchEngine;
  }

  final Map<String, Person> _persons = {};

  UnmodifiableListView<Person> get persons {
    if (_firebaseUser == null) {
      return null;
    }

    final persons = [..._persons.values]..sort(_nameComparator);

    return UnmodifiableListView(persons);
  }

  Person get(String personId) {
    return _persons[personId];
  }

  Family getFamily(String familyId) {
    if (familyId == null) {
      return null;
    }
    final members = _families[familyId];
    if (members == null) {
      return null;
    }
    return Family(id: familyId, memberIds: members);
  }

  UnmodifiableListView<Person> get recentPersons {
    if (_firebaseUser == null || _persons.length <= 5) {
      return null;
    }

    // Order by two fields requires a composite index.
    // If you specify order by phoneticName, documents without the field
    // are filtered out.
    // [Firebase/Firestore][I-FST000001] Listen for query at
    // users/t1gVCkBrgMU9LjFRnrtu1FFjlir1/persons failed: The query requires an index.
    // You can create it here: https://console.firebase.google.com/v1/r/project/suztomo-hitomemo/firestore/indexes?create_composite=ClBwcm9qZWN0cy9zdXp0b21vLWhpdG9tZW1vL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9wZXJzb25zL2luZGV4ZXMvXxABGhAKDHBob25ldGljTmFtZRABGggKBG5hbWUQARoMCghfX25hbWVfXxAB
    final persons = _persons.values;
    final personsToShuffle = [...persons]
      ..sort((a, b) => -a.updated.compareTo(b.updated));

    return UnmodifiableListView(personsToShuffle.sublist(0, 3));
  }

  static const String tagIdFieldName = 'tagIds';

  Future<Source> _firestoreSource() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final firestoreSource = (connectivityResult == ConnectivityResult.none)
        ? Source.cache
        : Source.serverAndCache;
    return firestoreSource;
  }

  /// Returns the latest note data from Firestore
  Future<Note> fetchNote(Person person, Note note) async {
    final doc = await note.document.get(); // This should not ask local store
    if (doc.data == null) {
      return null;
    }
    final noteMap =
        (doc.data['notes'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final noteId = note.id;
    if (!noteMap.containsKey(noteId)) {
      return null;
    }
    final latestNote = Note.fromMapEntry(noteId, noteMap[noteId]);
    return latestNote;
  }

  Future<UnmodifiableListView<Note>> getNotes(Person person) async {
    final notes = <Note>[];

    for (final noteReference in person.notes) {
      final doc = await noteReference.get(source: await _firestoreSource());
      if (doc.data != null) {
        final noteMap =
            (doc.data['notes'] ?? <String, dynamic>{}) as Map<String, dynamic>;
        for (final noteId in noteMap.keys) {
          final note = Note.fromMapEntry(noteId, noteMap[noteId]);
          notes.add(note.copyWith(document: noteReference));
        }
      }
    }

    return UnmodifiableListView(notes);
  }

  Stream<QuerySnapshot> personsSnapshot() {
    return _personsCollection.snapshots();
  }

  void clear() {
    _persons.clear();
  }

  Future<void> loadPersons() async {
    // https://gitlab.com/suztomo/hitomemo/-/issues/48
    final personIndex =
        await personIndexReference.get(source: await _firestoreSource());

    // Ensure logout and login clears the list of persons
    _persons.clear();
    _families.clear();
    if (personIndex.data == null) {
      // The first invocation
      return;
    }

    final personsMap = personIndex.data['persons'] as Map<String, dynamic>;
    final personIds = personsMap.keys;

    for (final personId in personIds) {
      final person =
          personFrom(personId, personsMap[personId] as Map<String, dynamic>);
      if (person == null) {
        continue;
      }
      _persons[personId] = person;

      final familyId = person.familyId;
      if (familyId != null) {
        var family = _families[familyId];
        if (family == null) {
          _families[familyId] = family = {};
        }
        if (person.id != familyId) {
          family.add(person.id);
        }
      }
    }
    notifyListeners();
  }

  String _nameCompareKey(Person p) {
    return (p.phoneticName ?? '') + p.name;
  }

  int _nameComparator(Person a, Person b) =>
      _nameCompareKey(a).compareTo(_nameCompareKey(b));

  Person personFrom(String personId, Map<String, dynamic> map) {
    if (map != null && map['notes'] == null) {
      // There's certain case where map['notes] is null?
      Crashlytics.instance.log('notes is null for personId: $personId');
    }

    // Unhandled Exception: type 'List<dynamic>' is not a subtype of type
    // 'List<String>' in type cast
    final noteReferences = (map['notes'] as List<dynamic>)
        .map((dynamic tagId) => tagId as DocumentReference)
        .toList();

    final person = Person(
      id: personId,
      name: map['name'] as String,
      phoneticName: map['phoneticName'] as String,
      updated: map['updated'] as Timestamp,
      pictureGcsPath: map['pictureGcsPath'] as String,
      notes: noteReferences,
      familyId: map['familyId'] as String,
    );

    return person;
  }

  Future<Person> addPerson(Person _person) async {
    const personCountFieldName = 'personCount';
    final currentTime = Timestamp.now();

    DocumentReference firstNoteDocument(String personId) {
      return _personsCollection
          .document(personId)
          .collection('notes')
          .document('0');
    }

    try {
      final result = await _firestore.runTransaction((Transaction tx) async {
        final userSnapshot = await tx.get(_userReference);
        final personCount =
            (userSnapshot.data[personCountFieldName] as int) ?? 0;
        final personId = '$personCount';

        final personIndexDoc = await tx.get(personIndexReference);
        if (!personIndexDoc.exists) {
          await tx.set(personIndexReference, <String, dynamic>{});
        }

        await tx.update(personIndexReference, <String, dynamic>{
          'persons.$personId.name': _person.name,
          'persons.$personId.phoneticName': _person.phoneticName,
          'persons.$personId.pictureGcsPath': _person.pictureGcsPath,
          'persons.$personId.created': currentTime,
          'persons.$personId.updated': currentTime,
          // No longer recording tags in persons document
          // https://gitlab.com/suztomo/hitomemo/-/issues/52
          // 'persons.$personId.tagIds': person.tagIds.toList(),
          'persons.$personId.notes': <DocumentReference>[
            firstNoteDocument(personId)
          ],
          'persons.$personId.familyId': _person.familyId,
        });

        await tx.update(_userReference, <String, FieldValue>{
          personCountFieldName: FieldValue.increment(1)
        });

        // In cloud_firestore, the transaction handler should return void
        // or a map somehow. The value of the Map cannot be Person or
        // DocumentReference; otherwise you get strange PlatformException(error,
        // Invalid argument: Instance of 'DocumentReference', null).
        // https://github.com/FirebaseExtended/flutterfire/issues/1642
        return <String, dynamic>{'personId': personId};
      });
      final personId = result['personId'] as String;
      final person = _person.copyWith(
        id: personId,
        notes: [firstNoteDocument(personId)],
        updated: currentTime,
      );

      updatePersonList(person); // Sort

      unawaited(analytics.logEvent(
          name: 'add_person',
          parameters: <String, dynamic>{'count': _persons.length}));

      final searchEngine = await this.searchEngine;
      await searchEngine.updatePersonTimestamp(person);

      notifyListeners();
      return person;
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document $err');
        }
      }
      rethrow;
    }
  }

  Future<void> updateFamily(Family updatedFamily) async {
    final familyId = updatedFamily.id;
    if (updatedFamily.memberIds.contains(familyId)) {
      throw Exception('Members should not contain family head ID');
    }
    final oldFamilyMembers = _families[familyId] ?? {};
    final newFamilyMembers = updatedFamily.memberIds;

    final toRemove = oldFamilyMembers.difference(newFamilyMembers);
    final toAdd = newFamilyMembers.difference(oldFamilyMembers);
    try {
      final batch = _firestore.batch();
      for (final personId in toRemove) {
        batch.updateData(personIndexReference, <String, dynamic>{
          'persons.$personId.familyId': FieldValue.delete(),
          'persons.$personId.updated': FieldValue.serverTimestamp(),
        });
      }
      for (final personId in toAdd) {
        batch.updateData(personIndexReference, <String, dynamic>{
          'persons.$personId.familyId': familyId,
          'persons.$personId.updated': FieldValue.serverTimestamp(),
        });
      }

      // Update the family head
      if (newFamilyMembers.isNotEmpty) {
        batch.updateData(personIndexReference, <String, dynamic>{
          'persons.$familyId.familyId': familyId,
          'persons.$familyId.updated': FieldValue.serverTimestamp(),
        });
      } else {
        batch.updateData(personIndexReference, <String, dynamic>{
          'persons.$familyId.familyId': null,
          'persons.$familyId.updated': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      _families[familyId] = updatedFamily.memberIds;
      for (final personId in toRemove) {
        _persons[personId] = _persons[personId].copyWith(familyId: null);
      }
      for (final personId in toAdd) {
        _persons[personId] = _persons[personId].copyWith(familyId: familyId);
      }
    } on Exception catch (err) {
      print('$err');
      rethrow;
    }
  }

  void updatePersonList(Person person) {
    _persons[person.id] = person;
  }

  /// Returns the added note. The note has noteID.
  /// https://gitlab.com/suztomo/hitomemo/-/wikis/Firestore-Document-Structure#note-documents-usersuseridpersonspersonidnotesnumber
  Future<Note> addNoteToPerson(Person _person, Note note) async {
    if (note.id != null) {
      throw Exception('The note already has ID. This cannot be added');
    }
    final currentTime = Timestamp.now();

    final personId = _person.id;
    try {
      var noteReference = _person.notes.last;

      // noteCount is responsible to ensure there's no duplicate note ID.
      // This field may not be updated by another place.
      const noteCountFieldName = 'noteCount';
      const newNoteDocumentKey = 'newNoteDocument';
      final result = await _firestore.runTransaction((Transaction tx) async {
        try {
          final userSnapshot = await tx.get(_userReference);
          final noteCount = (userSnapshot.data[noteCountFieldName] as int) ?? 0;
          final noteId = noteCount;

          final noteDoc = await tx.get(noteReference);

          final existingMap = noteDoc.data;
          final latestNoteMap =
              (existingMap != null && existingMap['notes'] != null)
                  ? (existingMap['notes'] as Map<String, dynamic>)
                  : <String, dynamic>{};
          final noteCountInDoc = latestNoteMap.keys.toList().length;

          final ret = <String, dynamic>{};

          if (noteCountInDoc >= 100) {
            final existingNoteDocumentCount = _person.notes.length;
            final newNoteDocumentId = '$existingNoteDocumentCount';
            // Create a reference to sibling
            noteReference = noteReference.parent().document(newNoteDocumentId);
            await tx.set(noteReference, <String, dynamic>{});
            ret[newNoteDocumentKey] = noteReference.path;

            await tx.set(_userReference, <String, dynamic>{
              'persons.$personId.notes':
                  FieldValue.arrayUnion(<DocumentReference>[noteReference])
            });
          } else if (!noteDoc.exists) {
            await tx.set(noteReference, <String, dynamic>{});
          }

          await tx.update(noteReference, <String, dynamic>{
            'notes.$noteId.content': note.content,
            'notes.$noteId.date': Note.toDate(note.date),
            'notes.$noteId.created': currentTime,
            'notes.$noteId.updated': currentTime,
            'notes.$noteId.tagIds': note.tagIds.toList(),
            'notes.$noteId.tagPersonIds': note.tagPersonIds.toList(),
            'notes.$noteId.pictureUrls': note.pictureUrls.toList(),
          });

          await tx.update(personIndexReference, <String, dynamic>{
            'persons.$personId.updated': currentTime,
          });
          await tx.update(_userReference, <String, FieldValue>{
            noteCountFieldName: FieldValue.increment(1)
          });

          // In cloud_firestore, the transaction handler should return void
          // or a map somehow.
          // https://github.com/FirebaseExtended/flutterfire/issues/1642
          ret['noteId'] = '$noteId';
          ret['noteDocumentPath'] = noteReference.path;
          return ret;
        } on Exception catch (err) {
          print('$err');
          rethrow;
        }
      });
      final noteDocumentPath = result['noteDocumentPath'] as String;
      if (noteDocumentPath == null) {
        print('this means the transaction did not run at the end');
      }

      // Note ID is unique within a user
      final _note = note.copyWith(
        id: result['noteId'] as String,
        document: _firestore.document(noteDocumentPath),
        updated: currentTime,
      );

      // for sorting
      var person = _person.copyWith(updated: currentTime);
      if (result.containsKey(newNoteDocumentKey)) {
        // The current note document exceeds the limit
        final newNoteReference =
            _firestore.document(result[newNoteDocumentKey] as String);
        // This change in person is not visible to users.
        person = person.copyWith(notes: [...person.notes, newNoteReference]);
      }
      updatePersonList(person);

      // Note count per person, not per user
      unawaited(analytics.logEvent(
          name: 'add_note_to_person',
          parameters: <String, dynamic>{'count': person.notes.length}));

      await (await searchEngine)?.indexNote(person, _note);

      notifyListeners();

      return _note;
    } on Exception catch (err) {
      print('Could not save new note $err');
      rethrow;
    }
  }

  Future<Person> updateNote(
      Person _person, Note originalNote, Note newNote) async {
    final noteId = newNote.id;
    final noteDocument = newNote.document;
    final currentTime = Timestamp.now();
    try {
      final batch = _firestore.batch()
        ..updateData(noteDocument, <String, dynamic>{
          'notes.$noteId.content': newNote.content,
          'notes.$noteId.updated': FieldValue.serverTimestamp(),
          'notes.$noteId.date': Note.toDate(newNote.date),
          'notes.$noteId.tagIds': newNote.tagIds.toList(),
          'notes.$noteId.tagPersonIds': newNote.tagPersonIds.toList(),
          'notes.$noteId.pictureUrls': newNote.pictureUrls.toList(),
        })
        ..updateData(personIndexReference, <String, dynamic>{
          'persons.${_person.id}.updated': currentTime,
        });
      await batch.commit();
    } on Exception catch (err) {
      print('Could not update note $err');
    }
    final person = _person.copyWith(updated: currentTime);
    updatePersonList(person);

    final searchEngine = await this.searchEngine;
    await searchEngine.indexNote(person, newNote);

    notifyListeners();
    return person;
  }

  Future<void> deleteAssociatedPicture(Person person, Note note) async {
    final fetchedNote = await fetchNote(person, note);
    final urls = <String>{...note.pictureUrls, ...fetchedNote.pictureUrls};

    for (final url in urls) {
      final uri = Uri.parse(url);
      final firebaseStorage = FirebaseStorage();
      final storageReference = firebaseStorage.ref().child(uri.path);
      await storageReference.delete();
      print('deleted $url');
    }
  }

  Future<Person> deleteNote(Person _person, Note _note) async {
    final currentTime = Timestamp.now();
    var note = _note.copyWith(updated: currentTime);
    final noteId = note.id;
    final noteDocument = note.document;

    // Delete pictures in Firebase storage
    unawaited(deleteAssociatedPicture(_person, _note));

    try {
      final batch = _firestore.batch()
        ..updateData(noteDocument, <String, dynamic>{
          'notes.$noteId.content': '', // To notify the deletion to other device
          'notes.$noteId.updated': FieldValue.serverTimestamp(),
          'notes.$noteId.deleted': true,
        })
        ..updateData(personIndexReference, <String, dynamic>{
          'persons.${_person.id}.updated': currentTime,
        });
      await batch.commit();
      note = note.copyWith(deleted: true);
    } on Exception catch (err) {
      print('Could not update note $err');
      rethrow;
    }

    final person = _person.copyWith(updated: currentTime);
    updatePersonList(person);
    await (await searchEngine)?.indexNote(person, note);

    notifyListeners();
    return person;
  }

  Future<Person> update(Person _person) async {
    final currentTime = Timestamp.now();
    final personId = _person.id;
    try {
      await personIndexReference.updateData(<String, dynamic>{
        'persons.$personId.name': _person.name,
        'persons.$personId.phoneticName': _person.phoneticName,
        'persons.$personId.updated': currentTime,
        // person_model is not responsible to update tag ID fields. It is
        // person_tags_model.
        // persons.$personId.notes will never get deleted
        'persons.$personId.notes': FieldValue.arrayUnion(_person.notes),
        'persons.$personId.pictureGcsPath': _person.pictureGcsPath,
        'persons.$personId.familyId': _person.familyId,
      });
    } on Exception catch (err) {
      print('Could not mark deleted: $err');
      rethrow;
    }
    final person = _person.copyWith(updated: currentTime);
    updatePersonList(person);

    final searchEngine = await this.searchEngine;
    await searchEngine.updatePersonTimestamp(person);

    notifyListeners();
    return person;
  }

  Future<void> delete(Person person) async {
    final personRef = _personsCollection.document(person.id);
    final personId = person.id;
    try {
      final batch = _firestore.batch()
        ..updateData(personIndexReference, <String, dynamic>{
          'persons.$personId': FieldValue.delete(),
        })
        ..delete(personRef);
      await batch.commit();
      _persons.remove(personId);
      notifyListeners();
    } on Exception catch (err) {
      print('Could not delete: $err');
      rethrow;
    }
  }

  Future<void> setLoginUserModel(LoginUserModel loginUserModel) async {
    if (_loginUserModel != null &&
        _userReference == loginUserModel.userReference) {
      return;
    }
    _loginUserModel = loginUserModel;
    _firebaseUser = loginUserModel.user;

    _userReference = loginUserModel.userReference;

    _personsCollection = _userReference.collection('persons');

    personIndexReference = _personsCollection.document('index');

    return loadPersons();
  }

  bool _matchText(String name, String query) {
    if (name == null) {
      return false;
    }
    if (name.contains(query)) {
      return true;
    }
    final lowerQuery = query.toLowerCase();
    final lowerName = name.toLowerCase();
    if (lowerName.contains(lowerQuery)) {
      return true;
    }
    return false;
  }

  List<Person> searchByText(String text) {
    final ret = <Person>[];
    for (final person in _persons.values) {
      if (_matchText(person.name, text) ||
          _matchText(person.phoneticName, text) ||
          matchRomaji(person.name, text) ||
          matchRomaji(person.phoneticName, text)) {
        ret.add(person);
      }
    }
    return ret;
  }
}
