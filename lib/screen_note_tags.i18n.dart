import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Tags', 'ja': 'タグ'} +
      {'en': 'Organize your memory by tags', 'ja': 'メモをタグでまとめられます'} +
      {
        'en': 'Add new tag',
        'ja': '新しいタグを追加',
      } +
      {'en': 'Save', 'ja': '保存'} +
      {'en': 'Delete', 'ja': '削除'} +
      {'en': 'Tag Name', 'ja': '名前'} +
      {'en': 'Saving the tag', 'ja': 'タグを登録中'} +
      {'en': 'Saved', 'ja': '保存しました'} +
      {'en': 'Deleting tag: ', 'ja': '削除中: '} +
      {'en': 'Deleted', 'ja': '削除しました'} +
      {'en': 'Tag name too short', 'ja': 'タグの名前が短すぎます'} +
      {'en': 'Duplicate tag name', 'ja': 'タグが重複しています'} +
      {'en': 'No note tagged with "#%s"', 'ja': '"#%s"のタグが付けられているメモはありません'} +
      {'en': 'Gifts Received', 'ja': 'プレゼント'} +
      {'en': 'Start tutorial on tags', 'ja': 'タグのチュートリアルを開始'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
