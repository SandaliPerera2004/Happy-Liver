import 'package:flutter/material.dart';
import 'models/risk_level.dart';
import 'assessment_firestore_service.dart';
import 'ai_chatbot.dart';
import 'main.dart';

class RecommendationsScreen extends StatefulWidget {
  final AssessmentResult? result;

  const RecommendationsScreen({super.key, this.result});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  AssessmentResult? _result;
  String _userName = 'Shehani';

  @override
  void initState() {
    super.initState();
    if (widget.result != null) {
      _result = widget.result;
      _loadUserName();
    } else {
      _loadData();
    }
  }

  Future<void> _loadUserName() async {
    final name = await AssessmentFirestoreService.getUserDisplayName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadData() async {
    final name = await AssessmentFirestoreService.getUserDisplayName();
    final res = await AssessmentFirestoreService.getLatestAssessment();
    if (mounted) {
      setState(() {
        _userName = name;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    final fattyLiverRisk = _result?.fattyLiverRisk ?? RiskLevel.moderate;
    final cholesterolRisk = _result?.cholesterolRisk ?? RiskLevel.low;
    final isHighRisk = fattyLiverRisk == RiskLevel.high || cholesterolRisk == RiskLevel.high;
    final isModerateRisk = fattyLiverRisk == RiskLevel.moderate || cholesterolRisk == RiskLevel.moderate;

    // 1. MEALS RECOMMENDATION (2-3 lines tailored to risk)
    String mealsTitle = 'Balanced Liver-Friendly Diet';
    String mealsSubtitle = 'Eat more vegetables, whole grains, lean proteins, and fresh fruits.\nLimit fried foods and refined sugar to reduce liver stress.';
    if (isHighRisk) {
      mealsTitle = 'Targeted Low-Fat & Clean Diet';
      mealsSubtitle = 'Eliminate deep-fried foods, red meat, and excess saturated fats.\nFill half your plate with green vegetables, legumes, and whole grains.';
    } else if (!isModerateRisk) {
      mealsTitle = 'Nutrient-Dense Maintenance Diet';
      mealsSubtitle = 'Maintain your balanced plate with leafy greens, legumes, and fresh fruit.\nKeep choosing high-fiber, lean protein sources for vitality.';
    }

    // 2. HYDRATION RECOMMENDATION (2-3 lines tailored to risk)
    String hydrationTitle = 'Optimal Fluid & Detox Intake';
    String hydrationSubtitle = 'Drink 8–10 glasses of water throughout the day.\nSwap sugary sodas with green tea, warm lemon water, or herbal teas.';
    if (isHighRisk) {
      hydrationTitle = 'Strict Detox Hydration';
      hydrationSubtitle = 'Drink 2.5–3 liters of pure water daily to flush metabolic waste.\nCompletely avoid alcohol, sodas, and sweetened energy drinks.';
    } else if (!isModerateRisk) {
      hydrationTitle = 'Daily Hydration Routine';
      hydrationSubtitle = 'Keep sipping 2–2.5L of water daily to maintain metabolic balance.\nAdequate hydration supports natural liver and kidney detoxification.';
    }

    // 3. SLEEP RECOMMENDATION (2-3 lines tailored to risk)
    String sleepTitle = 'Circadian Balance & Recovery';
    String sleepSubtitle = 'Sleep 7–9 hours each night and maintain a regular sleep schedule.\nQuality rest optimizes nocturnal liver repair and enzyme regulation.';
    if (isHighRisk) {
      sleepTitle = 'Restorative Nocturnal Recovery';
      sleepSubtitle = 'Ensure 7–9 hours of deep sleep and avoid screen time before bed.\nFinish dinner 3 hours prior to sleeping to aid overnight liver renewal.';
    } else if (!isModerateRisk) {
      sleepTitle = 'Healthy Rest & Recovery';
      sleepSubtitle = 'Continue getting 7–9 hours of sleep on a regular schedule.\nConsistent rest helps sustain healthy metabolic functions and energy.';
    }

    // 4. SUPPLEMENTS / LIFESTYLE RECOMMENDATION (2-3 lines tailored to risk)
    String supplementsTitle = 'Essential Nutrients & Omega-3';
    String supplementsSubtitle = 'Incorporate Omega-3 rich foods like chia seeds, walnuts, and fish.\nEngage in 30 minutes of moderate activity 3–4 days weekly.';
    if (isHighRisk) {
      supplementsTitle = 'Clinical Care & Essential Nutrients';
      supplementsSubtitle = 'Discuss Omega-3 and Vitamin E supplementation with your doctor.\nIncorporate daily brisk walking or low-impact cardio into your routine.';
    } else if (!isModerateRisk) {
      supplementsTitle = 'Essential Nutrients & Wellness';
      supplementsSubtitle = 'Keep nourishing your body with natural vitamins and antioxidant foods.\nMaintain your daily physical movement and healthy active lifestyle.';
    }

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
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_circle_left_outlined,
                      color: Color(0xFF146B0B),
                      size: 32,
                    ),
                    onPressed: () {
                      if (canPop) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainNavigationScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $_userName 👋',
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
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
                children: [
                  // Modern AI Assistant Hero Card
                  _buildAiHeroBanner(context),
                  const SizedBox(height: 16),

                  // Display recommendation cards with personalized 2-3 line guidance
                  _buildModernCard(
                    icon: Icons.restaurant_menu_rounded,
                    assetImagePath: 'assets/images/meal_image.png',
                    accentColor: const Color(0xFF2E7D32),
                    lightColor: const Color(0xFFE8F5E9),
                    tag: 'MEALS',
                    title: mealsTitle,
                    subtitle: mealsSubtitle,
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.water_drop_rounded,
                    assetImagePath: 'assets/images/hydration_image.png',
                    accentColor: const Color(0xFF0288D1),
                    lightColor: const Color(0xFFE1F5FE),
                    tag: 'HYDRATION',
                    title: hydrationTitle,
                    subtitle: hydrationSubtitle,
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.bedtime_rounded,
                    assetImagePath: 'assets/images/sleep_image.png',
                    accentColor: const Color(0xFF5E35B1),
                    lightColor: const Color(0xFFEDE7F6),
                    tag: 'SLEEP',
                    title: sleepTitle,
                    subtitle: sleepSubtitle,
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    icon: Icons.sanitizer_rounded,
                    assetImagePath: 'assets/images/vitamin_image.png',
                    accentColor: const Color(0xFFE65100),
                    lightColor: const Color(0xFFFFF3E0),
                    tag: 'SUPPLEMENTS',
                    title: supplementsTitle,
                    subtitle: supplementsSubtitle,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainNavigationScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF146B0B),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: "Daily Routine",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: "Settings",
            ),
          ],
        ),
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
              'assets/images/chatbot.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
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
                MaterialPageRoute(builder: (context) => const AiChatbotScreen()),
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
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}