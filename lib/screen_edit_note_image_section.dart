import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitomemo/widgets/note_add_image_button.dart';
import 'package:provider/provider.dart';

import 'note.dart';
import 'person.dart';
import 'widgets/note_edit_photo_section.dart';

class EditNoteImageSection extends StatefulWidget {
  const EditNoteImageSection(this.person);

  final Person person;

  @override
  State<StatefulWidget> createState() {
    return _EditNoteImageSectionState();
  }
}

class _EditNoteImageSectionState extends State<EditNoteImageSection> {
  _EditNoteImageSectionState();
  ValueNotifier<Note> _noteNotifier;

  final ScrollController photoScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _noteNotifier = Provider.of<ValueNotifier<Note>>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      NoteEditPhotoSection(_noteNotifier, photoScrollController),
      Center(
          child: NoteAddImageButton(
        widget.person,
        onPhotoUploaded: () {
          Timer(
              const Duration(milliseconds: 1000),
              () => photoScrollController.animateTo(
                    photoScrollController.position.maxScrollExtent,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  ));
        },
      ))
    ]);
  }
}
