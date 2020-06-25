import 'package:hitomemo/name.dart';
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': appNameEn, 'ja': appNameJa} +
      {
        'en': 'Home',
        'ja': 'ホーム',
      } +
      {'en': 'Timeline', 'ja': 'タイムライン'} +
      {
        'en': 'Tags',
        'ja': 'タグ',
      } +
      {'en': 'Groups', 'ja': 'グループ'} +
      {
        'en': 'Account',
        'ja': 'アカウント',
      } +
      {
        'en': 'Help',
        'ja': 'ヘルプ',
      } +
      {'en': 'About $appNameEn', 'ja': '$appNameEn'};

  String get i18n => localize(this, _translation);
}
