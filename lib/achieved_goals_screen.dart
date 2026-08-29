import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

// ============================================================
// APP
// ============================================================

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomePage(),
          DailyRoutinePage(),
          ProfilePage(),
          SettingsPage(),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          _navItem(
            index: 1,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Daily Routine',
          ),
          _navItem(
            index: 2,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
          _navItem(
            index: 3,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool active = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: SizedBox(
        width: 78,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 23,
              color: active
                  ? const Color(0xFF20C85A)
                  : const Color(0xFF61736A),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? const Color(0xFF20C85A)
                    : const Color(0xFF61736A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AchievedGoalsPage(
        showBackButton: false,
      ),
    );
  }
}

// ============================================================
// ACHIEVED GOALS PAGE
// ============================================================

class AchievedGoalsPage extends StatelessWidget {
  final bool showBackButton;

  const AchievedGoalsPage({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ======================================================
        // TOP BAR
        // ======================================================

        _buildHeader(context),

        // ======================================================
        // BODY
        // ======================================================

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 18,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // Trophy
                  _buildTrophy(),

                  const SizedBox(height: 10),

                  // Congratulations
                  const Text(
                    'Congratulations !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'You have archive your weekly goals !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // WATER
                  // ==================================================

                  GoalCard(
                    title: 'Water intake',
                    valueText: '42 / 56 Glasses',
                    percentage: 75,
                    emoji: '💧',
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // WORKOUT
                  // ==================================================

                  GoalCard(
                    title: 'Workout',
                    valueText: '5 / 7 Days',
                    percentage: 85,
                    emoji: '🏃',
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // DIET
                  // ==================================================

                  GoalCard(
                    title: 'Diet',
                    valueText: '5 / 7 Days',
                    percentage: 70,
                    emoji: '🥗',
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SLEEP
                  // ==================================================

                  GoalCard(
                    title: 'Sleep',
                    valueText: '6 / 7 Days',
                    percentage: 87,
                    emoji: '😴',
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 49,
      width: double.infinity,
      color: const Color(0xFFDFF8D6),
      child: Row(
        children: [
          const SizedBox(width: 13),

          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              if (showBackButton &&
                  Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Text(
            'Achieved Goals',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TROPHY
  // ============================================================

  Widget _buildTrophy() {
    return SizedBox(
      width: 100,
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main trophy
          const Text(
            '🏆',
            style: TextStyle(
              fontSize: 73,
            ),
          ),

          // Small sparkle
          Positioned(
            left: 4,
            top: 13,
            child: Transform.rotate(
              angle: -0.3,
              child: const Text(
                '✦',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFFA600),
                ),
              ),
            ),
          ),

          Positioned(
            right: 4,
            top: 10,
            child: const Text(
              '✦',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFFA600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GOAL CARD
// ============================================================

class GoalCard extends StatelessWidget {
  final String title;
  final String valueText;
  final int percentage;
  final String emoji;

  const GoalCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.percentage,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFB8EEA7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ====================================================
          // TITLE
          // ====================================================

          Positioned(
            top: 7,
            left: 70,
            right: 70,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF303030),
              ),
            ),
          ),

          // ====================================================
          // CHECK CIRCLE
          // ====================================================

          Positioned(
            left: 20,
            top: 34,
            child: Container(
              width: 31,
              height: 31,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF18A957),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),

          // ====================================================
          // VALUE WHITE PILL
          // ====================================================

          Positioned(
            left: 77,
            right: 77,
            top: 34,
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35000000),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  valueText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // EMOJI / IMAGE
          // ====================================================

          Positioned(
            right: 10,
            top: 22,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 43,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // PERCENTAGE
          // ====================================================

          Positioned(
            left: 61,
            right: 72,
            bottom: 5,
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    '$percentage%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF194B20),
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor:
                      const Color(0xFF8A8A8A),
                      valueColor:
                      const AlwaysStoppedAnimation(
                        Color(0xFF32C965),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DAILY ROUTINE PAGE
// ============================================================

class DailyRoutinePage extends StatelessWidget {
  const DailyRoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Daily Routine',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
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
    return const SafeArea(
      child: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}