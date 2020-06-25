import 'package:i18n_extension/i18n_extension.dart';

const tagsTutorialTitle = 'Add note about gifts';
const tagsTutorialStep1CreateTag = 'Save a tag such as "Gift"';
const tagsTutorialStep1CreateTagDone = 'Saved a tag (%s)';
const tagsTutorialStep2AddTagToNote = 'Add the tag to note';
const tagsTutorialStep3ViewTaggedNotes = 'View tagged notes';
const tagsTutorialStepCompleted = 'Great. You\'ve learned how to tag notes.';
const tagsTutorialStartSnackBar = 'Go to Tags page via upper-left menu.';
const tagsTutorialGotoHomeSnackBar = 'Next, go to Home and create a note.';
const tagsTutorialCreateNoteSnackBar = 'Next, create a note and add the tag.';
const tagsTutorialViewTaggedNoteSnackBar = 'Great. Next, tap the tag.';
const youCanAddMore = 'You can add more in bottom-right button';
const enoughPeopleAdded = 'Great. You\'ve added %s people.';

extension Localization on String {
  // Somehow final does not work here.
  // ignore: unused_field, prefer_final_fields
  static var _translation = Translations('en') +
      {'en': 'Your first diary', 'ja': '自分の日記'} +
      {'en': 'Adding People', 'ja': '人の登録'} +
      {'en': 'Note on Person', 'ja': 'メモを書く'} +
      {'en': 'Tutorial', 'ja': 'チュートリアル'} +
      {'en': 'Let\'s add 3 people to take notes.', 'ja': 'まずは人物を3人追加しましょう。'} +
      {'en': youCanAddMore, 'ja': '右下のボタンでも人を追加できます。'} +
      {'en': tagsTutorialTitle, 'ja': 'プレゼントを記録する'} +
      {
        'en': 'You\'ll learn how to organize notes by tags',
        'ja': 'タグを使ってメモを整理する方法を紹介します。'
      } +
      {'en': tagsTutorialStep1CreateTag, 'ja': '「タグ」画面でタグを保存する(例: 「プレゼント」タグ)'} +
      {'en': tagsTutorialStep1CreateTagDone, 'ja': 'タグを保存しました: %s'} +
      {'en': tagsTutorialGotoHomeSnackBar, 'ja': '「ホーム」へ行きメモを書きましょう'} +
      {'en': tagsTutorialStep2AddTagToNote, 'ja': '誰かのメモにそのタグを付ける'} +
      {'en': tagsTutorialStep3ViewTaggedNotes, 'ja': 'タグが付いたメモを見る'} +
      {'en': tagsTutorialStepCompleted, 'ja': '素晴らしい！タグの使い方をマスターしました。'} +
      {'en': tagsTutorialStartSnackBar, 'ja': '左上のメニューから「タグ」をタップ'} +
      {'en': tagsTutorialCreateNoteSnackBar, 'ja': '次にこのタグをメモに使いましょう'} +
      {'en': tagsTutorialViewTaggedNoteSnackBar, 'ja': '最後にタグをタップしてみましょう'} +
      {'en': enoughPeopleAdded, 'ja': '%s人登録しました。'} +
      {'en': 'Next: Tutorial', 'ja': 'チュートリアルに進む'} +
      {'en': 'End tutorial', 'ja': 'チュートリアルを止める'} +
      {
        'en': 'See "Help" page to resume tutorials',
        'ja': '"ヘルプ"からチュートリアルを再開できます'
      };

  String get i18n => localize(this, _translation);
  String fill(List<Object> params) => localizeFill(this, params);
}
