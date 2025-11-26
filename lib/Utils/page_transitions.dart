import 'package:flutter/material.dart';

class RightToLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RightToLeftRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          // Use a pro-feeling curve
          const curve = Curves.easeOutQuart;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      );
}
