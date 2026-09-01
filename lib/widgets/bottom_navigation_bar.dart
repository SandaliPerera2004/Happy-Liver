import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/daily%20routine/daily_routine_screen.dart';
import '../screens/dashboard/profile_screen.dart';
import '../screens/assessment/assessment_result_screen.dart';
import '../services/assessment_firestore_service.dart';
import '../settings.dart';

class HappyLiverBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const HappyLiverBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HappyLiverBottomNavBar> createState() =>
      _HappyLiverBottomNavBarState();
}

class _HappyLiverBottomNavBarState
    extends State<HappyLiverBottomNavBar> {
  static const Color _green = Color(0xFF2DCB59);
  static const Color _gray = Color(0xFF9AA29D);

  bool _isLoadingResults = false;

  // ================================================================
  // NAVIGATION
  // ================================================================

  Future<void> _navigate(
      BuildContext context,
      int index,
      ) async {
    // Already on this screen
    if (index == widget.selectedIndex) {
      return;
    }

    switch (index) {

    // ============================================================
    // ASSESSMENT RESULTS
    // ============================================================

      case 0:
        await _openAssessmentResults(context);
        break;

    // ============================================================
    // DAILY ROUTINE
    // ============================================================

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DailyRoutineScreen(
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
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
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
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
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
        break;

      default:
        return;
    }
  }

  // ================================================================
  // OPEN ASSESSMENT RESULTS
  // ================================================================

  Future<void> _openAssessmentResults(
      BuildContext context,
      ) async {
    if (_isLoadingResults) {
      return;
    }

    setState(() {
      _isLoadingResults = true;
    });

    try {
      // Get latest assessment from Firestore
      final result =
      await AssessmentFirestoreService
          .getLatestAssessmentResult();

      if (!mounted) {
        return;
      }

      // No assessment found
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No completed assessment found.',
            ),
          ),
        );

        return;
      }

      // Open Assessment Results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AssessmentResultScreen(
            result: result,
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load assessment results.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingResults = false;
        });
      }
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        border: Border(
          top: BorderSide(
            color: widget.isDarkMode
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
              // ASSESSMENT RESULTS
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
    final bool selected =
        widget.selectedIndex == index;

    final Color itemColor = selected
        ? _green
        : widget.isDarkMode
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