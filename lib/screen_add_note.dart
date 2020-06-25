import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hitomemo/tag_chip.dart';
import 'package:provider/provider.dart';

import 'note.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_edit_note.i18n.dart';
import 'widgets/person_circle_avatar.dart';

class AddNoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddNoteRouteState();
  }
}

class AddNoteRouteState extends State<AddNoteRoute> {
  final ValueNotifier<Note> _noteNotifier = ValueNotifier(Note(content: ''));

  final ValueNotifier<Person> _personNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NoteListItem references this provider
        ChangeNotifierProvider<ValueNotifier<Person>>.value(
            value: _personNotifier),
        ChangeNotifierProvider<ValueNotifier<Note>>.value(value: _noteNotifier)
      ],
      child: Consumer<ValueNotifier<Note>>(
          builder: (context, noteNotifier, child) => Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                title: Text('Add a Note'.i18n),
                leading: noteNotifier.value.content.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : Container(), // Do not show back button,
              ),
              body: SingleChildScrollView(
                child: SafeArea(
                  child: ValueListenableBuilder<Person>(
                      valueListenable: _personNotifier,
                      builder: (context, person, _) => Column(children: [
                            const SizedBox(height: 8),
                            const _PersonSelectionForm(),
                        Container()
                          ])),
                ),
              ))),
    );
  }
}

class _PersonSelectionForm extends StatefulWidget {
  const _PersonSelectionForm();

  @override
  _PersonSelectionFormState createState() => _PersonSelectionFormState();
}

class _PersonSelectionFormState extends State<_PersonSelectionForm> {
  final TextEditingController _editingController = TextEditingController();

  PersonsModel personsModel;

  List<Person> filteredPersons = [];

  @override
  void initState() {
    super.initState();

    personsModel = Provider.of<PersonsModel>(context, listen: false);

    filteredPersons = sortAndTruncate(personsModel.searchByText(''));

    _editingController.addListener(() {
      final text = _editingController.text;
      setState(() {
        filteredPersons = sortAndTruncate(personsModel.searchByText(text));
      });
    });
  }

  List<Person> sortAndTruncate(List<Person> input) {
    if (input.isEmpty) {
      return [];
    }

    final ret = <Person>[];
    bool isUserPerson(Person person) {
      return person.id == '0';
    }

    if (input.where(isUserPerson).isNotEmpty) {
      final userPerson = input.firstWhere(isUserPerson);
      ret
        ..add(userPerson)
        ..addAll([...input]..removeWhere(isUserPerson));
    } else {
      ret.addAll(input);
    }
    return ret.sublist(0, min(ret.length, 5));
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personNotifier =
        Provider.of<ValueNotifier<Person>>(context, listen: true);

    final person = personNotifier.value;

    if (person != null) {
      return const _SelectedPerson();
    }

    final chips = filteredPersons.map((p) => PersonTagChip(
          p,
          onSelected: (_) {
            personNotifier.value = p;
          },
        ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a person'.i18n),
          TextFormField(
            controller: _editingController,
            maxLines: 1,
            decoration: InputDecoration(
              icon: const Icon(Icons.person),
              labelText: 'Filter'.i18n,
            ),
          ),
          Wrap(
            children: chips.toList(growable: false),
          )
        ],
      ),
    );
  }
}

class _SelectedPerson extends StatelessWidget {
  const _SelectedPerson();

  @override
  Widget build(BuildContext context) {
    final personNotifier = Provider.of<ValueNotifier<Person>>(context);
    final person = personNotifier.value;
    const r = 20.0;

    return Consumer<ValueNotifier<Note>>(
        builder: (context, noteNotifier, _) => ListTile(
            leading: PersonCircleAvatar(person, radius: r),
            title: Text(
              person.name,
            ),
            trailing: noteNotifier.value.content.isEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      personNotifier.value = null;
                    },
                  )
                : null));
  }
}
