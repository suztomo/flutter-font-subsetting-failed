import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../person.dart';
import 'cached_image.dart';

class PersonCircleAvatar extends StatelessWidget {
  const PersonCircleAvatar(this.person, {this.radius});

  final double radius;
  final Person person;

  @override
  Widget build(BuildContext context) {
    final pictureGcsPath = person?.pictureGcsPath;
    final theme = Theme.of(context);
    if (pictureGcsPath == null) {
      return CircleAvatar(
        radius: radius,
        child: Icon(
          Icons.person,
          size: radius != null ? (radius * 1.6) : null,
          color: theme.disabledColor,
        ),
        backgroundColor: Colors.transparent,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedImage(pictureGcsPath),
      backgroundColor: Colors.grey,
    );
  }
}
