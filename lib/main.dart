import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'hitomemo.dart';
import 'hitomemo.i18n.dart';
import 'login_user_model.dart';
import 'name.dart';
import 'note_tags_model.dart';
import 'onboarding/screen_onboarding.dart';
import 'onboarding/screen_sign_in.dart';
import 'person_model.dart';
import 'person_tags_model.dart';
import 'screen_about_app.dart';
import 'screen_account.dart';
import 'screen_groups.dart';
import 'screen_help.dart';
import 'screen_license.dart';
import 'screen_note_tags.dart';
import 'widgets/tutorial.dart';

void main() {
  runApp(HitomemoApp());
}

// Google developer account tomotomotomo888@gmail.com
// Firebase project Hitomemo https://console.firebase.google.com/u/0/project/suztomo-hitomemo/overview
// Google OAuth Consent Screen
// https://console.developers.google.com/apis/credentials/consent?project=suztomo-hitomemo
class HitomemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // This does not seem helping. Instead, this app uses InfoPList.
          // strings file to internationalize app name on home screen.
          // https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
          onGenerateTitle: (context) => appNameEn.i18n,
          theme: ThemeData.light(),
          home: I18n(child: HitomemoInitialPage()),
          routes: {}),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus.unfocus();
      },
    );
  }
}

class HitomemoInitialPage extends StatelessWidget {
  static const String routeName = '/init';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('hi'));
  }
}
