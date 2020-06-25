import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as _image;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../login_user_model.dart';
import '../person.dart';
import 'cached_image.dart';
import 'person_editable_avatar.i18n.dart';
import 'photo_access_dialog.dart';

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
        await dialogPhotoAccess(context);
        return null;
      }
      return null;
    } on Exception catch (_) {
      // User did not give permission
      return null;
    }
  }

  /// Returns path of Google Cloud Storage image
  Future<String> _uploadImage(BuildContext context, File file) async {
    final loginUserModel = Provider.of<LoginUserModel>(context, listen: false);
    final person = widget.notifier.value;
    final personId = person.id;
    final filename = personId != null ? personId : 'unsaved';
    final personPath = '${loginUserModel.user.uid}/$filename';
    // final extension = file.path.split('.').last;
    final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch / 1000;
//    final path = '$personPath.jpg';
    final path = '$personPath/$secondsSinceEpoch.jpg';
    final firebaseStorage = FirebaseStorage();
    final storageReference = firebaseStorage.ref().child(path);
    final uploadTask = storageReference.putFile(file);
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Uploading picture'.i18n)));

    setState(() {
      uploadingPhoto = true;
    });
    final streamSubscription = uploadTask.events.listen((event) {
      // https://pub.dev/packages/firebase_storage
      print('EVENT ${event.type}');
    });

    final taskSnapshot = await uploadTask.onComplete;
    await streamSubscription.cancel();
    setState(() {
      uploadingPhoto = false;
    });
    if (taskSnapshot.error != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Picture failed: Error: %s'
              .i18n
              .fill(['${taskSnapshot.error}']))));
      return null;
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Picture uploaded'.i18n)));
      final bucketName = await storageReference.getBucket();
      return 'gs://$bucketName/${storageReference.path}';
    }
  }

  Future<void> _onPhotoIconPressed(BuildContext context) async {
    final theme = Theme.of(context);
    final imageFile = await _pickImage(context);
    if (imageFile == null) {
      return;
    }

    final croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper'.i18n,
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: theme.primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1,
          hidesNavigationBar: false,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
        ));
    if (croppedFile == null) {
      return;
    }

    final decodedImage = _image.decodeImage(croppedFile.readAsBytesSync());
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    // Use 8x8 grid
    // https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/
    final resizedImage = _image.copyResize(decodedImage, width: 512);
    final jpegData = _image.encodeJpg(resizedImage);
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final bn = path.basename(imageFile.path);
    final file = File('$tempPath/resized_$bn')..writeAsBytesSync(jpegData);

    // https://firebasestorage.googleapis.com/v0/b/suztomo-hitomemo.appspot.com/o/t1gVCkBrgMU9LjFRnrtu1FFjlir1%2FYagiCfrKMGTwcxq3l21V.jpg?alt=media&token=3b17cf0d-e6ba-4543-890a-2f5a4e363547
    final gcsPath = await _uploadImage(context, file);
    await file.delete();

    final person = widget.notifier.value;
    widget.notifier.value = person.copyWith(pictureGcsPath: gcsPath);
  }

  Future<void> _iconSelection(BuildContext context) async {
    final pictureGcsUrl = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarIconSelection(),
    );
    if (pictureGcsUrl != null) {
      final person = widget.notifier.value;
      widget.notifier.value = person.copyWith(pictureGcsPath: pictureGcsUrl);
    }
  }

  Future<void> onPersonFaceIconPressed(BuildContext context) async {
    final source = await showModalBottomSheet<AvatarSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarSourceSelection(),
    );

    if (source == AvatarSource.photoLibrary) {
      return _onPhotoIconPressed(context);
    } else if (source == AvatarSource.icon) {
      return _iconSelection(context);
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
      onTap: () => onPersonFaceIconPressed(context),
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
