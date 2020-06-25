import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'person.dart';
import 'tag.dart';
/// ChoiceChip for tags
class GroupChip extends StatelessWidget {
  const GroupChip(this._tag, {this.selected = true, this.onSelected});

  final PTag _tag;

  final bool selected;

  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSelected = this.onSelected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ChoiceChip(
        padding: const EdgeInsets.all(0),
        label: Text(
          _tag.name,
          style: theme.textTheme.bodyText1,
        ),
        labelStyle: theme.textTheme.bodyText1,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

class PersonTagChip extends StatelessWidget {
  const PersonTagChip(this._person,
      {this.title, this.onSelected, this.onDeleted});

  final Person _person;
  final String title;
  final ValueChanged<bool> onSelected;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (onDeleted != null) {
      final chipTheme = ChipTheme.of(context);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InputChip(
          padding: const EdgeInsets.all(0),
          label: Text(
            title ?? _person.name,
          ),
          labelStyle: theme.textTheme.bodyText1,
          selected: true,
          onSelected: onSelected,
          onDeleted: onDeleted,
          selectedColor: chipTheme.secondarySelectedColor,
          showCheckmark: false,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ChoiceChip(
          padding: const EdgeInsets.all(0),
          label: Text(
            title ?? _person.name,
          ),
          labelStyle: theme.textTheme.bodyText1,
          selected: true,
          onSelected: onSelected,
        ),
      );
    }
  }
}
