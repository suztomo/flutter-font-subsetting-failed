import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotifyingMenuButton extends StatelessWidget {
  const NotifyingMenuButton(this.routeName);

  final String routeName;

  @override
  Widget build(BuildContext context) {
    var showDot = false;

    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        showDot
            ? Positioned(
                // draw a red marble
                top: 10,
                right: 14,
                child: Icon(Icons.brightness_1, size: 12, color: Colors.orange),
              )
            : Container()
      ],
    );
  }
}
