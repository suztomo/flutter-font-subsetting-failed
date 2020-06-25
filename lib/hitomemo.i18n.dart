import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {
        'en': 'Save',
        'ja': '保存',
      } +
      {'en': 'People', 'ja': 'ひと'} +
      {'en': 'Notes', 'ja': 'メモ'} +
      {'en': 'Indexing notes', 'ja': 'インデックスを更新しています'} +
      {'en': 'Indexed %s records', 'ja': '%s件のインデックスを更新しました'} +
      {'en': 'No note yet', 'ja': 'まだメモはありません'};

  String get i18n => localize(this, _translation);

  String fill(List<Object> params) => localizeFill(this, params);
}
