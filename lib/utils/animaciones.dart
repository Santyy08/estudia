import 'package:flutter/material.dart';

class Animaciones {
  // Fade In Animation (para widgets que aparecen suavemente)
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  // Slide from abajo hacia arriba
  static Widget slideFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOut,
    double offset = 30,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(0, offset / 100), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: value * 100, child: child);
      },
      child: child,
    );
  }

  // Scale Animation (zoom in)
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutBack,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: endScale),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  // Rotación con animación
  static Widget rotate({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOut,
    double beginTurns = 0.0,
    double endTurns = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginTurns, end: endTurns),
      duration: duration,
      curve: curve,
      builder: (context, turns, child) {
        return RotationTransition(
          turns: AlwaysStoppedAnimation(turns),
          child: child,
        );
      },
      child: child,
    );
  }
}
