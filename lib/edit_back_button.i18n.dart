import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Discard', 'ja': '破棄'} +
      {
        'en': 'Cancel',
        'ja': 'キャンセル',
      } +
      {
        'en': 'Discard change?',
        'ja': '編集内容を破棄しますか?',
      };

  String get i18n => localize(this, _translation);
}
