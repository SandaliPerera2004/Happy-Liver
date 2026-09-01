import 'package:flutter/material.dart';

void main() {
  runApp(
    const FitnessApp(),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Liver',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const AchievedGoalsPage(),
    );
  }
}

class AchievedGoalsPage extends StatelessWidget {
  final bool showBackButton;

  const AchievedGoalsPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
            ),

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
                      const SizedBox(
                        height: 25,
                      ),

                      _buildTrophy(),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        'Congratulations!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        'You have achieved your weekly goals!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      const GoalCard(
                        title: 'Water Intake',
                        valueText: '42 / 56 Glasses',
                        percentage: 75,
                        emoji: '💧',
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const GoalCard(
                        title: 'Workout',
                        valueText: '5 / 7 Days',
                        percentage: 71,
                        emoji: '🏃',
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const GoalCard(
                        title: 'Diet',
                        valueText: '5 / 7 Days',
                        percentage: 71,
                        emoji: '🥗',
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const GoalCard(
                        title: 'Sleep',
                        valueText: '6 / 7 Days',
                        percentage: 86,
                        emoji: '😴',
                      ),

                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {
    return Container(
      height: 49,
      width: double.infinity,
      color: const Color(
        0xFFDFF8D6,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 13,
          ),

          InkWell(
            borderRadius: BorderRadius.circular(
              30,
            ),
            onTap: () {
              if (
              showBackButton &&
                  Navigator.canPop(
                    context,
                  )
              ) {
                Navigator.pop(
                  context,
                );
              }
            },
            child: const SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                Icons.arrow_back,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(
            width: 13,
          ),

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

  Widget _buildTrophy() {
    return SizedBox(
      width: 100,
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '🏆',
            style: TextStyle(
              fontSize: 73,
            ),
          ),

          Positioned(
            left: 4,
            top: 13,
            child: Transform.rotate(
              angle: -0.3,
              child: const Text(
                '✦',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(
                    0xFFFFA600,
                  ),
                ),
              ),
            ),
          ),

          const Positioned(
            right: 4,
            top: 10,
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 15,
                color: Color(
                  0xFFFFA600,
                ),
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
  final String emoji;

  const GoalCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.percentage,
    required this.emoji,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FCF6,
        ),
        borderRadius: BorderRadius.circular(
          28,
        ),
        border: Border.all(
          color: const Color(
            0xFFB8EEA7,
          ),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x30000000,
            ),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
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
                color: Color(
                  0xFF303030,
                ),
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: 34,
            child: Container(
              width: 31,
              height: 31,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(
                  0xFF18A957,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),

          Positioned(
            left: 77,
            right: 77,
            top: 34,
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  22,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(
                      0x35000000,
                    ),
                    blurRadius: 5,
                    offset: Offset(
                      0,
                      3,
                    ),
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
                      color: Color(
                        0xFF194B20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: const Color(
                        0xFF8A8A8A,
                      ),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                        Color(
                          0xFF32C965,
                        ),
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