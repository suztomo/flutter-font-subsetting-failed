import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitomemo/note.dart';
import 'package:hitomemo/note_tags_model.dart';
import 'package:hitomemo/person.dart';
import 'package:hitomemo/tag_chip.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'note_list_item.i18n.dart';
import 'note_list_item_photo_section.dart';
import 'person_tag_section.dart';
import 'screen_edit_note.dart';

class NoteListItem extends StatelessWidget {
  NoteListItem(this._person, Note note)
      : _originalNote = note,
        _noteNotifier = ValueNotifier<Note>(note);

  final Person _person;
  final Note _originalNote;
  // OpenContainer seems to call openBuilder parameter multiple
  // times, resulting in calling EditNoteRoute 2 times. When
  // ValueNotifier was created in EditNoteRoute, it caused duplicate
  // notifiers which caused its "hasChanged" method not working.
  final ValueNotifier<Note> _noteNotifier;

  static final DateFormat _dateFormatter =
      DateFormat.MMMd(I18n.locale.languageCode);

  Widget _leadingIcon(DateTime noteDate) {
    final eventIcon = Icon(
      Icons.event,
    );
    if (noteDate == null) {
      return eventIcon;
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            eventIcon,
            Text(_dateFormatter.format(_noteNotifier.value.date))
          ],
        ),
      );
    }
  }

  Widget _tagSection(BuildContext context, Note note) {
    final tagsModel = Provider.of<NoteTagRepository>(context, listen: false);

    final noteChips = <Widget>[];

    for (final tagId in note.tagIds) {
      final tag = tagsModel.get(tagId);
      if (tag == null) {
        // the tag has been removed
        continue;
      }
      noteChips.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: NoteTagChip(
          tag,
        ),
      ));
    }

    return Wrap(
      spacing: 5,
      children: noteChips,
    );
  }

  Widget _listTile(BuildContext context, VoidCallback openContainerCallback) {
    // This used to use ListTile, but it's inflexibility of layout (
    // padding/margin) made me to use Row.
    final note = _noteNotifier.value;
    final tagPersonIds = note.tagPersonIds.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _leadingIcon(note.date),
        const SizedBox(width: 8),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(note.content),
              _tagSection(context, note),
              tagPersonIds.isNotEmpty
                  ? PersonTagSection(tagPersonIds)
                  : SizedBox(
                      height: note.pictureUrls.isNotEmpty ? 8 : 0,
                    ),
              NotePhotoSection(note.pictureUrls),
            ],
          ),
        )),
        IconButton(
          icon: const Icon(
            Icons.edit,
          ),
          onPressed: () {
            // delete?
            openContainerCallback();
          },
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesNotifier =
        Provider.of<ValueNotifier<List<Note>>>(context, listen: false);
    return OpenContainer(
      // DevTool WidgetInspector told that this is not transparent
      closedColor: Colors.transparent, // What?? Not default??
      transitionType: ContainerTransitionType.fade,
      openBuilder: (_context, VoidCallback closeContainer) {
        void closeCallback(Note note) {
          closeContainer();

          Timer(const Duration(milliseconds: 500), () {
            if (note != null) {
              final updatedNotes = notesNotifier.value
                  .map((n) => (n.id == note.id) ? note : n)
                  .toList();

              // It seems the note list is not getting updated for this value.
              notesNotifier.value = updatedNotes;
            } else {
              // Note is deleted
              final notes = [...notesNotifier.value]
                ..retainWhere((n) => n.id != _originalNote.id);
              notesNotifier.value = notes;

              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Deleted'.i18n)));
            }
          });
        }

        return EditNoteRoute(_person, _noteNotifier, closeCallback);
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0,
      closedBuilder: _listTile,
    );
  }
}
