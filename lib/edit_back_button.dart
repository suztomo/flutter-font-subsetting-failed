import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'edit_back_button.i18n.dart';

/// Returns Future(true) if the user confirms discarding the change
/// https://goodpatch.com/blog/dialog-design/
Future<bool> showGoBackDialog(BuildContext context) async {
  // flutter defined function
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      // return object of type Dialog
      return AlertDialog(
        title: Text('Discard change?'.i18n),
//          content: const Text('Alert Dialog body'),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: Text('Discard'.i18n),
            color: theme.errorColor,
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
          ),
          FlatButton(
            child: Text('Cancel'.i18n),
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
        ],
      );
    },
  );
}
