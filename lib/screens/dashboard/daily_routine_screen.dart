import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DailyRoutineScreen extends StatelessWidget {
  const DailyRoutineScreen({super.key});

  static const Color kHeaderGreen = Color(0xFFDDF2DD);
  static const Color kCardGreen = Color(0xFFEAF7EA);
  static const Color kCardBorder = Color(0xFF9AD29A);
  static const Color kDarkGreenText = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Green header bar
              Container(
                width: double.infinity,
                color: kHeaderGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: SvgPicture.asset(
                        'assets/icons/Arrow left-circle.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Daily Routine',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tagline + illustration
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Small steps everyday leads to big results',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                fontSize: 19,
                                height: 1.6,
                                fontWeight: FontWeight.w800,
                                color: kDarkGreenText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/Daily.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      _buildRoutineCard(
                        context: context,
                        imagePath: 'assets/images/Food bowl 1.png',
                        title: 'Diet Plan',
                        description:
                        'Explore healthy meal plans tailored for you.',
                        onTap: () {
                          debugPrint('Diet Plan card tapped');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DietPlanScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      _buildRoutineCard(
                        context: context,
                        imagePath: 'assets/images/Water bottle.png',
                        title: 'Workout Plan',
                        description:
                        'Discover effective workouts to keep you active.',
                        onTap: () {
                          debugPrint('Workout Plan card tapped');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WorkoutPlanScreen(),
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
      ),
    );
  }

  Widget _buildRoutineCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kCardBorder, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 90,
                height: 90,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade900,
                      height: 1.3,
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


class DietPlanScreen extends StatelessWidget {
  const DietPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet Plan')),
      body: const Center(child: Text('Diet Plan screen')),
    );
  }
}


class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
      body: const Center(child: Text('Workout Plan screen')),
    );
  }
}