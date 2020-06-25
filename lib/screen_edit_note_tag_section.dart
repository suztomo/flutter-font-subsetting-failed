import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note.dart';
import 'note_tags_model.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_edit_note.i18n.dart';
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
  NoteTagRepository tagsModel;
  PersonsModel personsModel;

  @override
  void initState() {
    super.initState();
    tagsModel = Provider.of<NoteTagRepository>(context, listen: false);
    personsModel = Provider.of<PersonsModel>(context, listen: false);
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

  Future<void> _personTagAddTapped() async {
    final note = _noteNotifier.value;
  }

  static const Icon _addTagIcon = Icon(CommunityMaterialIcons.pound_box);
  Container noTagChip() => Container();

  static const Icon _addPersonIcon = Icon(Icons.person_add);
  Container noPersonChip() => Container(
          child: ChoiceChip(
        avatar: _addPersonIcon,
        label: Text('Tag person'.i18n),
        onSelected: (selected) {
          _personTagAddTapped();
        },
        selected: false,
      ));

  Widget _selectedNoteTags(BuildContext context) {
    final tagChips = tagsModel.tags
        .where((tag) => _noteNotifier.value.tagIds.contains(tag.id))
        .map((tag) {
      return Container(
          child: NoteTagChip(
        tag,
        onSelected: (selected) {
          _tagEditTapped();
        },
        selected: true,
      ));
    }).toList();

    if (tagChips.isEmpty) {
      tagChips.add(noTagChip());
    }

    return Wrap(
        spacing: 10, alignment: WrapAlignment.center, children: tagChips);
  }

  Widget _selectedPersonTags(BuildContext context) {
    final note = _noteNotifier.value;
    final selectedPersonTagIds = note.tagPersonIds;
    final tagChips = selectedPersonTagIds
        .map(personsModel.get)
        .where((p) => p != null)
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
        child: IconButton(icon: _addPersonIcon, onPressed: _personTagAddTapped),
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
                noPersonChip(),
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
        children: <Widget>[
          _selectedNoteTags(context),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _selectedPersonTags(context),
        ],
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
  NoteTagRepository tagsModel;

  bool addingNewTag = false;

  TextEditingController _textEditingController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    tagsModel = Provider.of<NoteTagRepository>(context, listen: false);
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  List<Widget> tagChoiceChipList(ValueNotifier<Set<String>> tagNotifier) {
    final tags = tagNotifier.value;
    return tagsModel.tags.map((tag) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: NoteTagChip(
          tag,
          selectable: true,
          selected: tags.contains(tag.id),
          onSelected: (selected) async {
            final updatedTags = {...tags}; // copy
            if (selected) {
              updatedTags.add(tag.id);
            } else {
              updatedTags.remove(tag.id);
            }
            tagNotifier.value = updatedTags;
          },
        ),
      );
    }).toList();
  }

  Future<void> onCreatePressed() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final scaffold = Scaffold.of(widget.scaffoldContext)
      ..showSnackBar(SnackBar(content: Text('Saving the tag'.i18n)));

    final tagName = _textEditingController.text;
    final tag = NTag.create(tagName);
    await tagsModel.save(tag);

    _textEditingController.clear();

    final tagsNotifier =
        Provider.of<ValueNotifier<Set<String>>>(context, listen: false);

    tagsNotifier.value = {...tagsNotifier.value, tag.id};

    setState(() {
      addingNewTag = false;
    });

    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Saved %s'.i18n.fill([tag.name]))));

  }

  String validateNewTagName(String newTagName) {
    final tagNames = tagsModel.tags.map((t) => t.name).toSet();
    if (newTagName.length <= 1) {
      return 'Tag name too short'.i18n;
    }
    if (tagNames.contains(newTagName)) {
      // If _tag is null, it's a new tag
      return 'Duplicate tag name'.i18n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      title: Stack(
        children: [
          Text(
            'Select Tags'.i18n,
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
      content: SingleChildScrollView(
        child: Consumer<ValueNotifier<Set<String>>>(
            builder: (_, notifier, __) => Column(
                  children: [
                    addingNewTag
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Form(
                              key: _formKey,
                              child: Row(children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _textEditingController,
                                    validator: validateNewTagName,
                                    decoration: InputDecoration(
                                      icon: const Icon(
                                          CommunityMaterialIcons.pound_box),
                                      labelText: 'New Tag'.i18n,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: RaisedButton(
                                    visualDensity: VisualDensity.compact,
                                    child: Text('Create'.i18n),
                                    onPressed: onCreatePressed,
                                  ),
                                )
                              ]),
                            ),
                          )
                        : Container(),
                    Wrap(
                      children: tagChoiceChipList(notifier),
                    ),
                  ],
                )),
      ),
      actions: [
        MaterialButton(
            elevation: 5,
            child: Text('Close'.i18n),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
