import 'package:i18n_extension/i18n_extension.dart';
import 'package:tuple/tuple.dart';

const String hintTextReceivedGift = '%s gave me a present.';

final List<Tuple2<String, String>> invitingHintTexts = [
  const Tuple2('anniversary', '記念日'),
  // const Tuple2('birthday', '誕生日'),
  const Tuple2('preferences', '好きなこと'),
  // const Tuple2('personality', '性格'),
  const Tuple2('memorable occasions', '思い出の出来事'),
  const Tuple2('memorable words', '思い出の言葉'),
  const Tuple2('short-term goal ', '近い将来の話'),
  const Tuple2('long-term dream', '遠い将来の夢'),
  const Tuple2('the first impression', '最初に会った時のこと'),
  const Tuple2('the last meeting', '最後に会った時のこと'),
  const Tuple2('current job', '仕事について話したこと'),
  const Tuple2('past jobs', '過去の仕事について'),
//   const Tuple2('birthplace', '生まれた場所'),
  const Tuple2('talk about childhood', '子どもの頃の話'),
  const Tuple2('family-related story', '家族の話'),
  const Tuple2('hobby-related story', '趣味の話'),
  const Tuple2('good skill', '得意なこと'),
];

final List<Tuple2<String, String>> invitingDiaryHintTexts = [
  const Tuple2('recent anniversary', '最近の記念日'),
  const Tuple2('something happy', '幸せを感じたこと'),
//  const Tuple2('something worrying', '心配なこと'),
  const Tuple2('new event', '今日の新しい出来事'),
  const Tuple2('things you tried', '何か試してみたこと'),
  const Tuple2('the same things as yesterday', '昨日と同じこと'),
  const Tuple2('things that have changed since last week', '先週と違うこと'),
  const Tuple2('things that have changed since yesterday', '昨日と違うこと'),
  const Tuple2('funny things', '面白かったこと'),
  const Tuple2('new event', '新しい出来事'),
  const Tuple2('repeating events', '繰り返されていること'),
  const Tuple2('memorable words', '思い出の言葉'),
  const Tuple2('short-term goal ', '近い将来の話'),
  const Tuple2('long-term dream', '遠い将来の夢'),
  const Tuple2('finished tasks', '無事終えた仕事'),
  const Tuple2('unfinished tasks', '今度やる仕事'),
  const Tuple2('tasteful meals', '美味しかったごはん'),
  const Tuple2('small changes you observed', '小さな変化'),
  const Tuple2('persons you helped', '誰かを助けてあげたこと'),
  const Tuple2('things you praise', '何か褒めたこと'),
  const Tuple2('about hobby', '趣味のこと'),
  const Tuple2('progress you made', '何かの進捗'),
  const Tuple2('things you couldn\'t do few months back', '数ヶ月前はできなかったこと'),
  const Tuple2('things you could have done better', 'もうちょっと上手くできそうなこと'),
  const Tuple2('satisfaction', '満足していること'),
  const Tuple2('appreciation', '感謝していること'),
  const Tuple2('important things you want to remember', '覚えておきたい大切なこと'),
];

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Good memory', 'ja': '思い出のメモ'} +
      {'en': 'Diary', 'ja': '日記'} +
      {'en': 'Empty note', 'ja': 'メモが空です'} +
      {
        'en': 'Undo',
        'ja': '取り消し',
      } +
      {'en': 'Saving note', 'ja': 'メモを登録中'} +
      {'en': 'Note saved', 'ja': '保存しました'} +
      {'en': 'e.g.,', 'ja': '例:'} +
      {'en': 'Save', 'ja': '登録'} +
      {'en': 'Note about %s', 'ja': '%sのメモ'} +
      {'en': hintTextReceivedGift, 'ja': '%sさんがプレゼントをくれました。'} +
      {'en': 'Logout', 'ja': 'ログアウト'};

  String get i18n {
    var translation = _translation;
    for (final t in invitingHintTexts) {
      translation = translation + {'en': t.item1, 'ja': t.item2};
    }
    for (final t in invitingDiaryHintTexts) {
      translation = translation + {'en': t.item1, 'ja': t.item2};
    }

    return localize(this, translation);
  }

  String fill(List<Object> params) => localizeFill(this, params);
}
