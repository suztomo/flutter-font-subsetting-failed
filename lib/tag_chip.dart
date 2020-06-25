import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'person.dart';
import 'screen_show_group_persons.dart';
import 'screen_show_tag_notes.dart';
import 'tag.dart';
import 'widgets/person_circle_avatar.dart';

/// ChoiceChip for tags
class GroupChip extends StatelessWidget {
  const GroupChip(this._tag, {this.selected = true, this.onSelected});

  final PTag _tag;

  final bool selected;

  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSelected = this.onSelected ??
        (_) async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
                settings:
                    const RouteSettings(name: ShowGroupPersonsRoute.routeName),
                builder: (context) => ShowGroupPersonsRoute(_tag)),
          );
        };

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

    final leadingIcon = PersonCircleAvatar(_person, radius: 20);

    if (onDeleted != null) {
      final chipTheme = ChipTheme.of(context);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InputChip(
          avatar: leadingIcon,
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
          avatar: leadingIcon,
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

class NoteTagChip extends StatefulWidget {
  const NoteTagChip(this._tag,
      {this.selected = true,
      this.onSelected,
      this.selectable = false,
      this.small = false});

  final NTag _tag;

  final bool selected;

  final bool selectable;

  final bool small;

  final ValueChanged<bool> onSelected;

  @override
  _NoteTagChipState createState() => _NoteTagChipState();
}

class _NoteTagChipState extends State<NoteTagChip> {
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSelected = widget.onSelected ??
        (_) async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
                settings:
                    const RouteSettings(name: ShowGroupPersonsRoute.routeName),
                builder: (context) => ShowTagNotesRoute(widget._tag)),
          );
        };

    final textTheme =
        theme.textTheme.bodyText1.copyWith(fontSize: widget.small ? 10 : 14);
    // final fontSize = textTheme.fontSize;

    // https://hue360.herokuapp.com/
    const lightOrange = Color(0xFFF6D580);
    final color = _selected ? lightOrange : theme.disabledColor;

    return ButtonTheme(
      height: 20,
      minWidth: 50,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: FlatButton(
          // Removes unwanted margin around the button
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text(
            '#${widget._tag.name}',
            // Setting height aligns the heights of the chip size
            style: textTheme.copyWith(height: widget.small ? 1.2 : 1.5),
          ),
          color: color,
          onPressed: () {
            // Flip selected flag only when the caller expects special handling
            // on selected.
            if (widget.selectable) {
              _selected = !_selected;
            }
            onSelected(_selected);
          }),
    );
  }
}
