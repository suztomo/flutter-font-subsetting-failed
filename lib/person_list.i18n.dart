import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Loading...', 'ja': '読み込み中...'} +
      {
        'en': 'All (a-z)',
        'ja': '全て',
      } +
      {
        'en': 'Recent',
        'ja': '最近の更新',
      };

  String get i18n => localize(this, _translation);
}
