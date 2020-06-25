import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'hitomemo.dart';
import 'person_search_field.i18n.dart';

class HomeSearchField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeSearchFieldState();
  }
}

class HomeSearchFieldState extends State<HomeSearchField> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final criteriaNotifier =
        Provider.of<ValueNotifier<SearchCriteria>>(context, listen: false);

    _textController.addListener(() async {
      final queryText = _textController.text;
      criteriaNotifier.value = criteriaNotifier.value.copyWith(text: queryText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 18),
      child: SafeArea(
          top: false,
          bottom: false,
          child: TextFormField(
            focusNode: searchFieldFocusNode,
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: 'Search'.i18n, border: InputBorder.none))),
    );
  }
}
