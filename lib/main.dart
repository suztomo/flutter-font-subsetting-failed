import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';

import 'hitomemo.dart';
import 'hitomemo.i18n.dart';
import 'login_user_model.dart';
import 'name.dart';
import 'note_tags_model.dart';
import 'onboarding/screen_onboarding.dart';
import 'person_model.dart';
import 'person_tags_model.dart';

void main() {
  runApp(HitomemoApp());
}

class HitomemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        child: MaterialApp(
            onGenerateTitle: (context) => appNameEn.i18n,
            home: I18n(child: HitomemoInitialPage())),
      );
  }
}

class HitomemoInitialPage extends StatelessWidget {
  static const String routeName = '/init';

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginUserModel>(builder: (context, loginUserModel, child) {
      switch (loginUserModel.status) {
        case LoginStatus.loggedIn:
          return HitomemoHomePage();
        default:
          throw Exception('Unexpected login status ${loginUserModel.status}');
      }
    });
  }
}
