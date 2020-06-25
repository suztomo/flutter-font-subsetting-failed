import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import '../login_user_model.dart';
import '../screen_help.dart';
import 'screen_onboarding.dart';
import 'screen_sign_in.i18n.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/signin_page.dart
class SignInPage extends StatefulWidget {
  static const String routeName = 'signin';

  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    // I couldn't make landscape iPhone orientation work with Flexible and
    // FittedBox. Relying on MediaQuery.
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final screenHeight = size.bottomRight(Offset.zero).dy;

    return Scaffold(
        resizeToAvoidBottomPadding: false, // Avoid overflow by keyboard
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: Container()),
                  screenHeight < 500
                      ? Container()
                      : const Expanded(
                          flex: 3,
                          child: Center(
                            child: SizedBox(
                              height: slideImageHeight,
                              child: Image(
                                height: slideImageHeight,
                                image: AssetImage(
                                  'assets/images/bunbougu_memo.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                  screenHeight < 500
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Text(
                              'Sign in with your Google or Apple account'.i18n),
                          alignment: Alignment.center,
                        ),
                  _GoogleSignInSection(),
                  _AppleSignInSection(),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 16),
                    const FeedbackButton.text()
                  ],
                ))
          ],
        ));
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  bool _success;
  String _userID;
  GoogleSignIn _googleSignIn;

  String errorMessage;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: _GoogleSignInButton(() async {
                await _signInWithGoogle();
              })),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorMessage ?? googleAccountCaption.i18n,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _success == null
                  ? ''
                  : (_success
                      ? 'Successfully signed in, uid: $_userID'
                      : 'Sign in failed'),
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
        ],
      ),
    );
  }

  // Example code of how to sign in with google.
  Future<void> _signInWithGoogle() async {
    // final isSignedIn = await _googleSignIn.isSignedIn();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user tapped 'Cancel'
      unawaited(analytics.logEvent(name: 'signin_cancel'));
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final authResult = await _auth.signInWithCredential(credential);
      final user = authResult.user;
      assert(user.email != null);
      assert(!user.isAnonymous);
      final idToken = await user.getIdToken();
      assert(idToken != null);

      final currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      setState(() {
        _success = true;
        _userID = user.uid;
        Provider.of<LoginUserModel>(context, listen: false)
            .loginUser(currentUser);
      });
      unawaited(analytics.logEvent(name: 'onboarding_end'));
    } on Exception catch (err) {
      print('$err');
      setState(() {
        errorMessage = '$err';
      });
      unawaited(analytics.logEvent(name: 'google_signin_failed'));
      rethrow;
    }
  }
}

const double buttonWidth = 250;

/// flutter_signin_button's Google button has overflow problem below. Creating
/// my own button referring https://developers.google.com/identity/branding-guidelines
/// The following assertion was thrown during layout:
/// A RenderFlex overflowed by 72 pixels on the right.
///
/// The relevant error-causing widget was:
///   Row file:///Users/suztomo/Documents/hitomemo/lib/onboarding/screen_sign_in.dart:77:16
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton(this._onPressed);

  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Container(
        color: const Color(0xFF4285F4),
        width: buttonWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const Image(
                  image: AssetImage(
                    'assets/logos/google_dark.png',
                    package: 'flutter_signin_button',
                  ),
                  height: 45,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Sign in with Google'.i18n,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 17,
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppleSignInSectionState();
  }
}

class AuthCredentialWithApple {
  AuthCredentialWithApple({
    @required this.authCredential,
    @required this.appleIdCredential,
    @required this.name,
  });
  AuthCredential authCredential;
  AppleIdCredential appleIdCredential;
  PersonNameComponents name;
}

