import 'package:flutter/material.dart';
import 'package:hitomemo/person_tags_model.dart';
import 'package:hitomemo/widgets/person_circle_avatar.dart';
import 'package:provider/provider.dart';

import 'edit_back_button.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_groups.i18n.dart';
import 'screen_show_person.dart';
import 'tag.dart';
import 'widgets/person_select_dialog.dart';

class ShowGroupPersonsRoute extends StatefulWidget {
  const ShowGroupPersonsRoute(this._group);

  static const String routeName = 'tag/persons';

  final PTag _group;

  @override
  State<StatefulWidget> createState() {
    return ShowGroupPersonsState(_group);
  }
}

class ShowGroupPersonsState extends State<ShowGroupPersonsRoute> {
  ShowGroupPersonsState(PTag group) : groupNotifier = ValueNotifier(group);

  final ValueNotifier<PTag> groupNotifier;

  bool editing = false;

  Set<Person> personsToRemoveFromTag = {};

  TagsModel tagsModel;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editing = false;
    personsToRemoveFromTag = {};
    tagsModel = Provider.of<TagsModel>(context, listen: false);
    _nameController
      ..text = groupNotifier.value.name
      ..addListener(() {
        groupNotifier.value =
            groupNotifier.value.copyWith(name: _nameController.text);
      });
  }

  List<Widget> personTiles(BuildContext context, List<Person> persons) {
    if (persons.isEmpty) {
      return [
        Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
                'No person in "%s" group'.i18n.fill([groupNotifier.value.name]),
                style: Theme.of(context).textTheme.caption))
      ];
    }
    final items = persons.map((person) {
      final isSelected = !personsToRemoveFromTag.contains(person);

      return ListTile(
          leading:  PersonCircleAvatar(person, radius: 24),
          title: Text(
            person.name,
          ),
          onTap: () {
            // delete?
            Navigator.push<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  settings:
                      const RouteSettings(name: ShowPersonRoute.routeName),
                  builder: (context) => ShowPersonRoute(person)),
            );
          },
          trailing: editing
              ? Switch(
                  value: isSelected,
                  onChanged: (bool selected) {
                    setState(() {
                      if (selected) {
                        personsToRemoveFromTag.remove(person);
                      } else {
                        personsToRemoveFromTag.add(person);
                      }
                    });
                  })
              : null);
    });

    return ListTile.divideTiles(
      context: context,
      tiles: items,
    ).toList();
  }

  List<Person> _filterPersonByTag(
      List<Person> persons, List<String> personIds) {
    final ids = Set<String>.from(personIds);
    return persons.where((p) => ids.contains(p.id)).toList();
  }

  Widget _settingsButton() {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: editing ? Theme.of(context).disabledColor : null,
      ),
      onPressed: () async {
        setState(() {
          editing = !editing;
        });
      },
    );
  }

  Future<void> _onTagDeleteTapped(BuildContext scaffoldContext) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        // return object of type Dialog
        return AlertDialog(
          title: Text('Delete Group %s?'.i18n.fill([groupNotifier.value.name])),
          actions: <Widget>[
            RaisedButton(
              key: const Key('confirm-delete'),
              child: const Text('Delete'),
              textColor: theme.colorScheme.onError,
              color: theme.colorScheme.error,
              onPressed: () async {
                Navigator.of(dialogContext).pop(true);
              },
            ),
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (confirmed) {
      final tag = groupNotifier.value;

      final scaffold = Scaffold.of(scaffoldContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text('Deleting %s'.i18n.fill([tag.name]))));

      await tagsModel.removePersonsFromTag(personsToRemoveFromTag, tag);
      await tagsModel.delete(tag);

      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Deleted %s'.i18n)));

      Navigator.pop(context, EditTagResult.deleted(tag));
    }
  }

  Future<void> _onSaveButtonTapped(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final scaffold = Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Saving group'.i18n)));

    // This loop could be optimized to issue fewer queries
    var tag = groupNotifier.value;
    // update name
    tag = await tagsModel.update(tag);
    await tagsModel.removePersonsFromTag(personsToRemoveFromTag, tag);
    groupNotifier.value = tag;
    setState(() {
      editing = false;
    });
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Saved %s'.i18n.fill([tag.name]))));
  }

  List<Widget> _editingButtons(BuildContext context) {
    final theme = Theme.of(context);
    final tag = groupNotifier.value;
    final personIds = tagsModel.getPersonIds(tag).toSet();
    final isEveryoneRemoved = personIds
        .difference(personsToRemoveFromTag.map((p) => p.id).toSet())
        .isEmpty;
    final deleteButton = IconButton(
      color: theme.errorColor,
      icon: const Icon(Icons.delete),
      tooltip: 'Delete this group'.i18n,
      onPressed: isEveryoneRemoved ? () => _onTagDeleteTapped(context) : null,
    );

    final saveButton = RaisedButton(
      color: theme.accentColor,
      child: Text('Save'.i18n,),
      textColor: theme.colorScheme.onSecondary,
      onPressed: () => _onSaveButtonTapped(context),
    );
    if (editing) {
      return [deleteButton, saveButton];
    } else {
      return [];
    }
  }

  /// Returns true if (1) not editing and (2) user confirms ok to discard
  /// change.
  Future<bool> _onWillPop() async {
    if (!editing) {
      return true;
    }
    return showGoBackDialog(context);
  }

  Widget _tagNameForm(BuildContext context) {
    return Form(
      key: _formKey,
      onWillPop: _onWillPop,
      child: TextFormField(
        controller: _nameController,
        validator: (value) {
          if (value.length <= 1) {
            return 'Group name too short'.i18n;
          }
          final originalTag = groupNotifier.value;
          final existingNames = tagsModel.tags
              .where((t) => t.id != originalTag.id)
              .map((t) => t.name)
              .toSet();
          if (existingNames.contains(value)) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final personsModel = Provider.of<PersonsModel>(context, listen: false);
    final persons = personsModel.persons;

    return ChangeNotifierProvider<ValueNotifier<PTag>>.value(
      value: groupNotifier,
      child: Consumer<ValueNotifier<PTag>>(
          builder: (_, ValueNotifier<PTag> notifier, __) => Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: AppBar(
                  title: Text(groupNotifier.value.name),
                  actions: [_settingsButton()],
                  leading: editing ? Container() : null,
                ),
                body: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<TagsModel>(
                            builder: (context, tagsModel, _) => Column(
                                  children: [
                                    editing
                                        ? Center(
                                            child: _tagNameForm(context),
                                          )
                                        : Container(),
                                    ...personTiles(
                                        context,
                                        _filterPersonByTag(
                                            persons,
                                            tagsModel
                                                .getPersonIds(notifier.value))),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: _editingButtons(context),
                                    )
                                  ],
                                )))),
                floatingActionButton:
                    AddMemberFloatingActionButton(groupNotifier),
              )),
    );
  }
}

class AddMemberFloatingActionButton extends StatelessWidget {
  const AddMemberFloatingActionButton(this.groupNotifier);
  final ValueNotifier<PTag> groupNotifier;

  @override
  Widget build(BuildContext context) {
    final tagsModel = Provider.of<TagsModel>(context, listen: false);
    final personsModel = Provider.of<PersonsModel>(context, listen: false);
    return FloatingActionButton(
      child: const Icon(Icons.person_add),
      backgroundColor: Theme.of(context).accentColor,
      onPressed: () async {
        final group = groupNotifier.value;
        final selectedPersonId = await showDialog<String>(
            context: context,
            builder: (context) {
              final personIds = tagsModel.getPersonIds(group);
              return PersonSelectDialog(Set.from(personIds));
            });
        if (selectedPersonId == null) {
          return;
        }
        final scaffold = Scaffold.of(context)
          ..showSnackBar(SnackBar(content: Text('Updating group'.i18n)));

        final person = personsModel.get(selectedPersonId);
        await tagsModel.addPersonTag(person, group);

        print('Added $person to $group');
        scaffold
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('Updated %s'.i18n.fill([group.name]))));
      },
    );
  }
}
