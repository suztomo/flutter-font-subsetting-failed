import 'package:i18n_extension/i18n_extension.dart';

import '../name.dart';

const thisAppIs = '$appNameEn is a people-oriented note app to keep memory'
    ' of people around you.';

const whatToInput = 'For example, things you talked with your family and '
    'friends.\nIt\'s like a diary for your important relationship.';

const organizeInformation = 'You can group information by tags.';

const String yourDataIsInCloud = 'Your data is stored in Cloud. '
    'You can add and edit notes through multiple devices.\n'
    'Secure Google/Apple sign-in protects your data.';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {
        'en': 'Welcome to $appNameEn',
        'ja': '$appNameJa / $appNameEn',
      } +
      {'en': thisAppIs, 'ja': '$appNameJaは家族、友人、同僚との大切な\nおつきあいを記録するメモです。'} +
      {
        'en': 'Diary for Relationship',
        'ja': 'おつきあいのための日記',
      } +
      {
        'en': whatToInput,
        'ja': '人と話したことをメモに取りましょう。'
            '日記のようなものですが、もっと様々なことに使えます。\n\n'
            '* 子どもの成長記録\n'
            '* 親戚から頂いたプレゼントの記録\n'
            '* 自分の家族の交友関係のメモ\n'
            '* 普段は会えない大切な友人のこと\n'
            '* 新しい・古い職場の人達のこと\n'
            '* 1-on-1の際のメモ\n',
      } +
      {
        'en': 'Organize Your Memory',
        'ja': '記憶を整理しよう',
      } +
      {
        'en': organizeInformation,
        'ja': 'グループやタグ機能を使うと複数の情報をまとめられます。\n'
            '$appNameJaは人のことを覚えるための日記です。人のことを覚えることで会話が弾み、次に会うのも楽しみになります。',
      } +
      {
        'en': 'Automatic Backup',
        'ja': '自動バックアップ',
      } +
      {
        'en': yourDataIsInCloud,
        'ja': 'データは入力されたらすぐにクラウド上のあなたのアカウントに安全に保存されます。'
            '複数の端末(iPhone/iPad)から$appNameJaを利用できます。',
      } +
      {
        'en': 'Next',
        'ja': '進む',
      } +
      {
        'en': 'Back',
        'ja': '戻る',
      };

  String get i18n => localize(this, _translation);
}
