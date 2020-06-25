import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:hitomemo/name.dart';
import 'package:hitomemo/onboarding/screen_sign_in.dart';

import 'screen_onboarding.i18n.dart';

class HitomemoSlideOnboarding extends StatefulWidget {
  @override
  _HitomemoSlideOnboardingState createState() {
    return _HitomemoSlideOnboardingState();
  }
}

// From https://github.com/flutter/packages/blob/master/packages/animations/example/lib/shared_axis_transition.dart
class _HitomemoSlideOnboardingState extends State<HitomemoSlideOnboarding> {
  final SharedAxisTransitionType _transitionType =
      SharedAxisTransitionType.horizontal;

  int pageIndex = 0;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    analytics.logEvent(name: 'onboarding_start');
  }

  static final List<Widget> pages = [
    const _Slide(
        'assets/images/bunbougu_memo.png', 'Welcome to $appNameEn', thisAppIs),

    const _Slide('assets/images/sns_happy_man.png', 'Diary for Relationship',
        whatToInput),

    const _Slide('assets/images/kjhou_board.png', 'Organize Your Memory',
        organizeInformation),
    // Cloud before sign-in to emphasize the need of sign-in
    const _Slide('assets/images/computer_cloud_system.png', 'Automatic Backup',
        yourDataIsInCloud),
    SignInPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    var paddingWidth = 16.0;
    final screenWidth = size.bottomRight(Offset.zero).dx;

    // In UIKit Size (Points)
    // https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html
    if (screenWidth < 400) {
      paddingWidth = 8.0;
    }

    final screenHeight = size.bottomRight(Offset.zero).dy;

    // No bottom margin when
    // The screen is larger than iPhone SE (568)
    // The screen is horizontal in iPhone X (375)
    final bottomMargin = (screenHeight < 600) ? 0.0 : 64.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: false,
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    child: child,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: _transitionType,
                  );
                },
                child: GestureDetector(
                  child: pages[pageIndex],
                  onTap: () {
                    setState(() {
                      pageIndex = min(pages.length - 1, pageIndex + 1);
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: (pageIndex == 0)
                        ? null
                        : () {
                            setState(() {
                              pageIndex = max(0, pageIndex - 1);
                            });
                          },
                    textColor: Theme.of(context).colorScheme.primary,
                    child: Text('Back'.i18n),
                    key: const Key('onboarding_previous'),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(
                        children: List<Widget>.generate(pages.length,
                            (i) => _indicator(context, i == pageIndex)),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: (pages.length - 1 == pageIndex)
                        ? null
                        : () {
                            setState(() {
                              pageIndex = min(pages.length - 1, pageIndex + 1);
                            });
                          },
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    disabledColor: Colors.black12,
                    child: Text('Next'.i18n),
                    key: const Key('onboarding_next'),
                  ),
                ],
              ),
            ),
            SizedBox(height: bottomMargin),
          ],
        ),
      ),
    );
  }

  Widget _indicator(BuildContext context, bool selected) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: selected ? 24 : 16,
      decoration: BoxDecoration(
          color: selected ? theme.accentColor : theme.disabledColor,
          borderRadius: const BorderRadius.all(Radius.circular(12))),
    );
  }
}

class SharedAxisPageRoute extends PageRouteBuilder<dynamic> {
  SharedAxisPageRoute({Widget page, SharedAxisTransitionType transitionType})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}

const double slideImageHeight = 200;

class _Slide extends StatelessWidget {
  const _Slide(this._imageAssetName, this._title, this._subtitle);

  final String _title;
  final String _subtitle;
  final String _imageAssetName;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    var paddingWidth = 30.0;
    final screenWidth = size.bottomRight(Offset.zero).dx;
    if (screenWidth < 400) {
      paddingWidth = 16.0;
    }

    return Center(
      child: Container(
        padding: EdgeInsets.all(paddingWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: SizedBox(
              height: slideImageHeight,
              child: Image(
                  height: slideImageHeight,
                  image: AssetImage(
                    _imageAssetName,
                  ),
                  fit: BoxFit.fitHeight),
            )),
            Padding(
              padding: EdgeInsets.all(paddingWidth),
              child: Text(
                _title.i18n,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              _subtitle.i18n,
            ),
          ],
        ),
      ),
    );
  }
}
