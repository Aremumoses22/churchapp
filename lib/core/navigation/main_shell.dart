import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/widgets.dart';
import 'app_routes.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MAIN SHELL
//
// Wraps the 5 bottom-nav tabs with:
//   • AppBottomNavBar (tab switching with animation)
//   • AppPrayerFab (visible on all main tabs, hidden on pushed screens)
//   • StatefulShellRoute preserves each tab's navigator state so switching
//     tabs never triggers re-renders or loses scroll position.
// ──────────────────────────────────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Active tab content — each branch keeps its own navigator.
          navigationShell,

          // Prayer FAB — positioned above the bottom nav.
          AppPrayerFab(
            onPressed: () => context.push(AppRoutes.prayerRequest),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Double-tap a tab → pop to root of that branch.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
