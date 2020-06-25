import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as _image;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../note.dart';
import '../person.dart';
import '../screen_edit_note.i18n.dart';

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

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add_photo_alternate),
    );
  }
}
