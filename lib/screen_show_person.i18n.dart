import 'package:i18n_extension/i18n_extension.dart';

const aDiaryIsNoteAboutYourself = 'A diary is note about yourself.\n'
    'What is today\'s good memory?';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Loading notes...', 'ja': 'メモを読み込み中'} +
      {'en': 'No note yet', 'ja': 'メモはまだありません'} +
      {'en': aDiaryIsNoteAboutYourself, 'ja': '日記はまだありません'} +
      {'en': 'Family:%s', 'ja': '家族:%s'} +
      {'en': 'Family', 'ja': '家族'} +
      {
        'en': '''Examples:
- Achievement they shared with you
- An anniversary you celebrated together
- Gifts you received
''',
        'ja': '''例えばこんな思い出を記録:
・記念日
・貰った/贈ったプレゼント
・助けてもらったこと
'''
      };

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
