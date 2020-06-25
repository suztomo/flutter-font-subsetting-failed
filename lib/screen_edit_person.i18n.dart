import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Note', 'ja': 'メモ'} +
      {'en': 'Name', 'ja': '名前'} +
      {'en': 'Your Name', 'ja': '名前'} +
      {'en': 'Your Entry', 'ja': 'あなたのデータ'} +
      {'en': 'Delete', 'ja': '削除'} +
      {'en': 'Uploading picture', 'ja': '写真をアップロードしています'} +
      {
        'en': 'Picture uploaded',
        'ja': 'アップロードしました',
      } +
      {'en': 'Cropper', 'ja': '写真を切り取り'} +
      {'en': 'Invalid name', 'ja': '名前が短すぎます'} +
      {'en': 'John', 'ja': '渋沢 栄一さん'} +
      {'en': 'John Nourdog', 'ja': 'しぶさわえいいち'} +
      {'en': 'Phonetic Name', 'ja': 'よみがな'} +
      {'en': 'Select Groups', 'ja': 'グループを選択'} +
      {'en': 'Save', 'ja': '保存'} +
      {'en': 'No Group', 'ja': 'グループに追加'} +
      {'en': 'Edit %s', 'ja': '%s を編集'} +
      {'en': 'Close', 'ja': '閉じる'} +
      {'en': 'Picture failed: Error: %s', 'ja': 'アップロードエラー %s'} +
      {'en': 'Cancel', 'ja': 'キャンセル'} +
      {'en': 'Delete this entry?', 'ja': '削除しますか?'} +
      {
        'en': 'Photo Library Permission',
        'ja': '写真のアクセス許可',
      } +
      {
        'en': 'To add　photos, grant Photo Library permission in Settings app',
        'ja': '写真を追加するにはiPhoneの設定アプリで写真のアクセスを許可してください',
      } +
      {'en': 'OK', 'ja': '閉じる'} +
      {'en': 'Family', 'ja': '家族'} +
      {'en': 'Add Family', 'ja': '家族を追加'} +
      {'en': 'This entry is about yourself.', 'ja': 'このエントリーはあなた自身の情報です'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
