import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/daily%20routine/daily_routine_screen.dart';
import '../screens/dashboard/profile_screen.dart';
import '../settings.dart';

class HappyLiverBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const HappyLiverBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  static const Color _green = Color(0xFF2DCB59);
  static const Color _gray = Color(0xFF9AA29D);

  // ================================================================
  // NAVIGATION
  // ================================================================

  void _navigate(BuildContext context, int index) {
    // Already on this screen
    if (index == selectedIndex) {
      return;
    }

    switch (index) {
    // ============================================================
    // HOME
    // ============================================================

      case 0:
      // Dashboard will be connected later by Member 1.
        return;

    // ============================================================
    // DAILY ROUTINE
    // ============================================================

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DailyRoutineScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: onThemeChanged,
            ),
          ),
        );
        break;

    // ============================================================
    // PROFILE
    // ============================================================

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: onThemeChanged,
            ),
          ),
        );
        break;

    // ============================================================
    // SETTINGS
    // ============================================================

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: onThemeChanged,
            ),
          ),
        );
        break;

      default:
        return;
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white12
                : Colors.black.withOpacity(0.06),
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [
              // ======================================================
              // HOME
              // ======================================================

              _bottomItem(
                context: context,
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
              ),

              // ======================================================
              // DAILY ROUTINE
              // ======================================================

              _bottomItem(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                index: 1,
              ),

              // ======================================================
              // PROFILE
              // ======================================================

              _bottomItem(
                context: context,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 2,
              ),

              // ======================================================
              // SETTINGS
              // ======================================================

              _bottomItem(
                context: context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAV ITEM
  // ================================================================

  Widget _bottomItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    final Color itemColor = selected
        ? _green
        : isDarkMode
        ? Colors.white60
        : _gray;

    return GestureDetector(
      onTap: () {
        _navigate(context, index);
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 22,
            color: itemColor,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,

              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,

              color: itemColor,
            ),
          ),
        ],
      ),
    );
  }
}