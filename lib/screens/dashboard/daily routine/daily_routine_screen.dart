import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../profile_screen.dart';
import 'package:happy_liver/diet_plan_screen.dart';
import 'workout_plan_screen.dart';
import '../../../../widgets/bottom_navigation_bar.dart';
import '../../../../services/assessment_firestore_service.dart';
import '../../../../models/risk_level.dart';

class DailyRoutineScreen extends StatefulWidget {
  final bool isDarkMode;

  // Used when opening Settings from the shared bottom navigation.
  final Future<void> Function(bool) onThemeChanged;

  const DailyRoutineScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<DailyRoutineScreen> createState() =>
      _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _cardBg = Color(0xFFEAF7E9);
  static const Color _darkText = Color(0xFF1B3B1F);
  static const Color _grayText = Color(0xFF6B756E);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

  String _riskLevel = 'Low';
  bool _isLoadingRisk = true;

  @override
  void initState() {
    super.initState();
    _loadRiskLevel();
  }

  Future<void> _loadRiskLevel() async {
    try {
      final AssessmentResult? latestResult =
      await AssessmentFirestoreService.getLatestAssessmentResult();

      if (!mounted) return;

      if (latestResult == null) {
        setState(() {
          _riskLevel = 'Low';
          _isLoadingRisk = false;
        });
        return;
      }

      final RiskLevel overallRisk;

      if (latestResult.fattyLiverRisk == RiskLevel.high ||
          latestResult.cholesterolRisk == RiskLevel.high) {
        overallRisk = RiskLevel.high;
      } else if (latestResult.fattyLiverRisk == RiskLevel.moderate ||
          latestResult.cholesterolRisk == RiskLevel.moderate) {
        overallRisk = RiskLevel.moderate;
      } else {
        overallRisk = RiskLevel.low;
      }

      setState(() {
        _riskLevel = _riskLevelToString(overallRisk);
        _isLoadingRisk = false;
      });

      debugPrint('====================================');
      debugPrint('DAILY ROUTINE RISK');
      debugPrint('Fatty Liver: ${latestResult.fattyLiverRisk}');
      debugPrint('Cholesterol: ${latestResult.cholesterolRisk}');
      debugPrint('Overall Risk: $_riskLevel');
      debugPrint('====================================');
    } catch (e) {
      debugPrint('ERROR LOADING DAILY ROUTINE RISK: $e');

      if (!mounted) return;

      setState(() {
        _riskLevel = 'Low';
        _isLoadingRisk = false;
      });
    }
  }

  String _riskLevelToString(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.high:
        return 'High';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? _darkBackground
          : const Color(0xFFF5F6F8),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(),

                    const SizedBox(height: 24),

                    // =================================================
                    // DIET PLAN
                    // =================================================

                    _routineCard(
                      context: context,
                      imageAsset: 'assets/images/Food bowl 1.png',
                      title: 'Diet Plan',
                      description:
                      'Explore healthy meal plans tailored for you.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DietPlanScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // WORKOUT PLAN
                    // =================================================

                    _routineCard(
                      context: context,
                      imageAsset: 'assets/images/watter bottle 1.png',
                      title: 'Workout Plan',
                      description:
                      'Discover effective workouts to keep you active.',
                      onTap: () {
                        if (_isLoadingRisk) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Loading your workout plan...',
                              ),
                            ),
                          );
                          return;
                        }

                        debugPrint(
                          'OPENING WORKOUT PLAN WITH RISK: $_riskLevel',
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutPlanScreen(
                              riskLevel: _riskLevel,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: HappyLiverBottomNavBar(
        selectedIndex: 1,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      color: _lightGreenHeader,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.maybePop(context);
            },
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Daily Routine',
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

  Widget _buildHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Small steps everyday leads to big results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.35,
              color: _green,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Image.asset(
          'assets/images/daily.png',
          width: 120,
          height: 120,
        ),
      ],
    );
  }

  Widget _routineCard({
    required BuildContext context,
    required String imageAsset,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? _darkCard : _cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.isDarkMode
                          ? Colors.white
                          : _darkText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: widget.isDarkMode
                          ? Colors.white70
                          : _grayText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/right arrow.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}