class _AppleSignInSectionState extends State<_AppleSignInSection> {
  bool _success;
  String _userID = 'not logged in';
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static String composeName(PersonNameComponents nameComponents) {
    if (nameComponents.nickname != null) {
      return nameComponents.nickname;
    }
    final locale = I18n.locale;
    if (locale == const Locale('ja')) {
      if (nameComponents.familyName != null) {
        return '${nameComponents.familyName} ${nameComponents.givenName}';
      } else if (nameComponents.givenName != null) {
        return nameComponents.givenName;
      } else {
        return 'Your name'.i18n;
      }
    } else {
      if (nameComponents.familyName != null) {
        if (nameComponents.middleName != null) {
          return '${nameComponents.givenName} ${nameComponents.middleName}'
              ' ${nameComponents.familyName}';
        } else {
          // Very likely here
          return '${nameComponents.givenName} ${nameComponents.familyName}';
        }
      } else if (nameComponents.givenName != null) {
        return '${nameComponents.givenName}';
      } else {
        return 'Your name'.i18n;
      }
    }
  }

  Future onPressedAppleButton(BuildContext context) async {
    AuthCredentialWithApple appleCredential;
    try {
      appleCredential = await requestAppleIdCredential();
    } on Exception catch (e) {
      // エラーハンドリング
      print('Error $e');
      _success = false;
      rethrow;
    }
    if (appleCredential == null) {
      _success = false;
      return; // null == キャンセルなので何もしない
    }
    // Appleサインインを実行
    final result =
        await _auth.signInWithCredential(appleCredential.authCredential);
    if (result == null) {
      print('signInWithCredential returned null');
      unawaited(analytics.logEvent(name: 'apple_signin_failed'));
      _success = false;
    } else {
      final user = result.user;

      var displayName = user.displayName;
      // 新規ユーザーか既存ユーザーかの分岐
      if (result.additionalUserInfo.isNewUser) {
        // For new user's first login, Apple gives first name and family name.
        // In subsequent login, Apple does not give anything; appleCredential
        // .name are all null. FirebaseUser.reload() does not help.
        displayName = composeName(appleCredential.name);
        print('new user: $displayName');

        final updateUser = UserUpdateInfo()..displayName = displayName;
        await user.updateProfile(updateUser); // Not immediately
      } else {
        print('existing user, using $displayName');
      }

      setState(() {
        _success = true;
        _userID = user.uid;
        Provider.of<LoginUserModel>(context, listen: false)
            .loginUser(user, displayName: displayName);
      });
      unawaited(analytics.logEvent(name: 'onboarding_end'));
    }
  }

  Future<AuthCredentialWithApple> requestAppleIdCredential() async {
    final authResult = await AppleSignIn.performRequests([
      const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    if (authResult.error != null) {
      throw Exception('Sign in failed: ${authResult.error}');
    }

    switch (authResult.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = authResult.credential;
        const oAuthProvider = OAuthProvider(providerId: 'apple.com');
        final oAuthCredential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );

        // This full name may provide other fields than firstName and familyName
        final fullName = appleIdCredential.fullName;
        final credentialWithApple = AuthCredentialWithApple(
          authCredential: oAuthCredential,
          appleIdCredential: appleIdCredential,
          name: fullName,
        );
        return credentialWithApple;
      case AuthorizationStatus.cancelled:
        return null;
      case AuthorizationStatus.error:
        throw Exception('Sign in failed: ${AuthorizationStatus.error}');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AppleSignIn.isAvailable(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Text('Checking availability...'.i18n);
          }
          if (!snapshot.data) {
            return Text('Apple Signin is unavailable'.i18n);
          }
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: buttonWidth,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child:
                      _AppleSignInButton(() => onPressedAppleButton(context)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    appleAccountCaption.i18n,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _success == null
                        ? ''
                        : (_success
                            ? 'Successfully signed in, uid: $_userID'
                            : 'Sign in failed'),
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton(this._onPressed);

  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: Colors.black,
          width: buttonWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
                child: ClipRRect(
                  child: Icon(
                    FontAwesomeIcons.apple,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Sign in with Apple'.i18n,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 19,
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
