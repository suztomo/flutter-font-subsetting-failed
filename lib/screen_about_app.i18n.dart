import 'package:i18n_extension/i18n_extension.dart';

import 'name.dart';

const String thankYouOss = 'This app is built with the following'
    ' fantastic open source software. Thank you!';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'About $appNameEn', 'ja': '$appNameJaについて'} +
      {'en': 'Open Source License Declaration', 'ja': '使用しているソフトウェア'} +
      {
        'en': appNameEn,
        'ja': appNameJa,
      } +
      {'en': 'Show Copyright information', 'ja': '著作権情報を表示(英語)'} +
      {'en': 'App Store URL', 'ja': 'App Storeのページ'} +
      {'en': 'Share App Store URL', 'ja': 'App StoreのURLを送る'} +
      {'en': 'Review in App Store', 'ja': 'App Storeでレビュー'} +
      {'en': 'Add Review', 'ja': 'レビューを送る'} +
      {
        'en': 'Thank you for using $appNameEn! '
            'Your review in App Store motivates app developers '
            'for future enhancements.',
        'ja': '$appNameJaを使っていただきありがとうございます。'
            'App Storeのレビューを頂けると開発者のモチベーションアップになります。'
      } +
      {
        'en': 'Do you know somebody who may like $appNameEn? '
            'Share this App Store URL to your friends:',
        'ja': '$appNameJaを気に入ってくれそうな人がいたらApp Storeのリンクをシェア'
            'してみませんか?'
      } +
      {'en': '$appNameEn - People Diary', 'ja': '$appNameJaのURL'} +
      {'en': 'You can download $appNameEn here:', 'ja': '$appNameJaをダウンロード'} +
      {'en': '#$appNameEn', 'ja': '#$appNameJa'} +
      {'en': 'Copyright', 'ja': '著作権情報'} +
      {'en': thankYouOss, 'ja': 'このアプリは以下の素晴らしいオープンソースソフトウェアを使っています。'} +
      {'en': 'Privacy Policy', 'ja': 'プライバシーポリシー'} +
      {'en': 'Show Privacy Policy', 'ja': 'プライバシーポリシーを表示(英語)'};

  String get i18n => localize(this, _translation);
}
