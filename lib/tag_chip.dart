import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class NoteTagChip extends StatefulWidget {
  const NoteTagChip({this.selected = true,
      this.onSelected,
      this.selectable = false,
      this.small = false});

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
    final onSelected = widget.onSelected;

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
            'foo',
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
