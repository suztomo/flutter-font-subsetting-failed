import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../person.dart';
import 'cached_image.dart';
import 'person_editable_avatar.i18n.dart';

class PersonEditableAvatar extends StatefulWidget {
  const PersonEditableAvatar(this.notifier, {this.size = 50});
  final ValueNotifier<Person> notifier;

  final double size;

  @override
  State<StatefulWidget> createState() {
    return _PersonEditableAvatarState();
  }
}

class _PersonEditableAvatarState extends State<PersonEditableAvatar> {
  bool uploadingPhoto = false;

  Future<File> _pickImage(BuildContext context) async {
    try {
      final imageFile =
          await ImagePicker.pickImage(source: ImageSource.gallery);
      return imageFile;
    } on PlatformException catch (err) {
      // User did not give permission
      if (err.code == 'photo_access_denied') {
        return null;
      }
      return null;
    } on Exception catch (_) {
      // User did not give permission
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      child: Stack(
        children: <Widget>[
          ValueListenableBuilder<Person>(
              valueListenable: widget.notifier,
              builder: (context, person, _) => SizedBox(
                    height: widget.size,
                    width: widget.size,
                    child: person.pictureGcsPath == null
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: person.name.isEmpty
                                        ? Colors.grey
                                        : theme.primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.onPrimary,
                                )),
                          )
                        : CircleAvatar(
                            backgroundImage: CachedImage(person.pictureGcsPath),
                            backgroundColor: theme.disabledColor,
                          ),
                  )),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.add_circle,
              color: theme.primaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

enum AvatarSource {
  photoLibrary,
  icon,
}

class AvatarSourceSelection extends StatelessWidget {
  const AvatarSourceSelection({Key key, this.scrollController})
      : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Photo Library'.i18n),
            leading: Icon(Icons.photo),
            onTap: () => Navigator.of(context).pop(AvatarSource.photoLibrary),
          ),
          ListTile(
            title: Text('Icons'.i18n),
            leading: Icon(Icons.face),
            onTap: () => Navigator.of(context).pop(AvatarSource.icon),
          ),
        ],
      ),
    ));
  }
}

List<String> _cachedDefaultIconUrls;

Future<List<String>> iconGcsUrls() async {
  final firebaseStorage = FirebaseStorage();
  if (_cachedDefaultIconUrls != null) {
    return _cachedDefaultIconUrls;
  }
  final futures = [
    'avatar-user-01.png',
    'avatar-user-02.png',
    'avatar-user-03.png',
    'avatar-user-04.png',
    'avatar-user-05.png',
    'avatar-user-06.png',
    'avatar-user-07.png',
    'avatar-user-08.png',
    'avatar-user-09.png',
    'avatar-user-10.png',
    'avatar-user-11.png',
    'avatar-user-12.png',
    'avatar-user-13.png',
    'avatar-user-14.png',
    'avatar-user-15.png',
    'avatar-user-16.png',
  ].map((f) async {
    final storageReference = firebaseStorage.ref().child('shared/$f');
    final bucket = await storageReference.getBucket();
    return 'gs://$bucket/${storageReference.path}';
  }).toList(growable: false);
  return _cachedDefaultIconUrls = await Future.wait(futures);
}

class AvatarIconSelection extends StatelessWidget {
  const AvatarIconSelection({Key key, this.scrollController}) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final iconUrls = iconGcsUrls();

    final theme = Theme.of(context);
    return Material(
        child: SafeArea(
      top: false,
      child: FutureBuilder<List<String>>(
          future: iconUrls,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            if (snapshot.hasData) {
              return Container(
                child: GridView.count(
                  crossAxisCount: 4,
                  children: snapshot.data.map((gcsUrl) {
                    return GestureDetector(
                      child: CircleAvatar(
                        backgroundImage: CachedImage(gcsUrl),
                        backgroundColor: theme.disabledColor,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(gcsUrl);
                      },
                    );
                  }).toList(growable: false),
                ),
              );
            } else {
              return Container(
                  child: const Center(
                child: LinearProgressIndicator(),
              ));
            }
          }),
    ));
  }
}
