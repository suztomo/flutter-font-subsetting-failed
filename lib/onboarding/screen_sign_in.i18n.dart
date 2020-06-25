import 'package:i18n_extension/i18n_extension.dart';

const googleAccountCaption = 'If you have Google account, Google sign-in is '
    'suitable for you';

const appleAccountCaption = 'If your devices are all Apple products, '
    'Apple account login is suitable for you.';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {
        'en': 'Sign in with your Google or Apple account',
        'ja': 'Google / Appleのアカウントでサインイン'
      } +
      {
        'en': 'Sign in with Google',
        'ja': 'Googleでサインイン',
      } +
      {'en': 'Checking availability...', 'ja': 'プラットフォームを調べています'} +
      {'en': 'Sign in with Apple', 'ja': 'Appleでサインイン'} +
      {
        'en': googleAccountCaption,
        'ja': '既にGoogleアカウントをお持ちの場合、またはAndroidデバイスをお持ちの方は'
            'Googleのログインをご利用ください。'
      } +
      {
        'en': appleAccountCaption,
        'ja': 'お持ちのデバイスが全てApple製品の場合はAppleのログインも利用できます。'
      } +
      {'en': 'Your name', 'ja': 'あなたのお名前'} +
      {'en': 'Apple Signin is unavailable', 'ja': 'Appleサインインは無効です。'} +
      {'en': 'Privacy Policy', 'ja': 'プライバシーポリシー'};

  String get i18n => localize(this, _translation);
}
