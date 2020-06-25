import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/many_to_many.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

import 'default_tags.i18n.dart';
import 'login_user_model.dart';
import 'tag.dart';

/// Source of the truth of NTags and its relationship to Note IDs.
///
/// Note documents are maintained by PersonsModel.
class NoteTagRepository extends ChangeNotifier {
  NoteTagRepository(this._firestore, this._connectivity);
  final Firestore _firestore;
  final Connectivity _connectivity;
  FirebaseUser _firebaseUser;

  DocumentReference _userReference;

  CollectionReference _tagCollection;

  DocumentReference _tagIndexReference;

  FirebaseUser get loginUser => _firebaseUser;

  // NTag to Note ID mapping. Do we need this when we employ one document per
  // note strategy as in
  // https://gitlab.com/suztomo/hitomemo/-/wikis/Chronological-Fragmentation#proposal-one-document-per-note
  IdMap<NTag> store = IdMap();

  final Map<String, NTag> _tags = {};

  UnmodifiableListView<NTag> get tags => store.keys;

  UnmodifiableMapView<String, NTag> get tagsByName {
    final ret = <String, NTag>{};
    for (final tag in _tags.values) {
      ret[tag.name] = tag;
    }
    return UnmodifiableMapView(ret);
  }

  NTag get(String tagId) {
    return _tags[tagId];
  }

  // users/<uid>/noteTags
  static const String userNoteTagsFieldName = 'noteTags';

  static Future<void> addInitialNoteTagsInTransaction(
      Transaction tx, DocumentReference userDocumentReference) async {
    final noteTagIndex =
        userDocumentReference.collection('noteTags').document('index');
    await tx.set(noteTagIndex, <String, dynamic>{
      'noteTags': {
        '1': {
          'name': 'Birthday'.i18n,
          'updated': FieldValue.serverTimestamp(),
          'created': FieldValue.serverTimestamp(),
        },
        '2': {
          'name': 'Anniversary'.i18n,
          'updated': FieldValue.serverTimestamp(),
          'created': FieldValue.serverTimestamp(),
        },
        '3': {
          'name': 'Steps towards My Dream'.i18n,
          'updated': FieldValue.serverTimestamp(),
          'created': FieldValue.serverTimestamp(),
        },
      }
    });
  }

  Future<void> setLoginUserModel(LoginUserModel loginUserModel) async {
    /// This is called only once per login?
    _firebaseUser = loginUserModel.user;
    final uid = _firebaseUser.uid;
    _userReference = _firestore.collection('users').document('$uid');

    // Be consistent with Login User Model
    _tagCollection = _userReference.collection('noteTags');
    _tagIndexReference = _tagCollection.document('index');

    await loadTags();
  }

  void _loadTagFromTagIndex(DocumentSnapshot tagIndexSnapshot) {
    final tagIndex =
        tagIndexSnapshot.data[userNoteTagsFieldName] as Map<String, dynamic>;
    if (tagIndex != null) {
      tagIndex.forEach((tagId, dynamic value) {
        // ignore: unused_local_variable
        final tag = NTag.fromMapEntry(tagId, value);
        store.addKey(tag);
        _tags[tagId] = tag;
      });
    } else {
      // _tags is empty
    }
  }

  Future<void> loadTags() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final firestoreSource = (connectivityResult == ConnectivityResult.none)
        ? Source.cache
        : Source.serverAndCache;

    // How come this snapshot does not have any data for new user?
    final snapshot = await _tagIndexReference.get(source: firestoreSource);

