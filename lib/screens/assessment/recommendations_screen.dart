import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import '../settings/settings.dart';
import '../ai_chatbot/ai_chatbot_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final name = data['username'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            if (mounted) {
              setState(() {
                _username = name.trim();
              });
            }
            return;
          }
        }

        if (mounted) {
          setState(() {
            _username = user.displayName ?? 'User';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _username = 'User';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _username = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        });
      }
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AssessmentResultScreen()),
      );
      return;
    }

    switch (index) {
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _username.isNotEmpty ? _username : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Colored header area ONLY - below safe area
            Container(
              color: const Color(0xFFE5F8D8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $displayName 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF18321F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Your Liver Care Recommendations • Today',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF5A665D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable list content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
                children: [
                  // Modern AI Assistant Hero Card
                  _buildAiHeroBanner(context),
                  const SizedBox(height: 16),
                  // Display recommendation cards
                  _buildModernCard(
                    icon: Icons.restaurant_menu_rounded,
                    assetImagePath: 'assets/images/meal_image.png',
                    accentColor: const Color(0xFF2E7D32),
                    lightColor: const Color(0xFFE8F5E9),
                    tag: 'MEALS',
                    title: 'Balanced Liver-Friendly Diet',
                    subtitle:
                        'Eat more vegetables, whole grains, lean proteins, and fresh fruits.',
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.water_drop_rounded,
                    assetImagePath: 'assets/images/hydration_image.png',
                    accentColor: const Color(0xFF0288D1),
                    lightColor: const Color(0xFFE1F5FE),
                    tag: 'HYDRATION',
                    title: 'Optimal Fluid & Detox Intake',
                    subtitle:
                        'Drink enough water throughout the day and limit sugary drinks',
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.bedtime_rounded,
                    assetImagePath: 'assets/images/sleep_image.png',
                    accentColor: const Color(0xFF5E35B1),
                    lightColor: const Color(0xFFEDE7F6),
                    tag: 'SLEEP',
                    title: 'Circadian Balance & Recovery',
                    subtitle:
                        'Sleep 7–9 hours each night and maintain a regular sleep schedule.',
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.sanitizer_rounded,
                    assetImagePath: 'assets/images/vitamin_image.png',
                    accentColor: const Color(0xFFE65100),
                    lightColor: const Color(0xFFFFF3E0),
                    tag: 'SUPPLEMENTS',
                    title: 'Essential Nutrients & Omega-3',
                    subtitle: 'Take recommended supplements when needed.',
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildAiHeroBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCFF7D3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0EBE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(
              'assets/images/chatbot.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFF146B0B),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Health Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2D1F),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Get personalized answers for your liver health care instantly.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiChatbotScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF146B0B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Ask AI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required IconData icon,
    String? assetImagePath,
    required Color accentColor,
    required Color lightColor,
    required String tag,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Row
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: assetImagePath != null
                    ? Image.asset(
                        assetImagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(icon, color: accentColor, size: 24),
                      )
                    : Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2D1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}