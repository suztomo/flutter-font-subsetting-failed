import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/widgets/tutorial.dart';
import 'package:provider/provider.dart';

import '../hitomemo.dart';

class NotifyingMenuButton extends StatelessWidget {
  const NotifyingMenuButton(this.routeName);

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);

    final state = tutorialNotifier.value;

    var showDot = false;

    void onTagsTutorial(TagsTutorialState state) {
      if (state.recentTagIds.isEmpty) {
        showDot = true;
      } else {
        // state.recentTagIds.isNotEmpty
        if (state.noteUsedTagIds.isEmpty) {
          if (routeName != HitomemoHomePage.routeName) {
            showDot = true;
          }
        }
      }
    }

    state.maybeWhen(onTagsTutorial: onTagsTutorial, orElse: () => Void);

    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        showDot
            ? Positioned(
                // draw a red marble
                top: 10,
                right: 14,
                child: Icon(Icons.brightness_1, size: 12, color: Colors.orange),
              )
            : Container()
      ],
    );
  }
}
