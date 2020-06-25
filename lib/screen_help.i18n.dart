import 'package:hitomemo/name.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:tuple/tuple.dart';

class FaqQ {
  const FaqQ(this.en, this.ja);
  final String ja;
  final String en;
}

class FaqA {
  const FaqA(this.en, this.ja);
  final String en;
  final String ja;
}

final List<Tuple2<FaqQ, FaqA>> faqs = [
  const Tuple2(
      FaqQ('What is this app for?', 'このアプリはどう使えばいいですか?'),
      FaqA(
          'We recommend to write your favorite memory in $appNameEn, '
              'especially when you want to care somebody. '
              'For example it\'s good idea to record gifts you received or your'
              ' teammate\'s story about their family. '
              'When time comes, you can easily recall the important memory.',
          '$appNameJaはあなたの大切な人との出来事を記録するためのアプリです。'
              '例えば贈り物をもらった時のことや、同僚が家族の話をした時のことなどを記録するのに適しています。'
              '必要な時が来たら思い出せるように人物ごとのメモやタグ、グループ機能をデザインしました。')),
  const Tuple2(
      FaqQ('How can I backup data?', 'データのバックアップの方法を教えてください'),
      FaqA(
          'No worry! Your input data is immediately saved to the Cloud.'
              'When you lose your phone, you just need to signin the same '
              'email address as you are see in the Account page.',
          '入力されたデータは全てクラウドに保存されるのでバックアップの心配はありません。'
              '万が一ひと日記を使っていた端末を失ってしまった場合は同じメールアドレスで'
              'サインインするだけですぐにデータが復旧されます。')),
  const Tuple2(
      FaqQ('How can I use multiple devices?', '複数の端末を使う場合はどうすればいいですか?'),
      FaqA(
          'You can access your data through multiple devices. '
              'In that case, please ensure that you sign-in $appNameEn using '
              ' the same email address shown in the Account page.',
          '複数の端末を使う場合には、サインインする際に同じメールアドレスを利用してください。'
              '現在ログインしているメールアドレスは「アカウント」ページで確認できます。')),
  const Tuple2(
      FaqQ('Can I share data with somebody?', '他人とデータの共有はできますか?'),
      FaqA(
          'No, this app does share your data with people other than you. '
              'Your communication with somebody is unique to you. '
              'Therefore, we think this app should keep such information only '
              'accessible to your account.',
          'このアプリではデータをシェアする機能はついていません。'
              '自分と他の人とのやりとりは自分にとって特別なものなので、'
              '自分だけがアクセスできる場所に記録しておくのが一番だと考えてるからです。')),
  const Tuple2(
      FaqQ('Does this app use iCloud?', 'このアプリはiCloudを使用しますか?'),
      FaqA(
          'No, this app does not use iCloud. '
              'The data is stored in Google Cloud Platform.',
          'このアプリはiCloudは使いません。データはGoogleのクラウドに保存されています。')),
];

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Question', 'ja': 'お問い合わせ'} +
      {'en': 'Help', 'ja': 'ヘルプ'} +
      {
        'en': 'Question / Feedback Form',
        'ja': 'お問い合わせフォーム',
      } +
      {
        'en': 'Question?',
        'ja': 'お問い合わせ',
      } +
      {
        'en': 'Would you send your thoughts on this app to the '
            'developer? Both good and bad parts.',
        'ja': 'ご質問、アプリの良い点・悪い点など感想を開発者に書いてください。',
      } +
      {'en': 'FAQ', 'ja': 'よくあるご質問'} +
      {'en': 'Show FAQ', 'ja': 'FAQページを開く'} +
      {'en': 'Tutorial', 'ja': 'チュートリアル'} +
      {'en': 'Start Tutorial', 'ja': 'チュートリアルを開始'} +
      {'en': 'Stop Tutorial', 'ja': 'チュートリアルを止める'};

  String get i18n {
    var translation = _translation;
    for (final t in faqs) {
      translation = translation + {'en': t.item1.en, 'ja': t.item1.ja};
      translation = translation + {'en': t.item2.en, 'ja': t.item2.ja};
    }
    return localize(this, translation);
  }
}