    store.clear();
    _tags.clear();
    if (snapshot.exists) {
      _loadTagFromTagIndex(snapshot);
    }
  }

  Future<void> save(NTag tag) async {
    // https://stackoverflow.com/questions/46639058/firebase-cloud-firestore-invalid-collection-reference-collection-references-m
    final documentRef = _tagIndexReference;
    final tagId = tag.id;
    try {
      await _tagIndexReference.updateData(<String, dynamic>{
        '$userNoteTagsFieldName.$tagId.name': tag.name,
        '$userNoteTagsFieldName.$tagId.created': FieldValue.serverTimestamp(),
        '$userNoteTagsFieldName.$tagId.updated': FieldValue.serverTimestamp(),
      });

      store.addKey(tag);
      _tags[tagId] = tag;

      notifyListeners();
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document'
              ' ${documentRef.path}');
        }
      }
      rethrow;
    }
  }

  Future<void> update(NTag tag) async {
    // https://stackoverflow.com/questions/46639058/firebase-cloud-firestore-invalid-collection-reference-collection-references-m
    final documentRef = _tagIndexReference;
    final tagId = tag.id;
    try {
      await _tagIndexReference.updateData(<String, dynamic>{
        '$userNoteTagsFieldName.$tagId.name': tag.name,
        '$userNoteTagsFieldName.$tagId.updated': FieldValue.serverTimestamp(),
      });

      store.updateKey(tag);
      _tags[tag.id] = tag;

      notifyListeners();
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document'
              ' ${documentRef.path}');
        }
      }
      rethrow;
    }
  }

  Future<void> delete(NTag tag) async {
    final documentRef = _tagIndexReference;
    final tagId = tag.id;
    try {
      final batch = _firestore.batch()
        ..updateData(_tagIndexReference, <String, dynamic>{
          '$userNoteTagsFieldName.$tagId': FieldValue.delete(),
        })
        ..delete(_tagCollection.document(tagId));

      await batch.commit();
      store.removeKey(tag);
      _tags.remove(tagId);

      notifyListeners();
    } on Exception catch (err) {
      print('Error: $err');
      if (err is PlatformException) {
        if (err.code == 'Error 7') {
          // This happens when user disapprove Google OAuth in their account
          // while Firebase client in this app does not know about that.
          // https://myaccount.google.com/permissions
          print('Insufficient permission to update the document'
              ' ${documentRef.path}');
        }
      }
      rethrow;
    }
  }

  static final RegExp tagRegex = RegExp(r'#(\w+)');

  /// Extracts tag names written in text. A tag is characters followed by '#'
  /// character.
  static Set<String> extractTagNames(String text) {
    /*
    const hashtagLetters = '\p{L}\p{M}';
    const hashtagNumerals = '\p{Nd}';
    const hashtagSpecialChars =
        '_\u200c\u200d\ua67e\u05be\u05f3\u05f4\uff5e\u301c\u309b'
        '\u309c\u30a0\u30fb\u3003\u0f0b\u0f0c\u00b7';
    const hashtagLettersNumerals =
        hashtagLetters + hashtagNumerals + hashtagSpecialChars;
    const hashtagLettersNumeralsSet = '[' + hashtagLettersNumerals + ']';
    const hashtagLettersSet = '[' + hashtagLetters + ']';
    final hashtagRegex = RegExp('(^|[^&' +
        hashtagLettersNumerals +
        '])(#|\uFF03)(?!\uFE0F|\u20E3)(' +
        hashtagLettersNumeralsSet +
        '*' +
        hashtagLettersSet +
        hashtagLettersNumeralsSet +
        // ignore: lines_longer_than_80_chars
        '*)');*/

    // Regular expression from Twitter's library
    // https://github.com/twitter/twitter-text/blob/master/js/src/regexp/bmpLetterAndMarks.js

    const bmpLetterAndMarks =
        // ignore: lines_longer_than_80_chars
        'A-Za-z\xaa\xb5\xba\xc0-\xd6\xd8-\xf6\xf8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec\u02ee\u0300-\u0374\u0376\u0377\u037a-\u037d\u037f\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u0483-\u052f\u0531-\u0556\u0559\u0561-\u0587\u0591-\u05bd\u05bf\u05c1\u05c2\u05c4\u05c5\u05c7\u05d0-\u05ea\u05f0-\u05f2\u0610-\u061a\u0620-\u065f\u066e-\u06d3\u06d5-\u06dc\u06df-\u06e8\u06ea-\u06ef\u06fa-\u06fc\u06ff\u0710-\u074a\u074d-\u07b1\u07ca-\u07f5\u07fa\u0800-\u082d\u0840-\u085b\u08a0-\u08b2\u08e4-\u0963\u0971-\u0983\u0985-\u098c\u098f\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bc-\u09c4\u09c7\u09c8\u09cb-\u09ce\u09d7\u09dc\u09dd\u09df-\u09e3\u09f0\u09f1\u0a01-\u0a03\u0a05-\u0a0a\u0a0f\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32\u0a33\u0a35\u0a36\u0a38\u0a39\u0a3c\u0a3e-\u0a42\u0a47\u0a48\u0a4b-\u0a4d\u0a51\u0a59-\u0a5c\u0a5e\u0a70-\u0a75\u0a81-\u0a83\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2\u0ab3\u0ab5-\u0ab9\u0abc-\u0ac5\u0ac7-\u0ac9\u0acb-\u0acd\u0ad0\u0ae0-\u0ae3\u0b01-\u0b03\u0b05-\u0b0c\u0b0f\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32\u0b33\u0b35-\u0b39\u0b3c-\u0b44\u0b47\u0b48\u0b4b-\u0b4d\u0b56\u0b57\u0b5c\u0b5d\u0b5f-\u0b63\u0b71\u0b82\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99\u0b9a\u0b9c\u0b9e\u0b9f\u0ba3\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bbe-\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcd\u0bd0\u0bd7\u0c00-\u0c03\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c39\u0c3d-\u0c44\u0c46-\u0c48\u0c4a-\u0c4d\u0c55\u0c56\u0c58\u0c59\u0c60-\u0c63\u0c81-\u0c83\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbc-\u0cc4\u0cc6-\u0cc8\u0cca-\u0ccd\u0cd5\u0cd6\u0cde\u0ce0-\u0ce3\u0cf1\u0cf2\u0d01-\u0d03\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d-\u0d44\u0d46-\u0d48\u0d4a-\u0d4e\u0d57\u0d60-\u0d63\u0d7a-\u0d7f\u0d82\u0d83\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0dca\u0dcf-\u0dd4\u0dd6\u0dd8-\u0ddf\u0df2\u0df3\u0e01-\u0e3a\u0e40-\u0e4e\u0e81\u0e82\u0e84\u0e87\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa\u0eab\u0ead-\u0eb9\u0ebb-\u0ebd\u0ec0-\u0ec4\u0ec6\u0ec8-\u0ecd\u0edc-\u0edf\u0f00\u0f18\u0f19\u0f35\u0f37\u0f39\u0f3e-\u0f47\u0f49-\u0f6c\u0f71-\u0f84\u0f86-\u0f97\u0f99-\u0fbc\u0fc6\u1000-\u103f\u1050-\u108f\u109a-\u109d\u10a0-\u10c5\u10c7\u10cd\u10d0-\u10fa\u10fc-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u135d-\u135f\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16f1-\u16f8\u1700-\u170c\u170e-\u1714\u1720-\u1734\u1740-\u1753\u1760-\u176c\u176e-\u1770\u1772\u1773\u1780-\u17d3\u17d7\u17dc\u17dd\u180b-\u180d\u1820-\u1877\u1880-\u18aa\u18b0-\u18f5\u1900-\u191e\u1920-\u192b\u1930-\u193b\u1950-\u196d\u1970-\u1974\u1980-\u19ab\u19b0-\u19c9\u1a00-\u1a1b\u1a20-\u1a5e\u1a60-\u1a7c\u1a7f\u1aa7\u1ab0-\u1abe\u1b00-\u1b4b\u1b6b-\u1b73\u1b80-\u1baf\u1bba-\u1bf3\u1c00-\u1c37\u1c4d-\u1c4f\u1c5a-\u1c7d\u1cd0-\u1cd2\u1cd4-\u1cf6\u1cf8\u1cf9\u1d00-\u1df5\u1dfc-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u2071\u207f\u2090-\u209c\u20d0-\u20f0\u2102\u2107\u210a-\u2113\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e\u2183\u2184\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cf3\u2d00-\u2d25\u2d27\u2d2d\u2d30-\u2d67\u2d6f\u2d7f-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u2de0-\u2dff\u2e2f\u3005\u3006\u302a-\u302f\u3031-\u3035\u303b\u303c\u3041-\u3096\u3099\u309a\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400-\u4db5\u4e00-\u9fcc\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua61f\ua62a\ua62b\ua640-\ua672\ua674-\ua67d\ua67f-\ua69d\ua69f-\ua6e5\ua6f0\ua6f1\ua717-\ua71f\ua722-\ua788\ua78b-\ua78e\ua790-\ua7ad\ua7b0\ua7b1\ua7f7-\ua827\ua840-\ua873\ua880-\ua8c4\ua8e0-\ua8f7\ua8fb\ua90a-\ua92d\ua930-\ua953\ua960-\ua97c\ua980-\ua9c0\ua9cf\ua9e0-\ua9ef\ua9fa-\ua9fe\uaa00-\uaa36\uaa40-\uaa4d\uaa60-\uaa76\uaa7a-\uaac2\uaadb-\uaadd\uaae0-\uaaef\uaaf2-\uaaf6\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uab30-\uab5a\uab5c-\uab5f\uab64\uab65\uabc0-\uabea\uabec\uabed\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf870-\uf87f\uf882\uf884-\uf89f\uf8b8\uf8c1-\uf8d6\uf900-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40\ufb41\ufb43\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfb\ufe00-\ufe0f\ufe20-\ufe2d\ufe70-\ufe74\ufe76-\ufefc\uff21-\uff3a\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc';
    const bmpNumerals =
        // ignore: lines_longer_than_80_chars
        '0-9\u0660-\u0669\u06f0-\u06f9\u07c0-\u07c9\u0966-\u096f\u09e6-\u09ef\u0a66-\u0a6f\u0ae6-\u0aef\u0b66-\u0b6f\u0be6-\u0bef\u0c66-\u0c6f\u0ce6-\u0cef\u0d66-\u0d6f\u0de6-\u0def\u0e50-\u0e59\u0ed0-\u0ed9\u0f20-\u0f29\u1040-\u1049\u1090-\u1099\u17e0-\u17e9\u1810-\u1819\u1946-\u194f\u19d0-\u19d9\u1a80-\u1a89\u1a90-\u1a99\u1b50-\u1b59\u1bb0-\u1bb9\u1c40-\u1c49\u1c50-\u1c59\ua620-\ua629\ua8d0-\ua8d9\ua900-\ua909\ua9d0-\ua9d9\ua9f0-\ua9f9\uaa50-\uaa59\uabf0-\uabf9\uff10-\uff19/';
    const hashtagSpecialChars =
        // ignore: lines_longer_than_80_chars
        '_\u200c\u200d\ua67e\u05be\u05f3\u05f4\uff5e\u301c\u309b\u309c\u30a0\u30fb\u3003\u0f0b\u0f0c\xb7';
    // ignore: lines_longer_than_80_chars
    const hashtagAlpha = '$bmpLetterAndMarks$bmpNumerals$hashtagSpecialChars';
    final hashtagRegex = RegExp(
        // ignore: lines_longer_than_80_chars
        '(^|[^$bmpLetterAndMarks])(#|\uFF03)([$bmpLetterAndMarks][$hashtagAlpha]+)');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(3)).toSet();
  }
}
