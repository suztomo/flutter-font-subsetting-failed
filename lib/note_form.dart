import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hitomemo/login_user_model.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'date_raised_button.dart';
import 'note.dart';
import 'note_form.i18n.dart';
import 'note_tags_model.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_edit_note_image_section.dart';
import 'screen_edit_note_tag_section.dart';
import 'tag.dart';

class NoteForm extends StatefulWidget {
  const NoteForm(this._person);

  final Person _person;

  @override
  NoteFormState createState() {
    return NoteFormState(_person);
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class NoteFormState extends State<NoteForm> {
  NoteFormState(this._person);

  ValueNotifier<Note> noteNotifier;

  bool toolsFolded = true;

  @override
  void initState() {
    super.initState();

    noteNotifier = Provider.of<ValueNotifier<Note>>(context, listen: false);

    _memoController.addListener(() {
      final prev = noteNotifier.value;
      noteNotifier.value = prev.copyWith(content: _memoController.text);
      if (_enableSubmit != _memoController.text.isNotEmpty) {
        setState(() {
          // If not empty, then users can submit
          _enableSubmit = _memoController.text.isNotEmpty;
        });

        Scrollable.ensureVisible(
          _dateButtonKey.currentContext,
          duration: const Duration(milliseconds: 100),
        );
      }
    });
    _noteDate = DateTime.now();

    hintText = generateHintText();
  }

  String generateHintText() {
    final myself = _person.id == '0';

    /*
    if (!myself) {
      return 'Note about %s'.i18n.fill([_person.name]);
    }

     */

    final invitingDictionary =
        myself ? invitingDiaryHintTexts : invitingHintTexts;
    final hintTexts = List<Tuple2<String, String>>.from(invitingDictionary)
      ..shuffle();
    final selectedTuple = hintTexts.first;
    final n = myself ? 'Diary'.i18n : 'Note about %s'.i18n.fill([_person.name]);
    final eg = 'e.g.,'.i18n;
    final hint = selectedTuple.item1.i18n;
    final hintFromInventory = '$n ($eg $hint)';

    return null;
  }

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.

  final _formKey = GlobalKey<FormState>();

  final _dateButtonKey = GlobalKey();
  final _saveButtonKey = GlobalKey();

  final _memoController = TextEditingController();
  DateTime _noteDate;

  // ignore: prefer_final_fields
  Person _person;

  bool _enableEdit = true;
  bool _enableSubmit = false;

  String hintText = 'Note';

  Future<void> _onDatePressed() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _noteDate,
        firstDate: Note.dateRangeStart,
        lastDate: Note.dateRangeEnd);
    if (picked != null && _noteDate != picked) {
      setState(() {
        _noteDate = picked;
        noteNotifier.value = noteNotifier.value.copyWith(date: _noteDate);
      });
    }
  }

  Future<void> _onNoteSubmitPressed() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      setState(() {
        _enableSubmit = false;
        _enableEdit = false;
      });
      // If the form is valid, display a Snackbar.
      final scaffold = Scaffold.of(context)
        ..showSnackBar(SnackBar(content: Text('Saving note'.i18n)));
      final textVal = _memoController.text;

      final personsModel = Provider.of<PersonsModel>(context, listen: false);
      final noteTagRepository =
          Provider.of<NoteTagRepository>(context, listen: false);
      try {
        // Note.Id is null. It's assigned by Firestore's value
        var note =
            noteNotifier.value.copyWith(content: textVal, date: _noteDate);

        final tagsInContent = NoteTagRepository.extractTagNames(textVal);
        final tagsByName = noteTagRepository.tagsByName;
        for (final tagName in tagsInContent) {
          var t = tagsByName[tagName];
          if (t == null) {
            t = NTag.create(tagName);
            await noteTagRepository.save(t);
          }
          note = note.copyWith(tagIds: {...note.tagIds, t.id});
        }

        // Got noteID
        note = await personsModel.addNoteToPerson(_person, note);
        scaffold
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Note saved'.i18n)));

        _memoController.clear();
        setState(() {
          _enableEdit = true;
          _enableSubmit = false; // text is now empty
          toolsFolded = true;
        });

        try {
          final noteListNotifier =
              Provider.of<ValueNotifier<List<Note>>>(context, listen: false);
          final existingNotes = noteListNotifier.value;
          noteListNotifier.value = [note, ...existingNotes];

          // Hide keyboard
          FocusManager.instance.primaryFocus.unfocus();
        } on ProviderNotFoundException catch (_) {
          // When this form is on screen_add_note
          Navigator.pop(context);
        }

        // Hide images and tags
        noteNotifier.value = Note(date: _noteDate, content: '');
      } on Exception catch (err) {
        print('Could not save note: $err');
        final loginUserModel =
            Provider.of<LoginUserModel>(context, listen: false);

        scaffold.showSnackBar(
          SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Error: $err'),
              action: SnackBarAction(
                label: 'Logout'.i18n,
                onPressed: () async {
                  await loginUserModel.logout();
                  Navigator.of(context).pop();
                },
              )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    return Container(
        margin: const EdgeInsets.fromLTRB(15, 8, 15, 0),
        child: ChangeNotifierProvider.value(
          value: noteNotifier,
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DateButton(
                      _noteDate,
                      _onDatePressed,
                      buttonKey: _dateButtonKey,
                    ),
                    Focus(
                      onFocusChange: (focusGained) {
                        if (focusGained) {
                          // When a person has a picture, this ensureVisible
                          // is not enough. Therefore another ensureVisible is
                          // set when the user types characters.
                          Scrollable.ensureVisible(
                            _dateButtonKey.currentContext,
                            duration: const Duration(milliseconds: 100),
                          );
                        }
                      },
                      child: TextFormField(
                        enabled: _enableEdit,
                        maxLines: 3,
                        controller: _memoController,
                        decoration: InputDecoration(hintText: hintText),
                        // The validator receives the text that the user
                        // has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Empty note'.i18n;
                          }
                          return null;
                        },
                      ),
                    ),

                    toolsFolded
                        ? const SizedBox(
                            height: 16,
                          )
                        : Container(
                            child: Stack(
                            children: [
                              Column(children: [
                                const SizedBox(height: 8),
                                EditNoteTagSection(widget._person),
                                EditNoteImageSection(widget._person),
                              ]),
                            ],
                          )),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Expanded(child: Container()),
                      toolsFolded
                          ? (_enableSubmit
                              ? IconButton(
                                  icon: Icon(Icons.add_circle),
                                  onPressed: () {
                                    setState(() {
                                      toolsFolded = !toolsFolded;
                                    });
                                    FocusManager.instance.primaryFocus
                                        .unfocus();
                                  })
                              : IconButton(
                                  icon: Icon(Icons.add_circle),
                                  onPressed: null))
                          : IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: _enableSubmit
                                  ? () {
                                      setState(() {
                                        toolsFolded = !toolsFolded;
                                      });
                                      FocusManager.instance.primaryFocus
                                          .unfocus();
                                    }
                                  : null,
                            ),
                      RaisedButton(
                        key: _saveButtonKey,
                        color: Theme.of(context).accentColor,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _enableSubmit && _enableEdit
                            ? _onNoteSubmitPressed
                            : null,
                        child: Text('Save'.i18n),
                      )
                    ])

                    // Add TextFormFields and RaisedButton here.
                  ])),
        ));
  }
}
