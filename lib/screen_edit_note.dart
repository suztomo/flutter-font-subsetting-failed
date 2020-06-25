import 'package:flutter/material.dart';
import 'package:hitomemo/note_tags_model.dart';
import 'package:hitomemo/tag.dart';
import 'package:provider/provider.dart';

import 'date_raised_button.dart';
import 'note.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_edit_note.i18n.dart';
import 'screen_edit_note_image_section.dart';
import 'screen_edit_note_tag_section.dart';
import 'widgets/person_circle_avatar.dart';
import 'widgets/tutorial.dart';

class EditNoteRoute extends StatelessWidget {
  EditNoteRoute(this._person, this._noteNotifier, this._closeContainerCallback)
      : _originalNote = _noteNotifier.value;
  final Person _person;

  /// Value to check whether note has changed its attributes
  final Note _originalNote;

  /// The callback to update person entity
  final Function(Note person) _closeContainerCallback;
  final ValueNotifier<Note> _noteNotifier;

  final ValueNotifier<bool> _updatingNote = ValueNotifier(false);

  Future<void> _onButtonPressed(BuildContext context) async {
    _updatingNote.value = true;
    final personsModel = Provider.of<PersonsModel>(context, listen: false);
    final noteTagsRepository =
        Provider.of<NoteTagRepository>(context, listen: false);

    final scaffold = Scaffold.of(context)
      ..showSnackBar(SnackBar(content: Text('Saving note'.i18n)));

    try {
      var note = _noteNotifier.value;
      final noteContent = note.content;
      if (noteContent.isNotEmpty) {
        /// No setState because this window closes

        final tagsInContent = NoteTagRepository.extractTagNames(noteContent);
        final tagsByName = noteTagsRepository.tagsByName;
        for (final tagName in tagsInContent) {
          var t = tagsByName[tagName];
          if (t == null) {
            t = NTag.create(tagName);
            await noteTagsRepository.save(t);
          }
          note = note.copyWith(tagIds: {...note.tagIds, t.id});
        }

        await personsModel.updateNote(_person, _originalNote, note);
        // This widget cannot touch the note list value notifier in
        // screen_show_person.
        for (final tagId in note.tagIds) {
          Tutorial.recordAddingTagToNote(context, tagId);
        }
        _closeContainerCallback(note);
      }
      scaffold
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Saved'.i18n)));
    } on Exception catch (err) {
      print('Failed to save $err');
      _updatingNote.value = false;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<Note>>.value(
        value: _noteNotifier,
        child: ValueListenableBuilder<Note>(
            valueListenable: _noteNotifier,
            builder: (context, note, child) {
              final noChange = _originalNote == note;
              return Scaffold(
                  resizeToAvoidBottomPadding: false,
                  appBar: AppBar(
                    title: Row(
                      children: <Widget>[
                        PersonCircleAvatar(_person, radius: 15),
                        const SizedBox(width: 8),
                        Flexible(
                            child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(_person.name, maxLines: 1),
                        )),
                      ],
                    ),
                    leading: noChange
                        ? IconButton(
                            tooltip: 'Cancel'.i18n,
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        : Container(), // Do not show back button
                    actions: [
                      ValueListenableBuilder<bool>(
                          valueListenable: _updatingNote,
                          builder: (context, isUpdatingNote, child) {
                            return IconButton(
                                tooltip: 'Update'.i18n,
                                icon: const Icon(Icons.check_circle),
                                key: const Key('form_submit'),
                                iconSize: 30,
                                onPressed: (noChange || isUpdatingNote)
                                    ? null
                                    : () => _onButtonPressed(context));
                          })
                    ],
                  ),
                  body: SafeArea(
                      child: EditNoteForm(
                          _person, _originalNote, _closeContainerCallback)));
            }));
  }
}

// https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/signin_page.dart
class EditNoteForm extends StatefulWidget {
  const EditNoteForm(this._person, this._note, this._closeContainerCallback);
  final Person _person;
  final Note _note;
  final Function(Note note) _closeContainerCallback;

  @override
  State<StatefulWidget> createState() => EditNoteState(_person, _note);
}

class EditNoteState extends State<EditNoteForm> {
  EditNoteState(this._person, this._originalNote);
  final _formKey = GlobalKey<FormState>();
  final Person _person;
  final Note _originalNote;
  Note _note;
  ValueNotifier<Note> _noteNotifier;
  final _memoController = TextEditingController();
  var _deletingNote = false;

  @override
  void initState() {
    super.initState();
    _noteNotifier = Provider.of<ValueNotifier<Note>>(context, listen: false);
    _noteNotifier.addListener(() {
      _note = _noteNotifier.value;
    });

    _note = _originalNote;
    _memoController
      ..text = _note.content
      ..addListener(() {
        final newDeletingNote = _memoController.text.isEmpty;
        if (newDeletingNote != _deletingNote) {
          setState(() {
            _deletingNote = newDeletingNote;
          });
        }
        final note = _note.copyWith(content: _memoController.text);
        setState(() {
          _noteNotifier.value = _note = note;
        });
      });
  }

  @override
  void dispose() {
    // https://flutter.dev/docs/cookbook/forms/text-field-changes
    _memoController.dispose();
    super.dispose();
  }

  bool _hasChange() => _noteNotifier.value != _originalNote;

  @override
  Widget build(BuildContext context) {
    Future<void> _deleteTapped() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          final color = Theme.of(context).colorScheme;
          return AlertDialog(
            title: Text('Delete this note?'.i18n),
            actions: <Widget>[
              RaisedButton(
                key: const Key('confirm-delete'),
                child: Text('Delete'.i18n),
                textColor: color.onError,
                color: color.error,
                onPressed: () async {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
              FlatButton(
                child: Text('Cancel'.i18n),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
            ],
          );
        },
      );

      if (confirmed) {
        final personsModel = Provider.of<PersonsModel>(context, listen: false);
        await personsModel.deleteNote(_person, _noteNotifier.value);
        // This still has bug when deleting the last item in
        // ListView.
        // https://github.com/flutter/flutter/issues/51397
        widget._closeContainerCallback(null);
      }
    }

    Widget deleteButton() {
      return IconButton(
        icon: const Icon(Icons.delete),
        key: const Key('form_delete'),
        color: Theme.of(context).errorColor,
        onPressed: _deleteTapped,
      );
    }

    Future<void> _onDatePressed() async {
      final picked = await showDatePicker(
          context: context,
          initialDate: _note.date,
          firstDate: Note.dateRangeStart,
          lastDate: Note.dateRangeEnd);
      if (picked != null && picked != _note.date) {
        final note = _note.copyWith(date: picked);
        _noteNotifier.value = note;
        setState(() {
          _note = note;
        });
      }
    }

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DateButton(
                    _note.date,
                    _onDatePressed,
                  ),
                  TextFormField(
                    key: const Key('form_note'),
                    maxLines: 5,
                    controller: _memoController,
                    decoration: InputDecoration(hintText: 'Note'.i18n),
                    // The validator receives the text that the user
                    // has entered.
                    validator: (value) {
                      _deletingNote = value.isEmpty;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  EditNoteTagSection(_person),
                  EditNoteImageSection(_person),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[deleteButton()],
                  ),
                  // Add TextFormFields and RaisedButton here.
                ]),
          ),
        ));
  }
}
