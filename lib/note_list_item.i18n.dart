import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation =
      Translations('en') + {'en': 'Deleted', 'ja': '削除しました'};

  String get i18n => localize(this, _translation);
}
