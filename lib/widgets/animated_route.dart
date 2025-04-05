import 'package:flutter/material.dart';

Route createSlideRoute(Widget page, {AxisDirection direction = AxisDirection.right}) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetBegin = _getBeginOffset(direction);
      final offsetEnd = Offset.zero;
      final tween = Tween(begin: offsetBegin, end: offsetEnd).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Offset _getBeginOffset(AxisDirection direction) {
  switch (direction) {
    case AxisDirection.up:
      return const Offset(0, 1);
    case AxisDirection.down:
      return const Offset(0, -1);
    case AxisDirection.left:
      return const Offset(1, 0);
    case AxisDirection.right:
    default:
      return const Offset(-1, 0);
  }
}
