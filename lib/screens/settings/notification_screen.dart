import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _darkText = Color(0xFF1B1F1D);
  static const Color _grayText = Color(0xFF8A948E);
  static const Color _grayNav = Color(0xFF9AA29D);

  bool _allowNotifications = true;
  bool _healthTips = true;
  bool _routineReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _buildSettingsCard(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: _lightGreenHeader,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Help & Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SETTINGS CARD
  // ================================================================
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _toggleRow(
            title: 'Allow notifications',
            description:
            'Receive alerts, reminders, and important updates.',
            value: _allowNotifications,
            onChanged: (v) => setState(() => _allowNotifications = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _toggleRow(
            title: 'Health Tips',
            description:
            'Daily wellness advice and lifestyle recommendations.',
            value: _healthTips,
            onChanged: (v) => setState(() => _healthTips = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _toggleRow(
            title: 'Routine Reminder',
            description:
            "Get notified when it's time to take your medication.",
            value: _routineReminder,
            onChanged: (v) => setState(() => _routineReminder = v),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _grayText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD9DDD9),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION BAR
  // ================================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                onTap: () {
                  // Navigate to Home screen
                },
              ),
              _bottomItem(
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: false,
                onTap: () {
                  // Navigate to Daily Routine screen
                },
              ),
              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                onTap: () {
                  // Navigate to Profile screen
                },
              ),
              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                onTap: () {
                  // Already on Settings screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? _green : _grayNav,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? _green : _grayNav,
            ),
          ),
        ],
      ),
    );
  }
}