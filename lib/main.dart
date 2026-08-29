import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
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

  final List<Widget> pages = const [
    HomePage(),
    DietPage(),
    WorkoutPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _navItem(
            icon: Icons.restaurant_menu_outlined,
            activeIcon: Icons.restaurant_menu,
            label: 'Diet',
            index: 1,
          ),
          _navItem(
            icon: Icons.fitness_center_outlined,
            activeIcon: Icons.fitness_center,
            label: 'Workout',
            index: 2,
          ),
          _navItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: SizedBox(
        width: 75,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 70,
              color: Color(0xFF22C55E),
            ),
            const SizedBox(height: 15),
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // WEEKLY REPORT
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const WeeklyReportScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('Weekly Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB7F2CB),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
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
    return const SafeArea(
      child: Center(
        child: Text(
          'Diet Page',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
    return const SafeArea(
      child: Center(
        child: Text(
          'Workout Page',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
          'Profile Page',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WEEKLY REPORT SCREEN
// ============================================================

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Container(
              height: 50,
              color: const Color(0xFFDFF7D5),
              padding:
              const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Weekly Report',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.download,
                    size: 28,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 7),

                    _dateSelector(),

                    const SizedBox(height: 7),

                    _weekOverview(),

                    const SizedBox(height: 10),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 11),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _dietSummary(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _workoutSummary(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    _weeklyProgress(),

                    const SizedBox(height: 3),

                    _tipOfWeek(),
                  ],
                ),
              ),
            ),

            // ==================================================
            // REPORT BOTTOM NAV
            // ==================================================
            _reportBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _dateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '<',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Aug 10 – Aug 16',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '>',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEK OVERVIEW
  // ============================================================

  Widget _weekOverview() {
    final days = [
      ['MON', '10'],
      ['TUE', '11'],
      ['WED', '12'],
      ['THU', '13'],
      ['FRI', '14'],
      ['SAT', '15'],
      ['SUN', '16'],
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 7,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFFA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE8F4E8),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 25,
            decoration: BoxDecoration(
              color: const Color(0xFFD7F8E2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '▣',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Week Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return Column(
                children: [
                  Text(
                    day[0],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    day[1],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Icon(
                    Icons.fitness_center,
                    size: 19,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '🥗',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIET SUMMARY
  // ============================================================

  Widget _dietSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 7, 5, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE6F0E8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle(
            icon: '📋',
            title: 'Diet Summary',
          ),

          const SizedBox(height: 8),

          // DIET PLAN
          Container(
            height: 66,
            padding:
            const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F8E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diet Plan Followed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '5/7 days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _progressCircle(70),
              ],
            ),
          ),

          const SizedBox(height: 7),

          // HEALTHY CHOICES
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Healthy Choices',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(20),
                        child:
                        const LinearProgressIndicator(
                          value: .84,
                          minHeight: 6,
                          backgroundColor:
                          Color(0xFFD4D4D4),
                          valueColor:
                          AlwaysStoppedAnimation(
                            Color(0xFF2BC15A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '84%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          // AVERAGE CALORIES
          Container(
            height: 96,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Calories',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      '1630',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      ' kcal/day',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '🔥',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: CustomPaint(
                    painter: CaloriesChartPainter(),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT SUMMARY
  // ============================================================

  Widget _workoutSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 7, 5, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE6F0E8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle(
            icon: '📋',
            title: 'Workout Summary',
          ),

          const SizedBox(height: 8),

          // WORKOUT COMPLETED
          Container(
            height: 66,
            padding:
            const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F8E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workouts',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '5/7 days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _progressCircle(70),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Total workout',
                  '04',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _smallStat(
                  'Total Duration',
                  '540min',
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Total calories',
                  '1260 kcal',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _smallStat(
                  'Avg.Intensity',
                  'Moderate',
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Container(
            height: 96,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: WorkoutChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required String icon,
    required String title,
  }) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFB7F2CB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CIRCLE PROGRESS
  // ============================================================

  Widget _progressCircle(int percentage) {
    return SizedBox(
      width: 51,
      height: 51,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor:
            const Color(0xFFD5D5D5),
            valueColor:
            const AlwaysStoppedAnimation(
              Color(0xFF2CBD59),
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF258847),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL STAT
  // ============================================================

  Widget _smallStat(
      String title,
      String value,
      ) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F9E9),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  Widget _weeklyProgress() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        12,
        15,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Text(
                '📊',
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(width: 5),
              Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'You improved +12% Compared to last week',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIP OF THE WEEK
  // ============================================================

  Widget _tipOfWeek() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        9,
        15,
        13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏅',
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(width: 5),
              Text(
                'Tip of the week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Great job! you're consistent this week\n"
                  'Try to increase your workout time on weekends',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT BOTTOM NAVIGATION
  // ============================================================

  Widget _reportBottomNavigation() {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE6E6E6),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          _reportNavItem(
            icon: Icons.home_outlined,
            title: 'Home',
            active: true,
          ),
          _reportNavItem(
            icon: Icons.calendar_month_outlined,
            title: 'Daily Routine',
          ),
          _reportNavItem(
            icon: Icons.person_outline,
            title: 'Profile',
          ),
          _reportNavItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _reportNavItem({
    required IconData icon,
    required String title,
    bool active = false,
  }) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 23,
          color: active
              ? const Color(0xFF22C55E)
              : const Color(0xFF60756A),
        ),
        const SizedBox(height: 4),
        Text(
          title,
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
    );
  }
}

// ================================================================
// CALORIES CHART
// ================================================================

class CaloriesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 0.7;

    final linePaint = Paint()
      ..color = const Color(0xFF8CCBA2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF65B886)
      ..style = PaintingStyle.fill;

    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final values = [
      0.48,
      0.35,
      0.58,
      0.43,
      0.62,
      0.39,
      0.55,
    ];

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x =
          i * size.width / (values.length - 1);
      final y = size.height * values[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < values.length; i++) {
      final x =
          i * size.width / (values.length - 1);
      final y = size.height * values[i];

      canvas.drawCircle(
        Offset(x, y),
        2.3,
        pointPaint,
      );
    }

    final labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    for (int i = 0; i < labels.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 5,
            color: Colors.grey,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final x =
          i * size.width /
              (labels.length - 1) -
              textPainter.width / 2;

      textPainter.paint(
        canvas,
        Offset(
          x,
          size.height - 1,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ================================================================
// WORKOUT BAR CHART
// ================================================================

class WorkoutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFF777777)
      ..strokeWidth = 0.8;

    final barPaint = Paint()
      ..color = const Color(0xFF65B97D)
      ..style = PaintingStyle.fill;

    final barBorderPaint = Paint()
      ..color = const Color(0xFF4E9B65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawLine(
      Offset(15, 5),
      Offset(15, size.height - 17),
      axisPaint,
    );

    canvas.drawLine(
      Offset(15, size.height - 17),
      Offset(size.width, size.height - 17),
      axisPaint,
    );

    final values = [
      0.12,
      0.17,
      0.10,
      0.25,
      0.38,
      0.62,
      0.82,
    ];

    final labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final chartWidth = size.width - 25;
    final barWidth = chartWidth / 12;

    for (int i = 0; i < values.length; i++) {
      final x =
          20 + i * (chartWidth / values.length);

      final barHeight =
          (size.height - 27) * values[i];

      final rect = Rect.fromLTWH(
        x,
        size.height - 17 - barHeight,
        barWidth,
        barHeight,
      );

      canvas.drawRect(rect, barPaint);
      canvas.drawRect(rect, barBorderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 5,
            color: Colors.grey,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 -
              textPainter.width / 2,
          size.height - 13,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      CustomPainter oldDelegate,
      ) {
    return false;
  }
}