import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Edit Note', 'ja': 'メモを編集'} +
      {'en': 'Delete', 'ja': '削除'} +
      {'en': 'Update', 'ja': '保存'} +
      {'en': 'Note', 'ja': 'メモ'} +
      {'en': 'name', 'ja': '名前'} +
      {'en': 'Logout', 'ja': 'ログアウト'} +
      {'en': 'Saving note', 'ja': 'メモを登録中'} +
      {'en': 'Saved', 'ja': '保存しました'} +
      {'en': 'Select Tags', 'ja': 'タグを選択'} +
      {'en': 'Tag', 'ja': 'タグ'} +
      {'en': 'Close', 'ja': '閉じる'} +
      {'en': 'Done', 'ja': '保存'} +
      {
        'en': 'To add　photos, grant Photo Library permission in Settings app',
        'ja': '写真を追加するにはiPhoneの設定アプリで写真のアクセスを許可してください',
      } +
      {'en': 'Saving picture (%d / %d)', 'ja': '保存しています (%d / %d)'} +
      {
        'en': 'Picture uploaded',
        'ja': 'アップロードしました',
      } +
      {'en': 'Picture failed: Error: %s', 'ja': 'アップロードエラー %s'} +
      {'en': 'Tag person', 'ja': 'ヒトタグ'} +
      {'en': 'Delete this note?', 'ja': '削除しますか?'} +
      {'en': 'Delete', 'ja': '削除'} +
      {'en': 'Select a person', 'ja': 'ひとを選択'} +
      {'en': 'Cancel', 'ja': 'キャンセル'} +
      {'en': 'Filter', 'ja': '検索'} +
      {'en': 'Add a Note', 'ja': 'メモを追加'}+
      {'en': 'Tag name too short', 'ja': 'タグの名前が短すぎます'} +
      {'en': 'Duplicate tag name', 'ja': 'タグが重複しています'} +
      {'en': 'New Tag', 'ja': '新しいタグ'} +
      {'en': 'Saving the tag', 'ja': 'タグを登録中'} +
      {'en': 'Saved %s', 'ja': '%sを保存しました'} +
      {'en': 'Create', 'ja':'保存'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
