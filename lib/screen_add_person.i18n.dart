import 'package:i18n_extension/i18n_extension.dart';

const whatNamesDoYouHaveInMind = '''What names come to your mind?
- People you celebrate anniversaries together
- You received memorable gifts from them
- Mentors who help your dream
''';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Add Person', 'ja': '人を追加'} +
      {
        'en': 'Create notes for family, friends, or coworkers',
        'ja': '家族、友人や同僚の思い出を記録しましょう。'
      } +
      {
        'en': 'Saving data',
        'ja': '登録中',
      } +
      {
        'en': 'Undo',
        'ja': '取り消し',
      } +
      {'en': 'Logout', 'ja': 'ログアウト'} +
      {'en': 'name', 'ja': '名前'} +
      {'en': 'Empty name', 'ja': '名前が空です'} +
      {'en': 'Add', 'ja': '登録'} +
      {
        'en': whatNamesDoYouHaveInMind,
        'ja': '''憶えておきたい人は誰でしょうか?
・記念日をお祝いした人
・プレゼントのやりとりした人
・夢への挑戦を助けてくれる人
など
'''
      } +
      {'en': 'Add People', 'ja': 'まとめて人を追加'} +
      {'en': 'Submit', 'ja': '登録'};

  String get i18n => localize(this, _translation);
}
