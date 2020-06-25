import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hitomemo/note_tags_model.dart';
import 'package:hitomemo/person_model.dart';
import 'package:hitomemo/person_tags_model.dart';
import 'package:http/http.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:pedantic/pedantic.dart';

import 'onboarding/screen_sign_in.i18n.dart';
import 'person.dart';

// To clear login status on Hitomemo, visit Google Account settings
// "Signing in with Google" section
// https://myaccount.google.com/permissions?pli=1
enum LoginStatus {
  unknown,
  notLoggedIn,
  loggedIn,
}

// https://console.firebase.google.com/u/0/project/suztomo-hitomemo/database
class LoginUserModel extends ChangeNotifier {
  LoginUserModel(this._auth, this._firestore) {
    _auth.currentUser().then((currentUser) {
      _user = currentUser;
      if (_user != null) {
        _status = LoginStatus.loggedIn;
        Crashlytics.instance.setUserIdentifier(_user.uid);
        Crashlytics.instance.log('Logged-in: ${_user.uid}');
      } else {
        _status = LoginStatus.notLoggedIn;
      }
      notifyListeners();
    });
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  final FirebaseAuth _auth;
  final Firestore _firestore;

  static const userCountField = 'userCount';

  Future<void> saveUserInformation(
      FirebaseUser user, String displayName) async {
    // This ID is unpredictable (not a number or email address). This
    // unpredictable ID prevents malicious attackers to access Firebase data.
    final userDocumentReference =
        _firestore.collection('users').document(user.uid);
    final userDocument = await userDocumentReference.get();

    if (!userDocument.exists) {
      // Welcome new user!
      try {
        await _firestore.runTransaction((Transaction tx) async {
          final userCounter =
              _firestore.collection('global').document('user_counter');
          final counterSnapshot = await tx.get(userCounter);
          var count = 1;
          if (counterSnapshot.exists) {
            // The counter points next user ID
            count = counterSnapshot.data[userCountField] as int;
            await tx.update(userCounter,
                <String, dynamic>{userCountField: FieldValue.increment(1)});
          } else {
            await tx.set(userCounter,
                <String, dynamic>{userCountField: FieldValue.increment(1)});
          }

          final providers = user.providerData;
          // apple.com or/and google.com
          final providerIds =
              providers.map((p) => p.providerId).toList(growable: false);

          final userDocumentData = <String, dynamic>{
            'id': count,
            'displayName': displayName,
            'email': user.email,
            'providerIds': providerIds,
            'phoneNumber': user.phoneNumber,
            'photoUrl': user.photoUrl,
            'created': FieldValue.serverTimestamp(),
            'updated': FieldValue.serverTimestamp(),
            'isEmailVerified': user.isEmailVerified,
            'language': I18n.language,
          };
          // Sets tags fields
          TagsModel.initializeTagsObject(userDocumentData);

          await tx.set(userDocumentReference, userDocumentData);

          // Note: when this fails due to missing translation key, the
          // transaction is still committed.
          await NoteTagRepository.addInitialNoteTagsInTransaction(
              tx, userDocumentReference);
        });
        unawaited(analytics.logSignUp(signUpMethod: user.providerId));
      } on Exception catch (err) {
        print('Error creating user document $err');
      }

      // Add the user as the first person. This gives vividness of the app
      try {
        await _saveUserAsPerson(user, displayName);
      } on Exception catch (err) {
        print('Error creating user-as-person document $err');
      }
    } else {
      // Thank you for coming back.

      final providers = user.providerData;
      // apple.com or/and google.com
      final providerIds =
          providers.map((p) => p.providerId).toList(growable: false);

      // Somehow, it doesn't seem to receive the latest data in
      // https://myaccount.google.com/personal-info
      await userDocumentReference.updateData(<String, dynamic>{
        'displayName': displayName,
        'email': user.email,
        'providerIds': providerIds,
        'phoneNumber': user.phoneNumber,
        'photoUrl': user.photoUrl,
        'updated': FieldValue.serverTimestamp(),
        'isEmailVerified': user.isEmailVerified,
        'language': I18n.language,
      });
    }
  }

  Future<void> _saveUserAsPerson(FirebaseUser user, String displayName) async {
    // Short lived PersonsModel
    final personsModel = PersonsModel(_firestore, Connectivity());
    await personsModel.setLoginUserModel(this);

    // Sets ID. Very likely '0'.
    var userAsPerson = Person(name: displayName ?? 'Your name'.i18n);
    userAsPerson = await personsModel.addPerson(userAsPerson);

    if (user.photoUrl == null || !user.photoUrl.contains('.')) {
      return;
    }

    final response = await get(user.photoUrl);

    // png or jpg
    var fileExtension = 'jpg';
    if (fileExtension == 'jpeg') {
      fileExtension = 'jpg';
    }

    final headers = response.headers;
    if (headers['content-type'].contains('png')) {
      fileExtension = 'png';
    }

    final personPath = '${user.uid}/${userAsPerson.id}';
    final path = '$personPath/from_auth_provider.$fileExtension';
    final firebaseStorage = FirebaseStorage();
    final storageReference = firebaseStorage.ref().child(path);
    final uploadTask = storageReference.putData(response.bodyBytes);

    final streamSubscription = uploadTask.events.listen((event) {
      // https://pub.dev/packages/firebase_storage
      print('EVENT ${event.type}');
    });

    final taskSnapshot = await uploadTask.onComplete;
    await streamSubscription.cancel();
    if (taskSnapshot.error != null) {
      print('taskSnapshot.error: ${taskSnapshot.error}');
      return;
    } else {
      final bucketName = await storageReference.getBucket();
      userAsPerson = userAsPerson.copyWith(
          pictureGcsPath: 'gs://$bucketName/${storageReference.path}');
      await personsModel.update(userAsPerson);
    }
  }

  FirebaseUser _user;

  DocumentReference get userReference =>
      _firestore.collection('users').document('${_user.uid}');

  LoginStatus _status = LoginStatus.unknown;

  FirebaseUser get user => _user;

  LoginStatus get status => _status;

  bool get isLoggedin => _user != null;

  /// User login. DisplayName is the name to register the user into the service
  Future<void> loginUser(FirebaseUser user, {String displayName}) async {
    _user = user;

    unawaited(analytics.logLogin());

    _status = LoginStatus.unknown;
    notifyListeners();

    await saveUserInformation(user, displayName ?? user.displayName);

    _status = LoginStatus.loggedIn;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _status = LoginStatus.notLoggedIn;
    _user = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getUser() async {
    final snapshot = await userReference.get();
    return snapshot.data;
  }
}
