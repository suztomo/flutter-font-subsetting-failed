import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/many_to_many.dart';
import 'package:hitomemo/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

import 'default_tags.i18n.dart';
import 'login_user_model.dart';
import 'person_model.dart';
import 'tag.dart';

// https://console.firebase.google.com/u/0/project/suztomo-hitomemo/database
class TagsModel extends ChangeNotifier {
  TagsModel(this._firestore, this._connectivity);
  final Firestore _firestore;
  final Connectivity _connectivity;
  FirebaseUser _firebaseUser;

  DocumentReference _userReference;

  FirebaseUser get loginUser => _firebaseUser;

  // PTag to Person ID
  final IdMap<PTag> tagMap = IdMap();

  UnmodifiableListView<PTag> get tags => tagMap.keys;

  List<PTag> getTags(String personId) {
    return tagMap.getKeys(personId);
  }

  List<String> getPersonIds(PTag tagId) {
    return tagMap.getValues(tagId);
  }

  // users/<uid>/tags
  static const String userTagsFieldName = 'tags';

  static const String tagPersonIdsFieldName = 'personIds';

  PersonsModel personsModel;

  Future<void> setLoginUserModel(LoginUserModel loginUserModel) async {
    _firebaseUser = loginUserModel.user;
    _userReference = loginUserModel.userReference;

    await loadTags();
  }

  void _loadTagFromUserDocument(DocumentSnapshot userDocument) {
    tagMap.clear();
    final tagsDocument =
        userDocument[userTagsFieldName] as Map<String, dynamic>;
    if (userDocument[userTagsFieldName] != null) {
      tagsDocument.forEach((key, dynamic value) {
        final tag = PTag.fromMapEntry(key, value);
        tagMap.addKey(tag);
        final personIds =
            (value[tagPersonIdsFieldName] ?? <dynamic>[]) as List<dynamic>;
        for (final personId in personIds) {
          tagMap.add(tag.id, personId as String);
        }
      });
    } else {
      // _tags is empty
    }

    notifyListeners();
  }

  Future<void> loadTags() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final firestoreSource = (connectivityResult == ConnectivityResult.none)
        ? Source.cache
        : Source.serverAndCache;

    // How come this snapshot does not have any data for new user?
    final snapshot = await _userReference.get(source: firestoreSource);
    if (snapshot.exists) {
      _loadTagFromUserDocument(snapshot);
    }
  }

  /// Updates multiple tags of one person in one batch.
  Future<void> addPersonTag(Person person, PTag newTag) async {
    final oldTags = getTags(person.id);
    return updatePersonTags(person, {newTag, ...oldTags});
  }

  /// Updates multiple tags of one person in one batch.
  Future<void> updatePersonTags(Person person, Set<PTag> newTags) async {
    final oldTags = getTags(person.id);
    final oldTagIds = oldTags.map((t) => t.id).toSet();
    final newTagIds = newTags.map((t) => t.id).toSet();
    final personId = person.id;
    final removes = oldTagIds.difference(newTagIds);
    final adds = newTagIds.difference(oldTagIds);
    final currentTime = DateTime.now();

    final userTagUpdates = <String, dynamic>{};
    for (final tagId in adds) {
      userTagUpdates['$userTagsFieldName.$tagId.$tagPersonIdsFieldName'] =
          FieldValue.arrayUnion(<String>[personId]);
      userTagUpdates['$userTagsFieldName.$tagId.updated'] = currentTime;
    }

    for (final tagId in removes) {
      userTagUpdates['$userTagsFieldName.$tagId.$tagPersonIdsFieldName'] =
          FieldValue.arrayRemove(<String>[personId]);
      userTagUpdates['$userTagsFieldName.$tagId.updated'] = currentTime;
    }
    try {
      await _userReference.updateData(userTagUpdates);
      for (final tagId in adds) {
        tagMap.add(tagId, personId);
      }
      for (final tagId in removes) {
        tagMap.remove(tagId, personId);
      }

      notifyListeners();
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document'
              ' ${_userReference.path}');
        }
      }
      rethrow;
    }
  }

  Future<void> removePersonsFromTag(Set<Person> persons, PTag tag) async {
    final tagId = tag.id;
    final personIdsToRemove = persons.map((p) => p.id).toList();
    try {
      await _userReference.updateData(<String, dynamic>{
        '$userTagsFieldName.$tagId.$tagPersonIdsFieldName':
            FieldValue.arrayRemove(personIdsToRemove),
        '$userTagsFieldName.$tagId.updated': DateTime.now(),
      });
      for (final personId in personIdsToRemove) {
        tagMap.remove(tagId, personId);
      }
      notifyListeners();
      return;
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document'
              ' ${_userReference.path}');
        }
      }
      rethrow;
    }
  }

  static const pTagCountFieldName = 'personTagCounter';

  static void initializeTagsObject(Map<String, dynamic> userDocumentData) {
    // Reserve the first 100 groups to something
    userDocumentData[pTagCountFieldName] = 100;
    userDocumentData['tags'] = {
      '1': {
        'name': 'Family'.i18n,
        'created': FieldValue.serverTimestamp(),
        'updated': FieldValue.serverTimestamp(),
      },
      '2': {
        'name': 'Work'.i18n,
        'created': FieldValue.serverTimestamp(),
        'updated': FieldValue.serverTimestamp(),
      },
      '3': {
        'name': 'School'.i18n,
        'created': FieldValue.serverTimestamp(),
        'updated': FieldValue.serverTimestamp(),
      },
    };
  }

  /// Creates and updates tag
  Future<PTag> save(PTag tag) async {
    final currentTime = DateTime.now();
    try {
      final result = await _firestore.runTransaction((Transaction tx) async {
        final userSnapshot = await tx.get(_userReference);
        final personTagCount =
            (userSnapshot.data[pTagCountFieldName] as int) ?? 0;
        final tagId = personTagCount;

        await tx.update(_userReference, <String, dynamic>{
          'tags.$tagId.name': tag.name,
          'tags.$tagId.created': currentTime,
          'tags.$tagId.updated': currentTime,
        });

        await tx.update(_userReference,
            <String, FieldValue>{pTagCountFieldName: FieldValue.increment(1)});

        // In cloud_firestore, the transaction handler should return void
        // or a map somehow.
        // https://github.com/FirebaseExtended/flutterfire/issues/1642
        return <String, dynamic>{'tagId': '$tagId'};
      });
      final tagWithId = tag.copyWith(id: result['tagId'] as String);

      tagMap.addKey(tagWithId);
      notifyListeners();
      return tagWithId;
    } on Exception catch (err) {
      print('Could not save tag $err');
      rethrow;
    }
  }

  /// Creates and updates tag
  Future<PTag> update(PTag tag) async {
    final tagId = tag.id;
    final timestamp = DateTime.now();
    try {
      await _userReference.updateData(<String, dynamic>{
        'tags.$tagId.name': tag.name,
        'tags.$tagId.updated': timestamp
      });
    } on Exception catch (err) {
      print('Could not update $tagId $err');
      rethrow;
    }
    tagMap.updateKey(tag);
    notifyListeners();
    return tag;
  }

  // This function should not care about person model.
  Future<void> delete(PTag tag) async {
    final tagId = tag.id;
    final batch = _firestore.batch();
    try {
      batch.updateData(_userReference, <String, dynamic>{
        '$userTagsFieldName.$tagId': FieldValue.delete(),
      });
      await batch.commit();
      tagMap.removeKey(tag);
      notifyListeners();
    } on Exception catch (err) {
      print('Could not delete $tagId $err');
      rethrow;
    }
  }
}
