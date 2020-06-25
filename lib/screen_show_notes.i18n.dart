import 'package:i18n_extension/i18n_extension.dart';

const aDiaryIsNoteAboutYourself = 'A diary is note about yourself.\n'
    'What is today\'s good memory?';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Timeline', 'ja': 'タイムライン'} +
      {'en': 'No notes', 'ja': 'メモはありません'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
