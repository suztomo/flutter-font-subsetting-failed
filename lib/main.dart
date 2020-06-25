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

bool devicePreviewEnabled = false;

void main() {
  runApp(HitomemoApp());
}

final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

final FirebaseAuth auth = FirebaseAuth.instance;

final Connectivity connectivity = Connectivity();

// Google developer account tomotomotomo888@gmail.com
// Firebase project Hitomemo https://console.firebase.google.com/u/0/project/suztomo-hitomemo/overview
// Google OAuth Consent Screen
// https://console.developers.google.com/apis/credentials/consent?project=suztomo-hitomemo
class HitomemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // I want DevicePreview.of to return null if not enabled
    final locale =
        devicePreviewEnabled ? DevicePreview.of(context).locale : null;
    return
      GestureDetector(
        child: MaterialApp(
            debugShowCheckedModeBanner: !devicePreviewEnabled,
            localizationsDelegates: [
              // ... app-specific localization delegate[s] here
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ja'), // Japanese
            ],

            // https://pub.dev/packages/device_preview
            locale: locale,
            builder: DevicePreview.appBuilder,

            // This does not seem helping. Instead, this app uses InfoPList.
            // strings file to internationalize app name on home screen.
            // https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
            onGenerateTitle: (context) => appNameEn.i18n,
            navigatorObservers: <NavigatorObserver>[observer],
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
    // Initialize providers
    Provider.of<TagsModel>(context, listen: false);
    Provider.of<PersonsModel>(context, listen: false);
    Provider.of<NoteTagRepository>(context, listen: false);
    return Consumer<LoginUserModel>(builder: (context, loginUserModel, child) {
      switch (loginUserModel.status) {
        case LoginStatus.loggedIn:
          return HitomemoHomePage();
        case LoginStatus.unknown:
          return LoadingPage();
        case LoginStatus.notLoggedIn:
          return HitomemoSlideOnboarding();
        default:
          throw Exception('Unexpected login status ${loginUserModel.status}');
      }
    });
  }
}
