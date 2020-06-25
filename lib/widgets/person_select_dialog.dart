import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/person.dart';
import 'package:hitomemo/person_model.dart';
import 'package:hitomemo/widgets/person_circle_avatar.dart';
import 'package:provider/provider.dart';

import 'person_select_dialog.i18n.dart';

/// Selects a person. AlreadySelectedIds are person IDs to gray out.
class PersonSelectDialog extends StatefulWidget {
  const PersonSelectDialog(this.alreadySelectedIds, {this.title});

  final Set<String> alreadySelectedIds;

  final String title;

  @override
  _PersonSelectDialogState createState() =>
      _PersonSelectDialogState(alreadySelectedIds);
}

class _PersonSelectDialogState extends State<PersonSelectDialog> {
  _PersonSelectDialogState(this.alreadySelectedIds);
  final ValueNotifier<String> personIdNotifier = ValueNotifier(null);
  final Set<String> alreadySelectedIds;

  @override
  void initState() {
    super.initState();

    personIdNotifier.addListener(() {
      Navigator.of(context).pop(personIdNotifier.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        title: Text(widget.title ?? 'Select Person'.i18n),
        content: _PersonSelectionForm(personIdNotifier, alreadySelectedIds),
        actions: [
          MaterialButton(
              elevation: 5,
              child: Text('Cancel'.i18n),
              onPressed: () =>
                  Navigator.of(context).pop(personIdNotifier.value))
        ]);
  }
}

class _PersonSelectionForm extends StatefulWidget {
  const _PersonSelectionForm(this.personIdNotifier, this.alreadySelectedIds);
  final ValueNotifier<String> personIdNotifier;
  final Set<String> alreadySelectedIds;

  @override
  State<StatefulWidget> createState() {
    return _PersonSelectionFormState(personIdNotifier);
  }
}

class _PersonSelectionFormState extends State<_PersonSelectionForm> {
  _PersonSelectionFormState(this.personIdNotifier);

  ValueNotifier<String> personIdNotifier;

  TextEditingController textEditingController = TextEditingController();

  List<Person> allPersons = [];
  List<Person> visiblePersons = [];
  PersonsModel personsModel;

  @override
  void initState() {
    super.initState();
    personsModel = Provider.of<PersonsModel>(context, listen: false);
    visiblePersons = allPersons = personsModel.persons;
    textEditingController.addListener(() {
      final input = textEditingController.text;

      setState(() {
        visiblePersons = personsModel.searchByText(input);
      });
    });
  }

  List<Widget> personNameList(List<Person> persons) {
    final alreadySelected = widget.alreadySelectedIds;
    final recentUpdates = [...persons]
      ..removeWhere((p) => alreadySelected.contains(p.id))
      ..sort((Person a, Person b) =>
          b.updated.millisecondsSinceEpoch - a.updated.millisecondsSinceEpoch);

    final first3RecentUpdates =
        recentUpdates.sublist(0, min(recentUpdates.length, 3));

    return [
      ...first3RecentUpdates,
      ...persons.where((p) => !first3RecentUpdates.contains(p))
    ].map((person) {
      final active = !alreadySelected.contains(person.id);
      final tailing = active
          ? const Icon(Icons.add, color: Colors.green)
          : const Icon(
              Icons.add,
              color: Colors.black26,
            );
      return FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PersonCircleAvatar(person, radius: 15,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(person.name),
              ),
            ),
            tailing
          ],
        ),
        onPressed: active
            ? () {
                // This should close the dialog
                personIdNotifier.value = person.id;
              }
            : null,
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    // The MediaQueries avoid rendering bug
    // https://github.com/flutter/flutter/issues/19613#issuecomment-432085668
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(hintText: 'Search')),
          ),
          Expanded(
            child: ListView(
              children: personNameList(visiblePersons),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
