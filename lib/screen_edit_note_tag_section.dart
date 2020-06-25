import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note.dart';
import 'person.dart';
import 'tag.dart';
import 'tag_chip.dart';

class EditNoteTagSection extends StatefulWidget {
  const EditNoteTagSection(this.person);

  final Person person;

  @override
  State<StatefulWidget> createState() {
    return _EditNoteTagSectionState();
  }
}

class _EditNoteTagSectionState extends State<EditNoteTagSection> {
  _EditNoteTagSectionState();
  ValueNotifier<Note> _noteNotifier;

  @override
  void initState() {
    super.initState();
    _noteNotifier = Provider.of<ValueNotifier<Note>>(context, listen: false);
  }

  Future<void> _tagEditTapped() async {
    final tags = _noteNotifier.value.tagIds;
    final notifier = ValueNotifier<Set<String>>(tags);
    await showDialog<void>(
        context: context,
        builder: (_) {
          return ChangeNotifierProvider<ValueNotifier<Set<String>>>.value(
            value: notifier,
            child: _TagSelectionDialog(context),
          );
        });
    setState(() {
      _noteNotifier.value =
          _noteNotifier.value.copyWith(tagIds: notifier.value);
    });
  }

  Container noTagChip() => Container();

  static const Icon _addPersonIcon = Icon(Icons.person_add);
  Container noPersonChip() => Container(
          child: ChoiceChip(
        avatar: _addPersonIcon,
        label: Text('Tag person'),
        selected: false,
      ));

  Widget _selectedPersonTags(BuildContext context) {
    final note = _noteNotifier.value;
    final selectedPersonTagIds = note.tagPersonIds;
    final tagChips = []
        .map((person) {
      return Container(
        child: PersonTagChip(
          person,
          onDeleted: () {
            final updatedTagPersonIds = {...selectedPersonTagIds}
              ..remove(person.id);
            setState(() {
              _noteNotifier.value =
                  note.copyWith(tagPersonIds: updatedTagPersonIds);
            });
          },
        ),
      );
    }).toList();

    if (tagChips.isEmpty) {
      tagChips.add(noPersonChip());
    } else {
      tagChips.add(Container(
        child: IconButton(icon: _addPersonIcon, ),
      ));
    }

    return Expanded(
      child: Wrap(
          spacing: 10, alignment: WrapAlignment.center, children: tagChips),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = _noteNotifier.value;
    if (note.tagIds.isEmpty && note.tagPersonIds.isEmpty) {
      return Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [
                noTagChip(),
              ],
            ),
          ],
        ),
      );
    }

    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[],
      )
    ]);
  }
}

class _TagSelectionDialog extends StatefulWidget {
  const _TagSelectionDialog(this.scaffoldContext);
  final BuildContext scaffoldContext;

  @override
  State<StatefulWidget> createState() {
    return _TagSelectionState();
  }
}

class _TagSelectionState extends State<_TagSelectionDialog> {
  bool addingNewTag = false;

  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      title: Stack(
        children: [
          Text(
            'Select Tags',
            style: const TextStyle(fontSize: 22),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
//              visualDensity: VisualDensity.compact,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  addingNewTag ? Icons.remove_circle : Icons.add_circle,
                  color: theme.primaryColor,
                ),
              ),
              onTap: () {
                setState(() {
                  addingNewTag = !addingNewTag;
                });
              },
            ),
          )
        ],
      ),
      content: Column(
        children: [
          Icon(CommunityMaterialIcons.ab_testing)
        ],
      ),
      actions: [
        MaterialButton(
            elevation: 5,
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
