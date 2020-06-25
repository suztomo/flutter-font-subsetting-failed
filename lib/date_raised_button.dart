import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';

import 'date_raised_button.i18n.dart';

class DateButton extends StatelessWidget {
  const DateButton(this._date, this._onPressed, {this.buttonKey});

  final DateTime _date;
  final VoidCallback _onPressed;
  final Key buttonKey;

  static final DateFormat _formatter =
      DateFormat.MMMMEEEEd(I18n.locale.languageCode);

  static final DateFormat _formatterWithYear =
      DateFormat.yMMMMEEEEd(I18n.locale.languageCode);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formatter =
        today.year == _date.year ? _formatter : _formatterWithYear;

    final isToday = today.year == _date.year &&
        today.month == _date.month &&
        today.day == _date.day;

    final formattedDate = formatter.format(_date);

    return GestureDetector(
        key: buttonKey,
        onTap: _onPressed,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.event),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  isToday
                      ? 'Today (%s)'.i18n.fill([formattedDate])
                      : formattedDate,
                  strutStyle: const StrutStyle(
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
