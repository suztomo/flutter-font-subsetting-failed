import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/person_model.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';
import 'name.dart';
import 'screen_about_app.i18n.dart';
import 'screen_license.dart';
import 'widgets/menu_button.dart';

class AboutAppPage extends StatelessWidget {
  static const String routeName = 'about';

  static const String appStoreUrlEn =
      'https://apps.apple.com/us/app//id1508929510';
  static const String appStoreUrlJa =
      'https://apps.apple.com/jp/app//id1508929510';

  static const String privacyPolicyUrl =
      'https://suztomo.github.io/goodmemory/en/privacy-policy/';

  Future<void> shareStoreUrl(String storeUrl) async {
    final message = 'You can download $appNameEn here:'.i18n;
    final hashtag = '#$appNameEn'.i18n;
    await Share.share('$message\n$storeUrl\n$hashtag',
        subject: '$appNameEn - People Diary'.i18n);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final storeUrl =
        I18n.locale == const Locale('ja') ? appStoreUrlJa : appStoreUrlEn;

    final personsModel = Provider.of<PersonsModel>(context, listen: false);
    final personsCount = personsModel.persons.length;
    final showAddReview = personsCount > 15;

    final addReviewSection = showAddReview
        ? <Widget>[
            Text('Review in App Store'.i18n, style: textTheme.headline6),
            const SizedBox(
              height: 8,
            ),
            Text(
                'Thank you for using $appNameEn! '
                        'Your review in App Store motivates app developers '
                        'for future enhancements.'
                    .i18n,
                style: textTheme.caption),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    child: Text('Add Review'.i18n),
                    onPressed: () {
                      /*
                        https://pub.dev/packages/launch_review
                        // This unexpectedly opens another window
                        LaunchReview.launch(writeReview: true,
                            iOSAppId: '1508929510');
                            */
                      if (Platform.isIOS) {
                        // This does not work in TestFlight?
                        AppReview.requestReview.then((onValue) {
                          // What's the purpose of the callback?
                          // https://github.com/fluttercommunity/app_review/issues/18
                          print('Review requested: $onValue');
                        });
                      }
                    },
                  )),
            ),
            const SizedBox(
              height: 32,
            ),
          ]
        : <Widget>[];

    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
          title: Text('About $appNameEn'.i18n),
          actions: const <Widget>[],
          leading: const NotifyingMenuButton(AboutAppPage.routeName)),
      body: Builder(builder: (BuildContext context) {
        const margin = 16.0;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: margin),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                const SizedBox(height: margin),
                ...addReviewSection,
                Text('App Store URL'.i18n, style: textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Text(
                    'Do you know somebody who may like $appNameEn? '
                            'Share this App Store URL to your friends:'
                        .i18n,
                    style: textTheme.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              style: textTheme.caption.copyWith(
                                color: theme.primaryColor,
                              ),
                              text: storeUrl,
                              recognizer: MultiTapGestureRecognizer(
                                  longTapDelay:
                                      const Duration(milliseconds: 500))
                                ..onTap = (_) async {
                                  if (await canLaunch(storeUrl)) {
                                    await launch(
                                      storeUrl,
                                      forceSafariVC: false,
                                    );
                                  }
                                }
                                ..onLongTapDown = (_, detail) async {
                                  await shareStoreUrl(storeUrl);
                                }),
                        ],
                      )),
                    ),
                    IconButton(
                      icon: Icon(Icons.content_copy),
                      onPressed: () => shareStoreUrl(storeUrl),
                    )
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Text('Open Source License Declaration'.i18n,
                    style: textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Text(thankYouOss.i18n, style: textTheme.caption),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                        child: Text('Show Copyright information'.i18n),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, LicenseDisclaimerPage.routeName);
                        },
                      )),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text('Privacy Policy'.i18n, style: textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                        child: Text('Show Privacy Policy'.i18n),
                        onPressed: () async {
                          if (await canLaunch(privacyPolicyUrl)) {
                            await launch(
                              privacyPolicyUrl,
                              forceSafariVC: false,
                            );
                          }
                        },
                      )),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}
