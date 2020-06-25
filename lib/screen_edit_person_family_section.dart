import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'person.dart';
import 'person_model.dart';
import 'screen_edit_person.i18n.dart';
import 'tag_chip.dart';
import 'widgets/person_select_dialog.dart';

class FamilySection extends StatefulWidget {
  // Passing value to screen (route)
  // https://flutter.dev/docs/cookbook/navigation/passing-data#4-navigate-and-pass-data-to-the-detail-screen
  const FamilySection(this._personNotifier, this._familyNotifier);

  // This widget may set familyId to null or something
  final ValueNotifier<Person> _personNotifier;
  final ValueNotifier<Family> _familyNotifier;

  @override
  State<StatefulWidget> createState() {
    return _FamilySectionState(_personNotifier, _familyNotifier);
  }
}

class _FamilySectionState extends State<FamilySection> {
  _FamilySectionState(this._personNotifier, this._familyNotifier);

  final ValueNotifier<Person> _personNotifier;
  final ValueNotifier<Family> _familyNotifier;

  PersonsModel _personsModel;

  @override
  void initState() {
    super.initState();
    _personsModel = Provider.of<PersonsModel>(context, listen: false);
  }

  static const Icon _addPersonIcon = Icon(Icons.person_add);

  Future<void> _familyAddTapped() async {
    final person = _personNotifier.value;
    final family = _familyNotifier.value ?? Family(id: person.id);
    final memberIds = family.memberIds;
    final selectedPersonId = await showDialog<String>(
        context: context,
        builder: (context) {
          final idsToGreyOut = {person.id, ...family.memberIds};
          return PersonSelectDialog(idsToGreyOut, title: 'Add Family'.i18n);
        });
    if (selectedPersonId != null) {
      final updatedMemberIds = {...memberIds}..add(selectedPersonId);
      setState(() {
        _familyNotifier.value = family.copyWith(memberIds: updatedMemberIds);
      });
    }
  }

  Widget _familyContent() {
    final addFamilyButton =
        IconButton(icon: _addPersonIcon, onPressed: _familyAddTapped);

    final family = _familyNotifier.value;
    final head = _personsModel.get(family?.id);

    if (head == null) {
      // invalid
      return ChoiceChip(
        avatar: const CircleAvatar(
          child: Icon(Icons.home),
        ),
        label: Text('Add Family'.i18n),
        onSelected: (selected) {
          _familyAddTapped();
        },
        selected: false,
      );
    }

    final familyMemberChips = <Widget>[]
      ..addAll(
          family.memberIds.map(_personsModel.get).map((person) => PersonTagChip(
                person,
                onDeleted: () {
                  final family = _familyNotifier.value;
                  final updatedMemberIds = {...family.memberIds}
                    ..remove(person.id);
                  setState(() {
                    _familyNotifier.value =
                        family.copyWith(memberIds: updatedMemberIds);
                  });
                },
              )))
      ..add(addFamilyButton);

    return Wrap(children: familyMemberChips);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _familyContent(),
    ]);
  }
}
