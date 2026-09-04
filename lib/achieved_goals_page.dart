import 'package:flutter/material.dart';
import 'package:happy_liver/services/achieved_goals_service.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFFA),

      // ==================================================
      // APP BAR
      // ==================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F8D9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Achieved Goals',
          style: TextStyle(
            color: Color(0xFF16713A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==================================================
      // BODY
      // ==================================================
      body: FutureBuilder<AchievedGoalsData>(
        future: goalsFuture,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF39C96B),
              ),
            );
          }

          // ERROR
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

          // NO DATA
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No goal data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFF39C96B),

            onRefresh: () async {
              refreshGoals();

              if (goalsFuture != null) {
                await goalsFuture;
              }
            },

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),

              children: [
                // ==================================================
                // TROPHY
                // ==================================================
                const Center(
                  child: Text(
                    '🏆',
                    style: TextStyle(
                      fontSize: 58,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // CONGRATULATIONS
                // ==================================================
                const Center(
                  child: Text(
                    'Congratulations !',
                    style: TextStyle(
                      color: Color(0xFF16713A),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Center(
                  child: Text(
                    'You have archive your weekly goals !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // WATER CARD
                // ==================================================
                GoalCard(
                  title: 'Water intake',
                  valueText:
                  '${data.waterGlasses} / ${data.waterTargetGlasses} Glasses',
                  percentage: data.waterPercentage,
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF2196F3),
                  iconBackground: const Color(0xFFE1F2FF),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // WORKOUT CARD
                // ==================================================
                GoalCard(
                  title: 'Workout',
                  valueText:
                  '${data.workoutCompletedDays} / 7 Days',
                  percentage: data.workoutPercentage,
                  icon: Icons.directions_run_rounded,
                  iconColor: const Color(0xFFFF8A00),
                  iconBackground: const Color(0xFFFFEBD6),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // DIET CARD
                // ==================================================
                GoalCard(
                  title: 'Diet',
                  valueText:
                  '${data.dietCompletedDays} / 7 Days',
                  percentage: data.dietPercentage,
                  icon: Icons.restaurant_rounded,
                  iconColor: const Color(0xFF39A852),
                  iconBackground: const Color(0xFFE1F7E5),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),

      // ==================================================
      // BOTTOM NAVIGATION BAR
      // ==================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF39C96B),
        unselectedItemColor: Colors.grey,
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
    );
  }
}


// ======================================================
// GOAL CARD
// ======================================================

class GoalCard extends StatelessWidget {
  final String title;
  final String valueText;
  final int percentage;

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const GoalCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      // ==================================================
      // CARD COLOR
      // ==================================================
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EC),

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================
          // LARGE COLORFUL ICON
          // ==================================================
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

            child: Icon(
              icon,
              size: 38,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 15),

          // ==================================================
          // CARD DETAILS
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF16713A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // VALUE
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                // PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,

                    backgroundColor:
                    const Color(0xFFD9EEDC),

                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      Color(0xFF39C96B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ==================================================
          // PERCENTAGE
          // ==================================================
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Color(0xFF16713A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}