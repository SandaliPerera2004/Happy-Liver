import 'package:flutter/material.dart';

import '../../models/risk_level.dart';
import '../../services/assessment_firestore_service.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'ai_chatbot.dart';

class RecommendationsScreen extends StatefulWidget {
  final AssessmentResult result;

  const RecommendationsScreen({super.key, required this.result});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _userName = 'Shehani';

  RiskLevel _fattyLiverRisk = RiskLevel.low;
  RiskLevel _cholesterolRisk = RiskLevel.low;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Use the result passed from the Assessment Result screen
    _fattyLiverRisk = widget.result.fattyLiverRisk;
    _cholesterolRisk = widget.result.cholesterolRisk;

    _loadRecommendationData();
  }

  // =========================================================
  // LOAD USER NAME + LATEST ASSESSMENT
  // =========================================================

  Future<void> _loadRecommendationData() async {
    try {
      final userName = await _getUserDisplayName();

      if (!mounted) return;

      setState(() {
        _userName = userName;
        _isLoading = false;
      });

      // The AssessmentResult passed from the assessment screen
      // is the main source for recommendation risk levels.
      //
      // We do not need to replace it with another Firestore
      // document here.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // GET USER DISPLAY NAME
  // =========================================================

  Future<String> _getUserDisplayName() async {
    try {
      final user = AssessmentFirestoreService.currentUser;

      if (user == null) {
        return 'Shehani';
      }

      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        return user.displayName!.trim();
      }

      return 'Shehani';
    } catch (_) {
      return 'Shehani';
    }
  }

  // =========================================================
  // CHECK HIGH / MODERATE RISK
  // =========================================================

  bool get _isHighRisk {
    return _fattyLiverRisk == RiskLevel.high ||
        _cholesterolRisk == RiskLevel.high;
  }

  bool get _isModerateRisk {
    return _fattyLiverRisk == RiskLevel.moderate ||
        _cholesterolRisk == RiskLevel.moderate;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),

      // =======================================================
      // YOUR CUSTOM HEADER
      // =======================================================
      appBar: const CustomHeader(title: 'Recommendations', showBack: true),

      // =======================================================
      // BODY
      // =======================================================
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF146B0B)),
              )
            : ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                children: [
                  _buildAiHeroBanner(),

                  const SizedBox(height: 12),

                  _buildModernCard(
                    icon: Icons.restaurant_menu_rounded,
                    assetImagePath: 'assets/images/meal_image.png',
                    accentColor: const Color(0xFF2E7D32),
                    lightColor: const Color(0xFFE8F5E9),
                    tag: 'MEALS',
                    title: _mealsTitle(),
                    subtitle: _mealsSubtitle(),
                  ),

                  const SizedBox(height: 12),

                  _buildModernCard(
                    icon: Icons.water_drop_rounded,
                    assetImagePath: 'assets/images/hydration_image.png',
                    accentColor: const Color(0xFF0288D1),
                    lightColor: const Color(0xFFE1F5FE),
                    tag: 'HYDRATION',
                    title: _hydrationTitle(),
                    subtitle: _hydrationSubtitle(),
                  ),

                  const SizedBox(height: 12),

                  _buildModernCard(
                    icon: Icons.bedtime_rounded,
                    assetImagePath: 'assets/images/sleep_image.png',
                    accentColor: const Color(0xFF5E35B1),
                    lightColor: const Color(0xFFEDE7F6),
                    tag: 'SLEEP',
                    title: _sleepTitle(),
                    subtitle: _sleepSubtitle(),
                  ),

                  const SizedBox(height: 12),

                  _buildModernCard(
                    icon: Icons.sanitizer_rounded,
                    assetImagePath: 'assets/images/vitamin_image.png',
                    accentColor: const Color(0xFFE65100),
                    lightColor: const Color(0xFFFFF3E0),
                    tag: 'SUPPLEMENTS',
                    title: _supplementsTitle(),
                    subtitle: _supplementsSubtitle(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
      ),

      // =======================================================
      // YOUR SHARED BOTTOM NAVIGATION BAR
      // =======================================================
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  // =========================================================
  // MEALS RECOMMENDATION
  // =========================================================

  String _mealsTitle() {
    if (_isHighRisk) {
      return 'Targeted Low-Fat & Clean Diet';
    }

    if (!_isModerateRisk) {
      return 'Nutrient-Dense Maintenance Diet';
    }

    return 'Balanced Liver-Friendly Diet';
  }

  String _mealsSubtitle() {
    if (_isHighRisk) {
      return 'Reduce deep-fried foods, red meat, and excess saturated fats.\n'
          'Fill half your plate with vegetables, legumes, and whole grains.';
    }

    if (!_isModerateRisk) {
      return 'Maintain a balanced plate with leafy greens, legumes, and fresh fruit.\n'
          'Choose high-fiber foods and lean protein sources.';
    }

    return 'Eat more vegetables, whole grains, lean proteins, and fresh fruits.\n'
        'Limit fried foods and refined sugar to support liver health.';
  }

  // =========================================================
  // HYDRATION RECOMMENDATION
  // =========================================================

  String _hydrationTitle() {
    if (_isHighRisk) {
      return 'Healthy Hydration Routine';
    }

    if (!_isModerateRisk) {
      return 'Daily Hydration Routine';
    }

    return 'Optimal Hydration';
  }

  String _hydrationSubtitle() {
    if (_isHighRisk) {
      return 'Drink water regularly throughout the day and avoid sugary drinks.\n'
          'Choose water instead of sodas and sweetened beverages.';
    }

    if (!_isModerateRisk) {
      return 'Keep drinking around 2–2.5L of water daily, depending on your needs.\n'
          'Good hydration supports overall health and daily energy.';
    }

    return 'Drink water regularly throughout the day.\n'
        'Replace sugary sodas and sweetened drinks with water or unsweetened beverages.';
  }

  // =========================================================
  // SLEEP RECOMMENDATION
  // =========================================================

  String _sleepTitle() {
    if (_isHighRisk) {
      return 'Restorative Sleep & Recovery';
    }

    if (!_isModerateRisk) {
      return 'Healthy Rest & Recovery';
    }

    return 'Healthy Sleep Routine';
  }

  String _sleepSubtitle() {
    if (_isHighRisk) {
      return 'Aim for 7–9 hours of sleep each night and keep a consistent bedtime.\n'
          'Reduce screen time before bed to support better sleep.';
    }

    if (!_isModerateRisk) {
      return 'Continue getting 7–9 hours of sleep on a regular schedule.\n'
          'Consistent rest supports healthy energy and daily routines.';
    }

    return 'Aim for 7–9 hours of sleep each night and maintain a regular schedule.\n'
        'Good-quality sleep supports overall metabolic health.';
  }

  // =========================================================
  // SUPPLEMENTS / LIFESTYLE
  // =========================================================

  String _supplementsTitle() {
    if (_isHighRisk) {
      return 'Healthy Lifestyle & Nutrients';
    }

    if (!_isModerateRisk) {
      return 'Essential Nutrients & Wellness';
    }

    return 'Essential Nutrients & Omega-3';
  }

  String _supplementsSubtitle() {
    if (_isHighRisk) {
      return 'Choose nutrient-rich foods such as fish, nuts, seeds, and vegetables.\n'
          'Consider regular walking or other suitable physical activity.';
    }

    if (!_isModerateRisk) {
      return 'Continue choosing natural vitamin- and antioxidant-rich foods.\n'
          'Maintain regular physical activity and a healthy lifestyle.';
    }

    return 'Include Omega-3-rich foods such as fish, chia seeds, and walnuts.\n'
        'Aim for regular moderate physical activity as part of your routine.';
  }

  // =========================================================
  // AI HERO BANNER
  // =========================================================

  Widget _buildAiHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCFF7D3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0EBE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
              'assets/images/chatbot1.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF0C370D),
                  size: 32,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'AI Health Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D1F),
                        ),
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

          const SizedBox(width: 5),

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
              'ASK AI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RECOMMENDATION CARD
  // =========================================================

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
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(icon, color: accentColor, size: 24);
                        },
                      )
                    : Icon(icon, color: accentColor, size: 22),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: accentColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2D1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
