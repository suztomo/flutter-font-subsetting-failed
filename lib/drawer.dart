import 'package:flutter/material.dart';
import 'package:hitomemo/hitomemo.dart';
import 'package:provider/provider.dart';

import 'drawer.i18n.dart';
import 'person.dart';
import 'person_model.dart';
import 'widgets/person_circle_avatar.dart';
import 'widgets/tutorial.dart';

class MenuDrawer extends StatelessWidget {
  // https://flutter.dev/docs/cookbook/design/drawer

  Widget _header(BuildContext context, Person person) {
    final theme = Theme.of(context);

    const r = 28.0;

    return UserAccountsDrawerHeader(
      currentAccountPicture: PersonCircleAvatar(person, radius: r),
      accountName: Text(person?.name ?? ''),
      accountEmail: const Text(''),
      decoration: BoxDecoration(
        color: theme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personsModel = Provider.of<PersonsModel>(context, listen: false);

    final user = personsModel.get('0');
    if (user == null) {
      return Container(
        width: 250,
        child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
            ],
          ),
        ),
      );
    }
    final drawerHeader = _header(context, user);

    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);

    final state = tutorialNotifier.value;

    var showDotOnTag = false;
    var showDotOnHome = false;

    state.maybeWhen<void>(
      onTagsTutorial: (TagsTutorialState state) {
        if (state.recentTagIds.isEmpty) {
          showDotOnTag = true;
        } else if (state.noteUsedTagIds.isEmpty) {
          showDotOnHome = true;
        }
      },
      orElse: () {},
    );

    Widget textWithDot(String text, {bool showDot = true}) {
      return Stack(
        children: <Widget>[
          Text(text),
          showDot
              ? Positioned(
                  top: 5,
                  right: 30,
                  child:
                      Icon(Icons.brightness_1, size: 12, color: Colors.orange))
              : Container()
        ],
      );
    }

    return Container(
      width: 250,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              child: drawerHeader,
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: textWithDot('Home'.i18n, showDot: showDotOnHome),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, HitomemoHomePage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
