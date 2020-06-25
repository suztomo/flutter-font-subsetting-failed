import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/name.dart';
import 'package:image/image.dart' as _image;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../login_user_model.dart';
import '../note.dart';
import '../person.dart';

class NoteAddImageButton extends StatefulWidget {
  const NoteAddImageButton(this.person, {this.onPhotoUploaded});

  final Person person;

  final VoidCallback onPhotoUploaded;

  @override
  State<StatefulWidget> createState() {
    return _ButtonState();
  }
}

class _ButtonState extends State<NoteAddImageButton> {
  bool uploadingPhoto = false;
  ValueNotifier<Note> noteNotifier;

//  Set<Asset> selectedImages = {};

  // Mapping when we remove a picture
  Map<String, Asset> gcsUrlToAsset = {};

  @override
  void initState() {
    super.initState();
    noteNotifier = Provider.of<ValueNotifier<Note>>(context, listen: false);
  }

  /// Returns path of Google Cloud Storage image
  Future<String> _uploadImage(BuildContext context, File file) async {
    final person = widget.person;
    final loginUserModel = Provider.of<LoginUserModel>(context, listen: false);
    // This path should work even when Note does not have ID assigned yet.
    final personPath = '${loginUserModel.user.uid}/${person.id}';
    // final extension = file.path.split('.').last;
    final secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch / 1000;
//    final path = '$personPath.jpg';
    final path = '$personPath/$secondsSinceEpoch.jpg';
    final firebaseStorage = FirebaseStorage();
    final storageReference = firebaseStorage.ref().child(path);
    final uploadTask = storageReference.putFile(file);

    final streamSubscription = uploadTask.events.listen((event) {
      // https://pub.dev/packages/firebase_storage
      print('EVENT ${event.type}');
    });

    final taskSnapshot = await uploadTask.onComplete;
    await streamSubscription.cancel();
    if (taskSnapshot.error != null) {
      return null;
    } else {
      final bucketName = await storageReference.getBucket();
      return 'gs://$bucketName/${storageReference.path}';
    }
  }

  Future<void> _onPhotoIconPressed(BuildContext context) async {
    final selectedImages = <Asset>[];
    final existingGcsUrl = <String>[];
    final note = noteNotifier.value;
    for (final gcsUrl in note.pictureUrls) {
      if (gcsUrlToAsset.containsKey(gcsUrl)) {
        selectedImages.add(gcsUrlToAsset[gcsUrl]);
      } else {
        existingGcsUrl.add(gcsUrl);
      }
    }

    try {
      final resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: selectedImages,
        cupertinoOptions: const CupertinoOptions(takePhotoIcon: 'chat'),
        materialOptions: const MaterialOptions(
          actionBarColor: '#abcdef',
          actionBarTitle: '$appNameEn',
          allViewTitle: 'All Photos',
          useDetailsView: false,
          selectCircleStrokeColor: '#000000',
        ),
      );

      setState(() {
        uploadingPhoto = true;
      });

      final assetIdentifiers = selectedImages.map((e) => e.identifier).toSet();
      final picturesToUpload = resultList
          .where((element) => !assetIdentifiers.contains(element.identifier))
          .toSet();

      var count = 1;
      for (final asset in picturesToUpload) {
        count++;
        final byteData = await asset.getByteData();
        final uInt8List = byteData.buffer.asUint8List();
        final decodedImage = _image.decodeImage(uInt8List);
        // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
        // Use 8x8 grid
        // https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/
        final resizedImage = decodedImage.width > 1024
            ? _image.copyResize(decodedImage, width: 1024)
            : decodedImage;
        final jpegData = _image.encodeJpg(resizedImage);
        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;
        final bn = path.basename(asset.name);
        final file = File('$tempPath/resized_$bn')..writeAsBytesSync(jpegData);
        // https://firebasestorage.googleapis.com/v0/b/suztomo-hitomemo.appspot.com/o/t1gVCkBrgMU9LjFRnrtu1FFjlir1%2FYagiCfrKMGTwcxq3l21V.jpg?alt=media&token=3b17cf0d-e6ba-4543-890a-2f5a4e363547
        final gcsPath = await _uploadImage(context, file);
        await file.delete();
        if (!mounted) {
          return;
        }
        setState(() {
          final note = noteNotifier.value;
          final existingImages = note.pictureUrls;
          noteNotifier.value =
              note.copyWith(pictureUrls: [...existingImages, gcsPath]);
        });

        gcsUrlToAsset[gcsPath] = asset;
      }

    } on NoImagesSelectedException catch (_) {
      return;
    } catch (err) {
      print('$err');
      rethrow;
    } finally {
      setState(() {
        uploadingPhoto = false;
      });
    }
    if (widget.onPhotoUploaded != null) {
      widget.onPhotoUploaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add_photo_alternate),
      onPressed: uploadingPhoto ? null : () => _onPhotoIconPressed(context),
    );
  }
}
