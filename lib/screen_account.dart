import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hitomemo/login_user_model.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'drawer.dart';
import 'main.dart';
import 'screen_account.i18n.dart';
import 'widgets/cached_image.dart';
import 'widgets/menu_button.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/account';

  Future<void> _onLogoutPressed(BuildContext context) async {
    final theme = Theme.of(context);
    final logoutConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          // return object of type Dialog
          return AlertDialog(
            title: Text('Are you sure you wand to sign out?'.i18n),
            content: Text('The data is available next time you sign in.'.i18n),
//          content: const Text('Alert Dialog body'),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text('Logout'.i18n),
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
        });
    if (logoutConfirmed) {
      final loginUserModel =
          Provider.of<LoginUserModel>(context, listen: false);
      await loginUserModel.logout();
      unawaited(Navigator.pushReplacementNamed(
          context, HitomemoInitialPage.routeName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
          title: Text('Account'.i18n),
          leading: const NotifyingMenuButton(routeName)),
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) => Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _UserInfoTable(),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: FlatButton(
                    child: Text('Logout'.i18n),
                    onPressed: () => _onLogoutPressed(context),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfoTable extends StatefulWidget {
  @override
  _UserInfoTableState createState() => _UserInfoTableState();
}

class _UserInfoTableState extends State<_UserInfoTable> {
  _UserInfoTableState();

  @override
  void initState() {
    super.initState();
    final loginUserModel = Provider.of<LoginUserModel>(context, listen: false);
    userInfo = loginUserModel.getUser();
  }

  Future<Map<String, dynamic>> userInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userInfo,
        builder: (context, snapshot) {
          final state = snapshot.connectionState;
          if (state == ConnectionState.done) {
            final user = snapshot.data as Map<String, dynamic>;
            // This is different from User
            return _UserInfoTableContent(user);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const LinearProgressIndicator();
        });
  }
}

class _UserInfoTableContent extends StatelessWidget {
  const _UserInfoTableContent(this._userInfo);
  final Map<String, dynamic> _userInfo;

  List<TableRow> buildRows(
      BuildContext context, List<Tuple2<String, String>> data) {
    final textTheme = Theme.of(context).textTheme;
    return data
        .map((Tuple2<String, String> tuple) => TableRow(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(tuple.item1, style: textTheme.caption)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  tuple.item2,
                  style: textTheme.bodyText2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]))
        .toList();
  }

  Widget iconWidget(String pictureUrl) {
    const r = 30.0;
    if (pictureUrl == null) {
      return const Icon(
        Icons.person,
        size: r * 2.0,
      );
    } else if (pictureUrl.startsWith('gs://')) {
      return CircleAvatar(radius: r, backgroundImage: CachedImage(pictureUrl));
    } else {
      return CircleAvatar(radius: r, backgroundImage: NetworkImage(pictureUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userInfo == null) {
      return Center(
        child: Text('Could not retrieve user information'.i18n),
      );
    }

    final userId = _userInfo['id'] as int;
    final createdTimestamp = _userInfo['created'] as Timestamp;
    final createdDate = createdTimestamp.toDate();

    final locale = I18n.locale;
    final formatter = DateFormat.yMMMMd(locale.languageCode);
    final providerIdsRaw = _userInfo['providerIds'] as List;

    final providerIds = providerIdsRaw.join(', ');

    final data = [
      Tuple2('User ID'.i18n, '$userId'),
      Tuple2('Name'.i18n, (_userInfo['displayName'] as String) ?? '(empty)'),
      Tuple2('Email'.i18n, _userInfo['email'] as String),
      Tuple2('Authentication'.i18n, providerIds),
      Tuple2('Since'.i18n, formatter.format(createdDate)),
    ];

    final iconPicture = iconWidget(_userInfo['photoUrl'] as String);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: iconPicture,
        ),
        Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: buildRows(context, data)),
      ],
    );
  }
}
