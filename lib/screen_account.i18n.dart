import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Account', 'ja': 'アカウント'} +
      {'en': 'User ID', 'ja': 'ユーザ番号'} +
      {'en': 'Name', 'ja': '名前'} +
      {'en': 'Email', 'ja': 'メールアドレス'} +
      {'en': 'Name', 'ja': '名前'} +
      {'en': 'Authentication', 'ja': '認証'} +
      {'en': 'Since', 'ja': '登録日'} +
      {'en': 'Cancel', 'ja': 'キャンセル'} +
      {'en': 'Could not retrieve user information', 'ja': 'ユーザ情報を取得できませんでした'} +
      {
        'en': 'Logout',
        'ja': 'ログアウト',
      } +
      {
        'en': 'Are you sure you wand to sign out?',
        'ja': 'ログアウトしますか?',
      } +
      {
        'en': 'The data is available next time you sign in.',
        'ja': '保存された情報は次にログインした時に利用できます。',
      };

  String get i18n => localize(this, _translation);
}
