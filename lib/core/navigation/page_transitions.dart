import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CUSTOM PAGE TRANSITIONS
//
// Matching the Design Guide § 5.2:
//   • Slide + Fade  → detail pages (right → left)
//   • Slide Up      → bottom sheets, prayer modal
//   • Fade          → tab switches (bottom nav)
//   • Scale + Fade  → modals, alerts
// ──────────────────────────────────────────────────────────────────────────────

/// Slide right-to-left + fade in — used for pushing detail pages.
CustomTransitionPage<T> slideFadePage<T>({
  required LocalKey key,
  required Widget child,
  String? name,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      final fadeTween = Tween<double>(begin: 0, end: 1).chain(
        CurveTween(curve: Curves.easeOut),
      );

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

/// Slide up from bottom — used for bottom sheets and prayer modal.
CustomTransitionPage<T> slideUpPage<T>({
  required LocalKey key,
  required Widget child,
  String? name,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      );
    },
  );
}

/// Simple cross-fade — used for tab switches in bottom nav.
CustomTransitionPage<T> fadePage<T>({
  required LocalKey key,
  required Widget child,
  String? name,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Scale (0.85 → 1.0) + fade — used for modals and alert dialogs.
CustomTransitionPage<T> scaleFadePage<T>({
  required LocalKey key,
  required Widget child,
  String? name,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scaleTween = Tween<double>(begin: 0.85, end: 1.0).chain(
        CurveTween(curve: Curves.easeOutBack),
      );

      final fadeTween = Tween<double>(begin: 0, end: 1).chain(
        CurveTween(curve: Curves.easeOut),
      );

      return ScaleTransition(
        scale: animation.drive(scaleTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}
