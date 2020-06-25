import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {
        'en': 'Photo Library Permission',
        'ja': '写真のアクセス許可',
      } +
      {
        'en': 'To add photos, grant Photo Library permission in Settings',
        'ja': '写真を追加するにはiPhoneの設定アプリで写真のアクセスを許可してください',
      } +
      {'en': 'OK', 'ja': '閉じる'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
