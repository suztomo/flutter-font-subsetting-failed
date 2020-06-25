import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'screen_edit_note_tag_section.dart';

void main() {
  runApp(HitomemoApp());
}

class HitomemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        child: MaterialApp(
            home: I18n(child: EditNoteTagSection())),
      );
  }
}
