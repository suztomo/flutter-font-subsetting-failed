import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hitomemo/person.dart';
import 'package:hitomemo/person_model.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'screen_add_person.i18n.dart';
import 'widgets/person_editable_avatar.dart';

class AddMultiplePersonsRoute extends StatelessWidget {
  final ValueNotifier<bool> cancelEnabled = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: ValueListenableBuilder<bool>(
            valueListenable: cancelEnabled,
            builder: (context, enabled, _) => enabled
                ? IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.of(context).pop(<Person>[]);
                    },
                  )
                : Container(),
          ),
          // Here we take the value from the MyHomePage object that
          // was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Add People'.i18n),
        ),
        body: AddMultiplePersonsDialog(3, cancelEnabled));
  }
}

/// Dialog to input multiple persons information. The caller receives list of
/// Persons, which are saved in Firestore.
class AddMultiplePersonsDialog extends StatefulWidget {
  const AddMultiplePersonsDialog(this.count, this.cancelEnabled);

  final int count;

  final ValueNotifier<bool> cancelEnabled;

  @override
  _AddMultiplePersonsDialogState createState() =>
      _AddMultiplePersonsDialogState(count);
}

class _AddMultiplePersonsDialogState extends State<AddMultiplePersonsDialog> {
  _AddMultiplePersonsDialogState(this.count)
      : notifierAndKeys = List.generate(
            count, (_) => Tuple2(ValueNotifier(Person(name: '')), UniqueKey())),
        submitEnabled = ValueNotifier(true);

  final ValueNotifier<bool> submitEnabled;

  final int count;

  final List<Tuple2<ValueNotifier<Person>, UniqueKey>> notifierAndKeys;

  @override
  void initState() {
    super.initState();

    iconGcsUrls().then((urls) {
      final shuffled = [...urls]..shuffle();

      for (var i = 0; i < notifierAndKeys.length; ++i) {
        final personNotifier = notifierAndKeys[i].item1;
        final person = personNotifier.value;
        if (person.pictureGcsPath == null) {
          personNotifier.value = person.copyWith(pictureGcsPath: shuffled[i]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onSubmit() async {
      submitEnabled.value = false;

      final persons = notifierAndKeys
          .map((t) => t.item1)
          .map((n) => n.value)
          .where((p) => p != null)
          .toList(growable: false);
      if (persons.isNotEmpty) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Saving data'.i18n)));
      }

      final personsModel = Provider.of<PersonsModel>(context, listen: false);
      final savedPersons = <Person>[];
      for (final person in persons) {
        try {
          final saved = await personsModel.addPerson(person);
          savedPersons.add(saved);
        } on Exception catch (_) {
          submitEnabled.value = true;
          // Let the user try again
          return;
        }
      }

      Navigator.of(context).pop(savedPersons);
    }

    bool isEditing() {
      return notifierAndKeys
          .map((t) => t.item1)
          .map((n) => n.value)
          .where((p) => p != null)
          .where((p) => p.name.isNotEmpty)
          .isNotEmpty;
    }

    final theme = Theme.of(context);

    final firstKey = notifierAndKeys.first.item2;

    return Form(
        child: Column(children: <Widget>[
      ValueListenableBuilder<bool>(
        valueListenable: submitEnabled,
        builder: (context, notInProgress, _) => Visibility(
          visible: !notInProgress,
          child: const LinearProgressIndicator(),
        ),
      ),
      Expanded(
        child: AnimatedBuilder(
            animation: Listenable.merge(
                [...notifierAndKeys.map((t) => t.item1), submitEnabled]),
            builder: (context, __) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                widget.cancelEnabled.value = !isEditing();
              });
              final enabled = submitEnabled.value &&
                  notifierAndKeys
                      .map((t) => t.item1)
                      .map((n) => n.value)
                      .where((p) => p != null)
                      .map((p) => p.name)
                      .where((name) => name == null || name.isEmpty)
                      .isEmpty;

              return ListView(children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(whatNamesDoYouHaveInMind.i18n),
                ),
                ...notifierAndKeys.where((t) => t.item1.value != null).map(
                    (t) => _PersonInputTile(t.item1, t.item2,
                        deletable: firstKey != t.item2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      child: Text('Submit'.i18n),
                      color: theme.primaryColor,
                      textColor: theme.colorScheme.onPrimary,
                      onPressed: enabled ? onSubmit : null,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ]);
            }),
      ),
    ]));
  }
}

int personInputCounter = 0;

class _PersonInputTile extends StatefulWidget {
  const _PersonInputTile(this.notifier, Key key, {this.deletable = true})
      : super(key: key);
  final ValueNotifier<Person> notifier;

  final bool deletable;

  @override
  State<StatefulWidget> createState() {
    return _PersonInputTileState();
  }
}

class _PersonInputTileState extends State<_PersonInputTile> {
  final TextEditingController nameController = TextEditingController();

  final GlobalKey scrollableKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      final prevPerson = widget.notifier.value;
      widget.notifier.value = prevPerson.copyWith(name: nameController.text);

      // This unexpectedly bounces screen when the focus leaves a text field
      //Scrollable.ensureVisible(scrollableKey.currentContext,
      //    duration: const Duration(milliseconds: 100));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadingIcon = PersonEditableAvatar(widget.notifier);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              key: scrollableKey,
              decoration: InputDecoration(labelText: 'name'.i18n),
              controller: nameController,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 50,
                  child: ValueListenableBuilder<Person>(
                      valueListenable: widget.notifier,
                      builder: (context, person, _) {
                        final looksOk = person.pictureGcsPath != null &&
                            person.name.isNotEmpty;

                        if (looksOk) {
                          return const Icon(Icons.check_circle,
                              color: Colors.green);
                        }
                        if (widget.deletable && person.name.isEmpty) {
                          return GestureDetector(
                            child: const Icon(Icons.cancel),
                            onTap: () {
                              widget.notifier.value = null;
                            },
                          );
                        }
                        return Container();
                      }),
                ),
              ))
        ],
      ),
    );
  }
}
