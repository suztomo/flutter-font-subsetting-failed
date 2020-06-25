import 'dart:collection';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawer.dart';
import 'gesture_detector_app_bar.dart';
import 'note_tags_model.dart';
import 'screen_note_tags.i18n.dart';
import 'screen_show_group_persons.dart';
import 'screen_show_tag_notes.dart';
import 'tag.dart';
import 'tag_chip.dart';
import 'widgets/menu_button.dart';
import 'widgets/tutorial.dart';

class NoteTagPage extends StatelessWidget {
  static const String routeName = '/tags';
  final ValueNotifier<bool> editingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: editingNotifier,
        builder: (context, editing, child) => Scaffold(
              drawer: MenuDrawer(),
              appBar: GestureDetectorAppBar(
                  title: Text('Tags'.i18n),
                  onTap: () {
                    editingNotifier.value = false;
                  },
                  leading: const NotifyingMenuButton(routeName)),
              body: WithBottomTutorial.noteTagsPage(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Center(
                            child: Text('Organize your memory by tags'.i18n)),
                        _CreateNewTagForm(editingNotifier),
                        Consumer<NoteTagRepository>(
                          builder: (_context, tagsModel, child) =>
                              Expanded(child: _TagListView(tagsModel.tags)),
                        ),
                      ],
                    ),
                    onTap: () {
                      editingNotifier.value = false;
                    },
                  ),
                ),
              ),
              floatingActionButton: editing
                  ? null
                  : WithTutorialDot(tutorialKeyTagAddButton,
                      child: FloatingActionButton(
                        child: const Icon(Icons.add),
                        onPressed: () async {
                          editingNotifier.value = true;
                        },
                      )),
            ));
  }
}

class _CreateNewTagForm extends StatelessWidget {
  const _CreateNewTagForm(this.editingNotifier);
  final ValueNotifier<bool> editingNotifier;

  @override
  Widget build(BuildContext context) {
    if (editingNotifier.value) {
      return _TagEditForm(
          null, // No existing tag
          () => editingNotifier.value = false);
    }
    return Container();
  }
}

class _TagListView extends StatelessWidget {
  const _TagListView(this._tags);
  final UnmodifiableListView<NTag> _tags;

  @override
  Widget build(BuildContext context) {
    final elements = _tags.map((tag) {
      return _TagTile(tag);
    }).toList();

    return ListView(
      children: [
        ...ListTile.divideTiles(context: context, tiles: elements).toList(),

        Consumer<ValueNotifier<TutorialState>>(
            builder: (context, tutorialStateNotifier, _) {
          if (!(tutorialStateNotifier.value is Off)) {
            return Container();
          }
          return Center(
              child: FlatButton(
            child: Text('Start tutorial on tags'.i18n,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                )),
            onPressed: () {
              final notifier = Provider.of<ValueNotifier<TutorialState>>(
                  context,
                  listen: false);
              // ignore: cascade_invocations
              notifier.value =
                  TutorialState.onTagsTutorial(TagsTutorialState());
            },
          ));
        }),

        const SizedBox(height: 250) // Scrollable when tutorial is visible
      ],
    );
  }
}

class _TagTile extends StatefulWidget {
  const _TagTile(this._tag);
  final NTag _tag;

  @override
  State<StatefulWidget> createState() {
    return _TagTileState();
  }
}

class _TagTileState extends State<_TagTile> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Row(
        children: [
          Expanded(
            child: _TagEditForm(widget._tag, () {
              // This _TagTileState is not responsible to refresh the tag name
              // the parent has Consumer for NTagsModel
              setState(() {
                _editing = false;
              });
            }),
          ),
        ],
      );
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: NoteTagChip(widget._tag, onSelected: (selected) async {
            await Navigator.push<EditTagResult>(
              context,
              MaterialPageRoute<EditTagResult>(
                  settings: const RouteSettings(
                      name: ShowGroupPersonsRoute.routeName),
                  builder: (context) => ShowTagNotesRoute(widget._tag)),
            );
          }),
        ),
        Padding(
          child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _editing = true;
              });
            },
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        )
      ]);
    }
  }
}

// Tag name, Color, Icon,
class _TagEditForm extends StatefulWidget {
  const _TagEditForm(this._tag, this._callbackOnDone);
  // Null if this is to create a new one
  final NTag _tag;
  final VoidCallback _callbackOnDone;

  @override
  State<StatefulWidget> createState() {
    return _TagEditFormState();
  }
}

class _TagEditFormState extends State<_TagEditForm> {
  _TagEditFormState();
  NTag _tag;
  NoteTagRepository _tagsModel;
  final _formKey = GlobalKey<FormState>();
  bool _trashButtonOn = false;

  final TextEditingController _nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tag = widget._tag;
    final initialName = _tag?.name;
    if (initialName != null) {
      _nameController.text = initialName;
    }
    _tagsModel = Provider.of<NoteTagRepository>(context, listen: false);

    _nameController.addListener(() {
      if (_trashButtonOn != _nameController.text.isEmpty) {
        setState(() {
          _trashButtonOn = _nameController.text.isEmpty;
        });
      }
    });
  }

  Future<void> _deleteTapped() async {
    if (_tag == null) {
      return;
    }
    final scaffold = Scaffold.of(context)
      ..showSnackBar(
          SnackBar(content: Text('Deleting tag: '.i18n + _tag.name)));
    await _tagsModel.delete(_tag);
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted'.i18n)));

    if (widget._callbackOnDone != null) {
      widget._callbackOnDone();
    }
  }

  Future<void> _doneTapped() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    final scaffold = Scaffold.of(context)
      ..showSnackBar(SnackBar(content: Text('Saving the tag'.i18n)));
    if (_tag == null) {
      _tag = NTag.create(_nameController.text);
      await _tagsModel.save(_tag);
    } else {
      final tag = _tag.copyWith(name: _nameController.text);
      // This should notify the list
      await _tagsModel.update(tag);
    }

    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Saved'.i18n)));

    Tutorial.recordAddingRecentlySavedTag(context, _tag.id);

    if (widget._callbackOnDone != null) {
      widget._callbackOnDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    String hintText;
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: false);
    tutorialNotifier.value.maybeWhen(
        orElse: () {},
        onTagsTutorial: (state) {
          if (state.recentTagIds.isEmpty) {
            hintText = 'Gifts Received'.i18n;
          }
        });

    final theme = Theme.of(context);
    return Row(
      children: [
        Form(
          key: _formKey,
          child: Expanded(
            child: TextFormField(
              controller: _nameController,
              validator: (value) {
                final tagNames = _tagsModel.tags.map((t) => t.name).toSet();
                if (value.length <= 1) {
                  return 'Tag name too short'.i18n;
                }
                if (_tag == null && tagNames.contains(value)) {
                  // If _tag is null, it's a new tag
                  return 'Duplicate tag name'.i18n;
                }
                return null;
              },
              decoration: InputDecoration(
                icon: const Icon(CommunityMaterialIcons.pound_box),
                labelText: 'Tag Name'.i18n,
                hintText: hintText,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: (_trashButtonOn && _tag != null)
              ? RaisedButton(
                  key: const Key('form_delete'),
                  child: Text('Delete'.i18n),
                  onPressed: _deleteTapped,
                  textColor: theme.colorScheme.onError,
                  color: theme.errorColor,
                )
              : RaisedButton(
                  key: const Key('form_submit'),
                  child: Text('Save'.i18n),
                  onPressed: _doneTapped,
                  color: theme.accentColor,
                  textColor: theme.colorScheme.onPrimary,
                ),
        )
      ],
    );
  }
}
