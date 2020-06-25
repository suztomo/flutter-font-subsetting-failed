import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Family', 'ja': '家族'} +
      {'en': 'Work', 'ja': '仕事'} +
      {'en': 'School', 'ja': '学校'} +
      {'en': 'Birthday', 'ja': '誕生日'} +
      {'en': 'Anniversary', 'ja': '記念日'} +
      {'en': 'Steps towards My Dream', 'ja': '夢への一歩'};

  String get i18n => localize(this, _translation);
}
