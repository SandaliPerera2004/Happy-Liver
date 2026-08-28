import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/assessment_firestore_service.dart';
import '../../services/personalized_recommendation_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import '../settings/settings.dart';
import '../ai_chatbot/ai_chatbot_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  final int? fattyLiverScore;
  final int? cholesterolScore;
  final String? fattyLiverStatus;
  final String? cholesterolStatus;
  final int? overallRiskScore;
  final String? overallRiskStatus;

  const RecommendationsScreen({
    super.key,
    this.fattyLiverScore,
    this.cholesterolScore,
    this.fattyLiverStatus,
    this.cholesterolStatus,
    this.overallRiskScore,
    this.overallRiskStatus,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _username = '';
  int _fattyLiverScore = 0;
  int _cholesterolScore = 0;
  String _fattyLiverStatus = '';
  String _cholesterolStatus = '';
  int _overallRiskScore = 0;
  String _overallRiskStatus = '';

  @override
  void initState() {
    super.initState();
    _fattyLiverScore = widget.fattyLiverScore ?? 0;
    _cholesterolScore = widget.cholesterolScore ?? 0;
    _fattyLiverStatus = widget.fattyLiverStatus ?? '';
    _cholesterolStatus = widget.cholesterolStatus ?? '';
    _overallRiskScore = widget.overallRiskScore ?? 0;
    _overallRiskStatus = widget.overallRiskStatus ?? '';
    _fetchUsername();

    if (_fattyLiverStatus.isEmpty || _cholesterolStatus.isEmpty) {
      _fetchLatestAssessment();
    }
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

  Future<void> _fetchLatestAssessment() async {
    try {
      final doc = await AssessmentFirestoreService.getLatestAssessment();
      if (doc != null && doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final flScore = (data['fattyLiverScore'] as num?)?.toInt();
        final chScore = (data['cholesterolScore'] as num?)?.toInt();
        final flMax = (data['fattyLiverMaxScore'] as num?)?.toInt();
        final chMax = (data['cholesterolMaxScore'] as num?)?.toInt();
        final flRisk = data['fattyLiverRisk'] as String?;
        final chRisk = data['cholesterolRisk'] as String?;

        int finalFl = flScore ?? 0;
        if (flScore != null && flMax != null && flMax > 0 && flScore <= flMax) {
          finalFl = ((flScore / flMax) * 100).round();
        }

        int finalCh = chScore ?? 0;
        if (chScore != null && chMax != null && chMax > 0 && chScore <= chMax) {
          finalCh = ((chScore / chMax) * 100).round();
        }

        String flStatus = _deriveStatus(finalFl, flRisk);
        String chStatus = _deriveStatus(finalCh, chRisk);

        final overall = ((finalFl + finalCh) / 2).round().clamp(0, 100);
        String overallStatus = overall < 35
            ? 'Low Risk'
            : (overall < 70 ? 'Moderate Risk' : 'High Risk');

        if (mounted) {
          setState(() {
            _fattyLiverScore = finalFl;
            _cholesterolScore = finalCh;
            _fattyLiverStatus = flStatus;
            _cholesterolStatus = chStatus;
            _overallRiskScore = overall;
            _overallRiskStatus = overallStatus;
          });
        }
      }
    } catch (_) {}
  }

  String _deriveStatus(int score, String? riskName) {
    if (riskName != null && riskName.isNotEmpty) {
      if (riskName.toLowerCase() == 'high') return 'High';
      if (riskName.toLowerCase() == 'moderate') return 'Moderate';
      if (riskName.toLowerCase() == 'low') return 'Low';
    }
    if (score < 35) return 'Low';
    if (score < 70) return 'Moderate';
    return 'High';
  }

  String get effectiveFattyLiverStatus {
    if (_fattyLiverStatus.isNotEmpty) return _fattyLiverStatus;
    if (_fattyLiverScore < 35) return 'Low';
    if (_fattyLiverScore < 70) return 'Moderate';
    return 'High';
  }

  String get effectiveCholesterolStatus {
    if (_cholesterolStatus.isNotEmpty) return _cholesterolStatus;
    if (_cholesterolScore < 35) return 'Low';
    if (_cholesterolScore < 70) return 'Moderate';
    return 'High';
  }

  String get effectiveOverallStatus {
    if (_overallRiskStatus.isNotEmpty) return _overallRiskStatus;
    final score = _overallRiskScore > 0
        ? _overallRiskScore
        : ((_fattyLiverScore + _cholesterolScore) / 2).round();
    if (score < 35) return 'Low Risk';
    if (score < 70) return 'Moderate Risk';
    return 'High Risk';
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
    final flStatus = effectiveFattyLiverStatus;
    final chStatus = effectiveCholesterolStatus;
    final overallStatus = effectiveOverallStatus;

    final cards = PersonalizedRecommendationService.getPersonalizedRecommendations(
      fattyLiverStatus: flStatus,
      cholesterolStatus: chStatus,
      overallRiskStatus: overallStatus,
      fattyLiverScore: _fattyLiverScore,
      cholesterolScore: _cholesterolScore,
      overallScore: _overallRiskScore,
    );

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
                        'Your Personalized Liver Care Plan • Today',
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

                  // Display the 4 Personalized Cards: MEALS, HYDRATION, SLEEP, SUPPLEMENTS
                  for (final card in cards) ...[
                    _buildModernCard(card),
                    const SizedBox(height: 16),
                  ],

                  // Medical Disclaimer Note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD3EAD5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'These personalized suggestions are based on your lifestyle assessment to help you protect your liver. Always consult a physician for diagnostic or clinical treatment plans.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.black.withAlpha(150),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildRiskPill(String label, String status) {
    Color bg;
    Color text;
    final s = status.toLowerCase();
    if (s.contains('high')) {
      bg = const Color(0xFFFFEBEE);
      text = const Color(0xFFC62828);
    } else if (s.contains('mod')) {
      bg = const Color(0xFFFFF3E0);
      text = const Color(0xFFE65100);
    } else {
      bg = const Color(0xFFE8F5E9);
      text = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text.withAlpha(200),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Health Assistant',
                      style: TextStyle(
                        fontSize: 15.5,
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
                const SizedBox(height: 3),
                Text(
                  'Have questions about your meals or supplements? Ask AI instantly.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Ask AI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(RecommendationCardData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EDE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.lightColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  data.assetImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(data.icon, color: data.accentColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.tag,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: data.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18321F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF5A665D),
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          if (data.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5EFE4)),
              ),
              child: Column(
                children: data.bulletPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: data.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E30),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
