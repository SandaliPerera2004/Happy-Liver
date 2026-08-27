import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/settings_firestore_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../assessment/assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import 'settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allowNotifications = true;
  bool _healthTips = true;
  bool _routineReminder = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SettingsFirestoreService.getNotificationPreferences();
    if (mounted) {
      setState(() {
        _allowNotifications = prefs['allowNotifications'] ?? true;
        _healthTips = prefs['healthTips'] ?? true;
        _routineReminder = prefs['routineReminder'] ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences({
    bool? allowNotifications,
    bool? healthTips,
    bool? routineReminder,
  }) async {
    final newAllow = allowNotifications ?? _allowNotifications;
    final newTips = healthTips ?? _healthTips;
    final newReminder = routineReminder ?? _routineReminder;

    setState(() {
      _allowNotifications = newAllow;
      _healthTips = newTips;
      _routineReminder = newReminder;
    });

    await SettingsFirestoreService.saveNotificationPreferences(
      allowNotifications: newAllow,
      healthTips: newTips,
      routineReminder: newReminder,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings updated'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF146B0B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF146B0B)),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: _buildSettingsCard(isDark),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D1E) : const Color(0xFFDFF3D8),
      ),
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
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleRow(
            title: 'Allow notifications',
            subtitle: 'Receive alerts, reminders, and important updates.',
            value: _allowNotifications,
            isDark: isDark,
            onChanged: (v) => _updatePreferences(allowNotifications: v),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFECECEC),
          ),
          _buildToggleRow(
            title: 'Health Tips',
            subtitle: 'Daily wellness advice and lifestyle recommendations.',
            value: _healthTips,
            isDark: isDark,
            onChanged: (v) => _updatePreferences(healthTips: v),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFECECEC),
          ),
          _buildToggleRow(
            title: 'Routine Reminder',
            subtitle: 'Get notified when it\'s time to complete daily routines.',
            value: _routineReminder,
            isDark: isDark,
            onChanged: (v) => _updatePreferences(routineReminder: v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
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
            activeThumbColor: const Color(0xFF146B0B),
            activeTrackColor: const Color(0xFFCFF7D3),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssessmentResultScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DailyRoutineScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
    }
  }

  Widget _buildBottomNavBar() {
    return CustomBottomNavBar(
      currentIndex: 3,
      onTap: _onBottomNavTapped,
    );
  }
}