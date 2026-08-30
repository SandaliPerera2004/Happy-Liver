import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/notification_settings_model.dart';
import '../../services/notification_settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationSettingsService _notificationService =
  NotificationSettingsService();

  bool _allowNotifications = true;
  bool _healthTips = true;
  bool _routineReminder = true;

  bool _isLoading = true;

  int _selectedNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // =========================================================
  // LOAD NOTIFICATION SETTINGS
  // =========================================================

  Future<void> _loadNotificationSettings() async {
    try {
      final settings =
      await _notificationService.getNotificationSettings();

      if (!mounted) return;

      setState(() {
        _allowNotifications = settings.allowNotifications;
        _healthTips = settings.healthTips;
        _routineReminder = settings.routineReminder;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load notification settings.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // SAVE NOTIFICATION SETTINGS
  // =========================================================

  Future<void> _updateSettings() async {
    try {
      final settings = NotificationSettingsModel(
        allowNotifications: _allowNotifications,
        healthTips: _healthTips,
        routineReminder: _routineReminder,
      );

      await _notificationService
          .updateNotificationSettings(settings);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save notification settings.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F6F8),

      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),

            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3FBE6B),
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  16,
                ),
                child: _buildSettingsCard(
                  isDarkMode,
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      _buildBottomNavBar(isDarkMode),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context) {
    // Keep the green header in BOTH modes.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFDFF3D8),
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

          const Text(
            'Notifications',
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

  // =========================================================
  // SETTINGS CARD
  // =========================================================

  Widget _buildSettingsCard(bool isDarkMode) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        // White in light mode
        // Dark card in dark mode
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.20 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          // =================================================
          // ALLOW NOTIFICATIONS
          // =================================================

          _buildToggleRow(
            title: 'Allow notifications',
            subtitle:
            'Receive alerts, reminders, and important updates.',
            value: _allowNotifications,
            isDarkMode: isDarkMode,
            onChanged: (v) async {
              setState(() {
                _allowNotifications = v;

                // If master notification is OFF,
                // automatically turn OFF the other two.
                if (!v) {
                  _healthTips = false;
                  _routineReminder = false;
                }
              });

              await _updateSettings();
            },
          ),

          Divider(
            height: 1,
            color: isDarkMode
                ? Colors.white12
                : const Color(0xFFECECEC),
          ),

          // =================================================
          // HEALTH TIPS
          // =================================================

          _buildToggleRow(
            title: 'Health Tips',
            subtitle:
            'Daily wellness advice and lifestyle recommendations.',
            value: _healthTips,
            isDarkMode: isDarkMode,
            onChanged: _allowNotifications
                ? (v) async {
              setState(() {
                _healthTips = v;
              });

              await _updateSettings();
            }
                : (_) {},
          ),

          Divider(
            height: 1,
            color: isDarkMode
                ? Colors.white12
                : const Color(0xFFECECEC),
          ),

          // =================================================
          // ROUTINE REMINDER
          // =================================================

          _buildToggleRow(
            title: 'Routine Reminder',
            subtitle:
            'Get reminders about your daily meal plan and workout plan.',
            value: _routineReminder,
            isDarkMode: isDarkMode,
            onChanged: _allowNotifications
                ? (v) async {
              setState(() {
                _routineReminder = v;
              });

              await _updateSettings();
            }
                : (_) {},
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TOGGLE ROW
  // =========================================================

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: isDarkMode
                        ? Colors.white70
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Switch(
            value: value,
            onChanged: onChanged,

            // Green branding remains the same.
            activeColor: Colors.white,
            activeTrackColor:
            const Color(0xFF3FBE6B),

            inactiveThumbColor: Colors.white,

            inactiveTrackColor: isDarkMode
                ? const Color(0xFF555555)
                : const Color(0xFFD9D9D9),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION BAR
  // =========================================================

  Widget _buildBottomNavBar(bool isDarkMode) {
    final items = [
      _NavItemData(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItemData(
        icon: Icons.calendar_today_rounded,
        label: 'Daily Routine',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        label: 'Profile',
      ),
      _NavItemData(
        icon: Icons.settings_outlined,
        label: 'Settings',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,

          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? Colors.white12
                  : Colors.grey.shade200,
            ),
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: List.generate(
            items.length,
                (index) {
              final isSelected =
                  index == _selectedNavIndex;

              final color = isSelected
                  ? const Color(0xFF3FBE6B)
                  : isDarkMode
                  ? Colors.white60
                  : Colors.black45;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                },

                behavior:
                HitTestBehavior.opaque,

                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].icon,
                      size: 22,
                      color: color,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      items[index].label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                        FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// NAVIGATION ITEM MODEL
// ===========================================================

class _NavItemData {
  final IconData icon;
  final String label;

  _NavItemData({
    required this.icon,
    required this.label,
  });
}