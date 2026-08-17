import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _darkText = Color(0xFF1B1F1D);
  static const Color _grayText = Color(0xFF6B756E);
  static const Color _grayNav = Color(0xFF9AA29D);
  static const Color _borderColor = Color(0xFFE5EAE7);

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
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _infoRow(
                      'Evaluate potential fatty liver and cholesterol '
                          'risk based on your responses.',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      'Receive lifestyle suggestions based on your '
                          'assessment results.',
                    ),
                    const SizedBox(height: 12),
                    _infoRowRichText(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: const [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: _grayText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2026 HappyLiver',
                    style: TextStyle(
                      fontSize: 12,
                      color: _grayText,
                    ),
                  ),
                ],
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
            'About us',
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
  // LOGO + APP NAME
  // ================================================================
  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo-wrap.png',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        const Text(
          'HappyLiver',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Your Health, Your Awareness',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _darkText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // INFO ROWS
  // ================================================================
  Widget _infoRow(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 18,
            color: _darkText,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: _darkText,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowRichText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 18,
            color: _darkText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                ),
                children: [
                  TextSpan(
                    text: 'HappyLiver is an educational risk assessment '
                        'tool and ',
                  ),
                  TextSpan(
                    text: 'does not provide medical diagnosis or '
                        'treatment.',
                    style: TextStyle(color: Color(0xFFE3453A)),
                  ),
                ],
              ),
            ),
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
                selected: true,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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
                  // Navigate to Settings screen
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