// Define a custom Form widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_user_model.dart';
import 'person.dart';
import 'person_model.dart';
import 'screen_add_person.i18n.dart';
import 'screen_show_person.dart';
import 'widgets/person_editable_avatar.dart';

class AddPersonRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // Here we take the value from the MyHomePage object that
          // was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Add Person'.i18n),
        ),
        body: PersonForm());
  }
}

class PersonForm extends StatefulWidget {
  @override
  PersonFormState createState() {
    return PersonFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class PersonFormState extends State<PersonForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  bool _submitEnabled = true;

  final ValueNotifier<Person> personNotifier = ValueNotifier(Person(name: ''));

  @override
  void initState() {
    super.initState();

    iconGcsUrls().then((urls) {
      final shuffled = [...urls]..shuffle();
      final p = personNotifier.value;
      if (p.pictureGcsPath == null) {
        personNotifier.value = p.copyWith(pictureGcsPath: shuffled.first);
      }
    });
  }

  Future<void> onButtonPressed(BuildContext context) async {
    // listen:false not to register changes
    // https://medium.com/flutter-nyc/a-closer-look-at-the-provider-package-993922d3a5a5
    final loginUserModel = Provider.of<LoginUserModel>(context, listen: false);
    final personsModel = Provider.of<PersonsModel>(context, listen: false);

    // otherwise.
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitEnabled = false;
      });
      // If the form is valid, display a Snackbar.
      final scaffold = Scaffold.of(context)
        ..showSnackBar(
          SnackBar(
              duration: const Duration(seconds: 10), // dummy
              content: Text('Saving data'.i18n)),
        );
      final textVal = _nameController.text;
      var person = personNotifier.value
          .copyWith(name: textVal, updated: Timestamp.now(), notes: []);
      try {
        final beforeAddPerson = DateTime.now();
        person = await personsModel.addPerson(person);
        final afterAddPerson = DateTime.now();
        final timeTaken = afterAddPerson.difference(beforeAddPerson);
        final timeTakenMills = timeTaken.inMilliseconds;
        final additionalWaitMillis = 1000 - timeTakenMills;
        await Future<dynamic>.delayed(
            Duration(milliseconds: additionalWaitMillis));
        scaffold.hideCurrentSnackBar();

        await Navigator.of(context).pushReplacement<dynamic, Person>(
          MaterialPageRoute<dynamic>(
              settings: const RouteSettings(name: ShowPersonRoute.routeName),
              builder: (context) => ShowPersonRoute(person)),
          result: person, // Tell the person list to scroll to top
        );

        // Navigator.of(context).pop(person);
      } on Exception catch (err) {
        setState(() {
          _submitEnabled = true;
        });
        print('Failed to addPerson: $err');
        scaffold
          ..hideCurrentSnackBar()
          ..showSnackBar(
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
    final theme = Theme.of(context);

    // Build a Form widget using the _formKey created above.
    return SingleChildScrollView(
      child: Container(
          margin: const EdgeInsets.all(15),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create notes for family, friends, or coworkers'.i18n,
                      style: theme.textTheme.caption,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PersonEditableAvatar(personNotifier),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            autofocus: true,
                            key: const Key('form_name'),
                            controller: _nameController,
                            decoration: InputDecoration(hintText: 'name'.i18n),
                            // The validator receives the text that the user
                            // has entered.
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Empty name'.i18n;
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          RaisedButton(
                            key: const Key('form_submit'),
                            child: Text('Add'.i18n),
                            onPressed: _submitEnabled
                                ? () async {
                                    await onButtonPressed(context);
                                  }
                                : null,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            color: theme.accentColor,
                          ),
                        ],
                      ),
                    ),
                    Center(
                        child: Text(
                      whatNamesDoYouHaveInMind.i18n,
                    ))
                    // Add TextFormFields and RaisedButton here.
                  ]))),
    );
  }
}
