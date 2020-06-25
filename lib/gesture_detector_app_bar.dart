import 'package:flutter/material.dart';

class GestureDetectorAppBar extends StatelessWidget with PreferredSizeWidget {
  GestureDetectorAppBar(
      {Widget title, GestureTapCallback onTap, Widget leading, this.actions})
      : _title = title,
        _onTap = onTap,
        _leading = leading;

  final Widget _title;
  final GestureTapCallback _onTap;
  final Widget _leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AppBar(
        title: _title,
        leading: _leading,
        actions: actions,
      ),
      onTap: _onTap,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
