import 'package:flutter/material.dart';

import 'photo_access_dialog.i18n.dart';

Future<void> dialogPhotoAccess(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      // return object of type Dialog
      return AlertDialog(
        title: Text('Photo Library Permission'.i18n),
        content: Text('To add photos, grant Photo '
                'Library permission in Settings'
            .i18n),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'.i18n),
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
        ],
      );
    },
  );
}
