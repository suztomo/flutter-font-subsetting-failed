import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/tag.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../note_list_item_photo_section.dart';
import '../note_tags_model.dart';
import '../person.dart';
import '../person_tag_section.dart';
import '../tag_chip.dart';
import 'person_circle_avatar.dart';

class NoteReplicaTile extends StatelessWidget {
  const NoteReplicaTile(this.person, this.note);

  final Person person;
  final NoteReplica note;

  Widget _tagSection(BuildContext context, NoteReplica note) {
    NTag showingTag;
    final screenShowTagNotes = context.findAncestorWidgetOfExactType<
        ChangeNotifierProvider<ValueNotifier<NTag>>>();
    if (screenShowTagNotes != null) {
      final noteTagNotifier =
          Provider.of<ValueNotifier<NTag>>(context, listen: false);
      showingTag = noteTagNotifier.value;
    }

    final tagsModel = Provider.of<NoteTagRepository>(context, listen: false);

    final noteChips = <Widget>[];

    for (final tagId in note.tagIds) {
      final tag = tagsModel.get(tagId);
      if (tag == null) {
        // the tag has been removed
        continue;
      }
      noteChips.add(NoteTagChip(
        tag,
        // When showing #birthday tag, tapping birthday tag should not show
        // additional screen to show #birthday.
        onSelected: showingTag == tag ? (_) {} : null,
      ));
    }

    return Wrap(
      spacing: 5,
      children: noteChips,
    );
  }

  @override
  Widget build(BuildContext context) {
    const r = 28.0;
    final theme = Theme.of(context);
    final _formatter = DateFormat.yMMMMd(I18n.locale.languageCode);

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    PersonCircleAvatar(person, radius: r),
                    SizedBox(
                        width: r * 2.5,
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FittedBox(
                            child: Text(person.name,
                                style: theme.textTheme.caption.copyWith()),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatter.format(note.date),
                      style: theme.textTheme.caption,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Text(
                        note.content,
                        style: theme.textTheme.bodyText1,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tagSection(context, note),
                        PersonTagSection(
                            note.tagPersonIds.toList(growable: false))
                      ],
                    ),
                    note.pictureUrls.isNotEmpty
                        ? const SizedBox(height: 8)
                        : Container(),
                    NotePhotoSection(note.pictureUrls),
                    const SizedBox(height: 8)
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
