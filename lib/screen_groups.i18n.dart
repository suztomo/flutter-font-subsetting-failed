import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Groups', 'ja': 'グループ'} +
      {
        'en': 'Organize your family/friends by groups',
        'ja': '友人や家族をグループでまとめられます'
      } +
      {
        'en': 'Add new group',
        'ja': '新しいグループを追加',
      } +
      {'en': 'Add', 'ja': '保存'} +
      {'en': 'Save', 'ja': '保存'} +
      {'en': 'Family', 'ja': '家族'} +
      {'en': 'ABC & Co.', 'ja': '会社'} +
      {'en': 'Company X', 'ja': '取引先'} +
      {'en': 'Group Name', 'ja': 'グループの名前'} +
      {'en': 'Logout', 'ja': 'ログアウト'} +
      {'en': 'Saving group', 'ja': 'グループを保存中'} +
      {'en': 'Saved %s', 'ja': '%sを保存しました'} +
      {'en': 'Group name too short', 'ja': '名前が短すぎます'} +
      {'en': 'Duplicate group name', 'ja': 'グループが重複しています'} +
      {'en': 'Delete Group %s?', 'ja': '%sグループを削除しますか?'} +
      {'en': 'Deleting %s', 'ja': '%sを削除しています'} +
      {'en': 'Deleted %s', 'ja': '%sを削除しました'} +
      {'en': 'No person in "%s" group', 'ja': '"%s"に登録されている人はいません'} +
      {'en': 'Updating group', 'ja': 'グループを更新しています'} +
      {'en': 'Updated %s', 'ja': '%sを更新しました'} +
      {'en': 'Delete this group', 'ja': 'このグループを削除'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
