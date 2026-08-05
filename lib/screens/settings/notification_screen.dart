import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notifications Settings',
      theme: ThemeData(
        fontFamily: 'SF Pro Text',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NotificationsSettingsScreen(),
    );
  }
}

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _allowNotifications = true;
  bool _healthTips = true;
  bool _routineReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildToggleRow(
              label: 'Allow notifications',
              value: _allowNotifications,
              onChanged: (val) {
                setState(() => _allowNotifications = val);
              },
            ),
            _buildToggleRow(
              label: 'Health Tips',
              value: _healthTips,
              onChanged: (val) {
                setState(() => _healthTips = val);
              },
            ),
            _buildToggleRow(
              label: 'Routine Reminder',
              value: _routineReminder,
              onChanged: (val) {
                setState(() => _routineReminder = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFDFF3DF), // light green background
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: SvgPicture.asset(
                'assets/icons/Arrow left-circle.svg', // exact file name, underscore not space
                width: 24,
                height: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(
            // Replace with NetworkImage/AssetImage for a real profile photo
              'assets/images/profile_image.png',
          ),
        ),
       ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF34C759), // iOS-style green
          ),
        ],
      ),
    );
  }
}