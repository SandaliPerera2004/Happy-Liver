import 'package:flutter/material.dart';

import 'services/weekly_report_service.dart';
import 'achieved_goals_page.dart';
import 'weekly_report_screen.dart' as report_screen;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  late final WeeklyReportService _reportService;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    _reportService = WeeklyReportService();

    pages = [
      HomePage(
        reportService: _reportService,
      ),
      const DietPage(),
      const WorkoutPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
      ),
      child: Row(
        children: [
          _navItem(
            Icons.home_outlined,
            Icons.home,
            'Home',
            0,
          ),
          _navItem(
            Icons.restaurant_menu_outlined,
            Icons.restaurant_menu,
            'Diet',
            1,
          ),
          _navItem(
            Icons.fitness_center_outlined,
            Icons.fitness_center,
            'Workout',
            2,
          ),
          _navItem(
            Icons.person_outline,
            Icons.person,
            'Profile',
            3,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      IconData activeIcon,
      String label,
      int index,
      ) {
    final bool active = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: SizedBox(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 24,
                color: active
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF60756A),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                  active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF60756A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME / EVALUATION
// ============================================================

class HomePage extends StatelessWidget {
  final WeeklyReportService reportService;

  const HomePage({
    super.key,
    required this.reportService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==================================================
                // WEEKLY REPORT
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return report_screen.WeeklyReportScreen(
                              service: reportService,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bar_chart,
                    ),
                    label: const Text(
                      'Weekly Report',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // ACHIEVED GOALS
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const AchievedGoalsPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.emoji_events_outlined,
                    ),
                    label: const Text(
                      'Achieved Goals',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F8D9),
                      foregroundColor: const Color(0xFF16713A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: Color(0xFF39C96B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIET PAGE
// ============================================================

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FFF9),
      body: SafeArea(
        child: Center(
          child: Text(
            'Diet Page',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WORKOUT PAGE
// ============================================================

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FFF9),
      body: SafeArea(
        child: Center(
          child: Text(
            'Workout Page',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE PAGE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FFF9),
      body: SafeArea(
        child: Center(
          child: Text(
            'Profile Page',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
