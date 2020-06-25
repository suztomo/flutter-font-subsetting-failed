import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Cropper', 'ja': '写真を切り取り'} +
      {
        'en': 'To add　photos, grant Photo Library permission in Settings app',
        'ja': '写真を追加するにはiPhoneの設定アプリで写真のアクセスを許可してください',
      } +
      {'en': 'Uploading picture', 'ja': '写真をアップロードしています'} +
      {
        'en': 'Picture uploaded',
        'ja': 'アップロードしました',
      } +
      {'en': 'Picture failed: Error: %s', 'ja': 'アップロードエラー %s'} +
      {'en': 'Photo Library', 'ja': '写真から選ぶ'} +
      {'en': 'Icons', 'ja': 'アイコンから選ぶ'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
