import 'package:flutter/material.dart';
import 'package:hitomemo/widgets/tutorial.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';
import 'screen_help.i18n.dart';
import 'widgets/menu_button.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = 'help';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
          title: Text('Help'.i18n),
          actions: const <Widget>[],
          leading: const NotifyingMenuButton(routeName)),
      body: Builder(builder: (BuildContext context) {
        const margin = 16.0;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: margin),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                const SizedBox(
                  height: margin,
                ),
                _TutorialSection(),
                const SizedBox(
                  height: 8,
                ),
                Text('FAQ'.i18n, style: textTheme.headline6),
                _FaqSection(),
                const SizedBox(height: margin),
                Text('Question'.i18n, style: textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: Text(
                      'Would you send your thoughts on this app to the '
                              'developer? Both good and bad parts.'
                          .i18n,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: FeedbackButton.button(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton.button() : _isButton = true;

  const FeedbackButton.text() : _isButton = false;

  final bool _isButton;

  static const String feedbackUrlJa =
      'https://docs.google.com/forms/d/e/1FAIpQLSd9rZy-nX6WKlC-OEwWZv1oFasZANsaESyCLLzLFuKgtb1OIQ/viewform';
  static const String feedbackUrlEn =
      'https://docs.google.com/forms/d/1KuMjJt5dHB3hX4SQQFMn_qUfQOndXzuf8sVBseaGifU/viewform';

  Future<void> _launchURL(BuildContext context) async {
    final locale = I18n.locale;
    final url = locale == const Locale('ja') ? feedbackUrlJa : feedbackUrlEn;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isButton) {
      return RaisedButton(
        child: Text('Question / Feedback Form'.i18n),
        onPressed: () => _launchURL(context),
      );
    } else {
      return GestureDetector(
        child: Text(
          'Question?'.i18n,
          style: Theme.of(context).textTheme.caption,
        ),
        onTap: () => _launchURL(context),
      );
    }
  }
}

/* In future when we place a "More FAQ" button
class FaqButton extends StatelessWidget {
  const FaqButton();

  static const String faqUrlJa =
      'https://docs.google.com/forms/d/e/1FAIpQLSd9rZy-nX6WKlC-OEwWZv1oFasZANsaESyCLLzLFuKgtb1OIQ/viewform';
  static const String faqUrlEn =
      'https://docs.google.com/forms/d/1KuMjJt5dHB3hX4SQQFMn_qUfQOndXzuf8sVBseaGifU/viewform';

  Future<void> _launchURL(BuildContext context) async {
    final locale = I18n.locale;
    final url = locale == const Locale('ja') ? faqUrlJa : faqUrlEn;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Show FAQ'.i18n),
      onPressed: () => _launchURL(context),
    );
  }
}
*/

class _FaqSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget faqWidget(Tuple2<FaqQ, FaqA> faq) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.item1.en.i18n,
              style: textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              faq.item2.en.i18n,
              style: textTheme.bodyText2,
            )
          ],
        ),
      );
    }

    final faqWidgets = faqs.map(faqWidget).toList(growable: false);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: faqWidgets);
  }
}

class _TutorialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tutorialNotifier =
        Provider.of<ValueNotifier<TutorialState>>(context, listen: true);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tutorial'.i18n, style: textTheme.headline6),
      const SizedBox(
        height: 8,
      ),
      const TutorialContent(
        cancellable: true,
      ),
      const SizedBox(
        height: 8,
      ),
      tutorialNotifier.value is Off
          ? Container()
          : RaisedButton(
              child: Text('Stop Tutorial'.i18n),
              onPressed: () {
                tutorialNotifier.value = const TutorialState.off();
              },
            )
    ]);
  }
}
