import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hitomemo/gesture_detector_app_bar.dart';
import 'package:hitomemo/person_tags_model.dart';
import 'package:provider/provider.dart';
import 'drawer.dart';
import 'person_tags_model.dart';
import 'screen_groups.i18n.dart';
import 'screen_show_group_persons.dart';
import 'tag.dart';
import 'tag_chip.dart';
import 'widgets/menu_button.dart';

class GroupPage extends StatelessWidget {
  static const String routeName = '/groups';

  final ValueNotifier<bool> editingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: editingNotifier,
      builder: (context, editing, child) => Scaffold(
        drawer: MenuDrawer(),
        appBar: GestureDetectorAppBar(
            title: Text('Groups'.i18n),
            onTap: () {
              editingNotifier.value = false;
            },
            leading: const NotifyingMenuButton(routeName)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            child: Column(
              children: [
                Center(
                    child: Text('Organize your family/friends by groups'.i18n)),
                const SizedBox(height: 8),
                _CreateNewTagForm(editingNotifier),
                Consumer<TagsModel>(
                  builder: (_context, tagsModel, child) =>
                      Expanded(child: _GroupListView(tagsModel.tags)),
                )
              ],
            ),
            onTap: () {
              editingNotifier.value = false;
            },
          ),
        ),
        floatingActionButton: editing
            ? null
            : FloatingActionButton(
                key: const Key('add_new_group'),
                child: const Icon(Icons.add),
                onPressed: () async {
                  editingNotifier.value = true;
                },
              ),
      ),
    );
  }
}

class _CreateNewTagForm extends StatelessWidget {
  const _CreateNewTagForm(this.editingNotifier);

  final ValueNotifier<bool> editingNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: editingNotifier,
        builder: (context, editing, child) => editing
            ? _GroupEditForm(
                null, // No existing tag
                () => editingNotifier.value = false)
            : Container());
  }
}

class _GroupListView extends StatelessWidget {
  const _GroupListView(this._tags);
  final UnmodifiableListView<PTag> _tags;

  @override
  Widget build(BuildContext context) {
    final elements = _tags.map((tag) {
      return _GroupTile(tag);
    }).toList();

    return ListView(
      children:
          ListTile.divideTiles(context: context, tiles: elements).toList(),
    );
  }
}

class _GroupTile extends StatefulWidget {
  const _GroupTile(this._tag);
  final PTag _tag;

  @override
  State<StatefulWidget> createState() {
    return _GroupTileState();
  }
}

class _GroupTileState extends State<_GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: GroupChip(widget._tag, onSelected: (selected) async {
          await Navigator.push<EditTagResult>(
            context,
            MaterialPageRoute<EditTagResult>(
                settings:
                    const RouteSettings(name: ShowGroupPersonsRoute.routeName),
                builder: (context) => ShowGroupPersonsRoute(widget._tag)),
          );
        }));
  }
}

// Tag name, Color, Icon,
class _GroupEditForm extends StatefulWidget {
  const _GroupEditForm(this._tag, this._callbackOnDone);
  // Null if this is to create a new one
  final PTag _tag;
  final VoidCallback _callbackOnDone;

  @override
  State<StatefulWidget> createState() {
    return _GroupEditFormState();
  }
}

class _GroupEditFormState extends State<_GroupEditForm> {
  _GroupEditFormState();
  PTag _tag;
  TagsModel _tagsModel;
  Set<String> _tagNames = {};
  final _formKey = GlobalKey<FormState>();
  bool _trashButtonOn = false;
  bool inProcessing = false;

  final TextEditingController _nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tag = widget._tag;
    final initialName = _tag?.name;
    if (initialName == null) {
      _nameController.text = '';
    } else {
      _nameController.text = initialName;
    }
    _tagsModel = Provider.of<TagsModel>(context, listen: false);
    _tagNames = _tagsModel.tags.map((tag) => tag.name).toSet();

    _nameController.addListener(() {
      if (_trashButtonOn != _nameController.text.isEmpty) {
        setState(() {
          _trashButtonOn = _nameController.text.isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _doneTapped() async {
    setState(() {
      inProcessing = true;
    });
    if (!_formKey.currentState.validate()) {
      return;
    }
    final scaffold = Scaffold.of(context)
      ..showSnackBar(SnackBar(content: Text('Saving group'.i18n)));

    if (_tag == null) {
      _tag = PTag.create(_nameController.text);
      await _tagsModel.save(_tag);
    } else {
      // Existing tag
      if (_nameController.text.isEmpty) {
        await _tagsModel.delete(_tag);
      } else {
        final tag = _tag.copyWith(name: _nameController.text);
        // This should notify the list
        await _tagsModel.update(tag);
      }
    }
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text('Saved %s'.i18n.fill([_tag.name]))));
    if (widget._callbackOnDone != null) {
      widget._callbackOnDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value.length <= 1) {
                  return 'Group name too short'.i18n;
                }
                if (_tag == null && _tagNames.contains(value)) {
                  // If _tag is null, it's a new tag
                  return 'Duplicate group name'.i18n;
                }
                return null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.group),
                labelText: 'Group Name'.i18n,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                key: const Key('form_submit'),
                child: Text('Add'.i18n),
                onPressed: inProcessing ? null : _doneTapped,
                color: theme.accentColor,
                textColor: Theme.of(context).colorScheme.onPrimary,
              )
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
