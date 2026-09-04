import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_liver/services/achieved_goals_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class AchievedGoalsPage extends StatefulWidget {
  const AchievedGoalsPage({super.key});

  @override
  State<AchievedGoalsPage> createState() => _AchievedGoalsPageState();
}

class _AchievedGoalsPageState extends State<AchievedGoalsPage> {
  final AchievedGoalsService service = AchievedGoalsService();
  Future<AchievedGoalsData>? goalsFuture;

  @override
  void initState() {
    super.initState();
    goalsFuture = service.getWeeklyGoals();
  }

  void refreshGoals() {
    setState(() {
      goalsFuture = service.getWeeklyGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor:
            isDarkMode ? const Color(0xFF121212) : Colors.white,
            statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
            isDarkMode ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF121212)
                : const Color(0xFFF9FFFA),

            body: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(context, isDarkMode),

                  Expanded(
                    child: FutureBuilder<AchievedGoalsData>(
                      future: goalsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF39C96B),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Error: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Text(
                              'No goal data available',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          );
                        }

                        final data = snapshot.data!;

                        return RefreshIndicator(
                          color: const Color(0xFF39C96B),
                          backgroundColor: isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          onRefresh: () async {
                            refreshGoals();

                            if (goalsFuture != null) {
                              await goalsFuture;
                            }
                          },
                          child: ListView(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              30,
                            ),
                            children: [
                              const Center(
                                child: Text(
                                  '🏆',
                                  style: TextStyle(fontSize: 58),
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Center(
                                child: Text(
                                  'Congratulations !',
                                  style: TextStyle(
                                    color: Color(0xFF39C96B),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Center(
                                child: Text(
                                  'You have archive your weekly goals !',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // WATER INTAKE
                              GoalCard(
                                title: 'Water intake',
                                valueText:
                                '${data.waterGlasses} / ${data.waterTargetGlasses} Glasses',
                                percentage: data.waterPercentage,
                                imageAsset: 'assets/images/water.png',
                                icon: Icons.water_drop_rounded,
                                iconColor: const Color(0xFF2196F3),
                                iconBackground: const Color(0xFFE1F2FF),
                                cardColor: const Color(0xFFC3FFC7),
                                cardColorEnd:
                                const Color(0xFF4CAF50),
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // WORKOUT
                              GoalCard(
                                title: 'Workout',
                                valueText:
                                '${data.workoutCompletedDays} / 7 Days',
                                percentage: data.workoutPercentage,
                                imageAsset: 'assets/images/workout.png',
                                icon: Icons.directions_run_rounded,
                                iconColor: const Color(0xFFFF8A00),
                                iconBackground: const Color(0xFFFFEBD6),
                                cardColor: const Color(0xFFC3FFC7),
                                cardColorEnd:
                                const Color(0xFF4CAF50),
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 16),

                              // DIET
                              GoalCard(
                                title: 'Diet',
                                valueText:
                                '${data.dietCompletedDays} / 7 Days',
                                percentage: data.dietPercentage,
                                imageAsset: 'assets/images/diet.png',
                                icon: Icons.restaurant_rounded,
                                iconColor: const Color(0xFF39A852),
                                iconBackground:
                                const Color(0xFFE1F7E5),
                                cardColor: const Color(0xFFC3FFC7),
                                cardColorEnd:
                                const Color(0xFF4CAF50),
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM NAVIGATION
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              selectedItemColor: const Color(0xFF39C96B),
              unselectedItemColor:
              isDarkMode ? Colors.white60 : Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Daily Routine',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1B3B1F)
            : const Color(0xFFDDF7D2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
              colorFilter: isDarkMode
                  ? const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Achieved Goals',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final String title;
  final String valueText;
  final int percentage;
  final String imageAsset;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color cardColor;
  final Color cardColorEnd;
  final bool isDarkMode;

  const GoalCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.percentage,
    required this.imageAsset,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cardColor,
    required this.cardColorEnd,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // CARD GRADIENT
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColorEnd,
          ],
        ),

        // STROKE / BORDER
        border: Border.all(
          color: const Color(0xFF087E0E),
          width: 1.5,
        ),

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              imageAsset,
              width: 46,
              height: 46,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  valueText,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor:
                    const Color(0xFFD9EEDC),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      Color(0xFF136319),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '$percentage%',
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}