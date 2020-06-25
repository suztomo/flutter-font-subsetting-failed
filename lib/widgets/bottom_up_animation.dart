import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

// https://flutter.dev/docs/cookbook/animation/page-route-animation
Route<T> createBottomUpAnimationRoute<T>(RoutePageBuilder pageBuilder) {
  return PageRouteBuilder<T>(
    pageBuilder: pageBuilder,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0, 1);
      const end = Offset.zero;
      const curve = Curves.ease;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
