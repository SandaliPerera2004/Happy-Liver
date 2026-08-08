import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WorkoutPlanScreen(),
  ));
}

enum WorkoutIcon { walk, strength, swim, rest }

// Map each icon type to its PNG asset path.
// Add these files under assets/images/ and register the folders in pubspec.yaml:
//
// flutter:
//   assets:
//     - assets/images/
//     - assets/icons/
//
const Map<WorkoutIcon, String> workoutIconAssets = {
  WorkoutIcon.walk: 'assets/images/walk.png',
  WorkoutIcon.strength: 'assets/images/strength.png',
  WorkoutIcon.swim: 'assets/images/swim.png',
  WorkoutIcon.rest: 'assets/images/rest.png',
};

const String tipBulbAsset = 'assets/images/tip.png';
const String trophyAsset = 'assets/images/trophy.png';
const String leafAsset = 'assets/images/leaf.png';

class WorkoutDay {
  final String day;
  final String title;
  final String subtitle;
  final WorkoutIcon icon;
  final bool isRest;
  bool done;

  WorkoutDay({
    required this.day,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isRest = false,
    this.done = false,
  });
}

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final List<WorkoutDay> _workouts = [
    WorkoutDay(day: 'Mon', title: 'Brisk walking', subtitle: '30 min', icon: WorkoutIcon.walk, done: true),
    WorkoutDay(day: 'Tue', title: 'Strength training', subtitle: '2 sets', icon: WorkoutIcon.strength),
    WorkoutDay(day: 'Wed', title: 'Swimming', subtitle: '30 min', icon: WorkoutIcon.swim),
    WorkoutDay(day: 'Thu', title: 'Brisk walking', subtitle: '30 min', icon: WorkoutIcon.walk, done: true),
    WorkoutDay(day: 'Fri', title: 'Strength training', subtitle: '2 sets', icon: WorkoutIcon.strength),
    WorkoutDay(day: 'Sat', title: 'Rest day', subtitle: 'Stretching / Yoga', icon: WorkoutIcon.rest, isRest: true, done: true),
    WorkoutDay(day: 'Sun', title: 'Brisk walking', subtitle: '30 min', icon: WorkoutIcon.walk),
  ];

  static const Color darkGreen = Color(0xFF14532D);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color statusGreen = Color(0xFF2E7D32);
  static const Color tableBorder = Color(0xFFE0E0E0);
  static const Color tableHeaderBg = Color(0xFFF5F5F5);

  int get _totalTrackable => _workouts.where((w) => !w.isRest).length;
  int get _completedTrackable => _workouts.where((w) => !w.isRest && w.done).length;

  void _toggleWorkout(int index) {
    final workout = _workouts[index];
    if (workout.isRest) return; // rest day status is fixed
    setState(() {
      workout.done = !workout.done;
    });
    // TODO: persist this change (e.g. shared_preferences, backend call)
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalTrackable == 0 ? 0.0 : _completedTrackable / _totalTrackable;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                // Increased top padding (was 8) for more breathing room between
                // the app bar and the progress card.
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  _buildProgressCard(progress),
                  const SizedBox(height: 16),
                  _buildWorkoutTable(),
                  const SizedBox(height: 16),
                  _buildTipCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar is placed inside the SafeArea (rather than Scaffold.appBar) so
  // its content never sits under the status bar / notch on any device.
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: lightGreenBg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 28,
              height: 28,
            ),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          const Text(
            'Workout Plan',
            style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Trophy PNG in the top-right corner.
          Positioned(
            right: 0,
            top: 0,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(trophyAsset, width: 70, height: 70, color: darkGreen),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Progress',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '$_completedTrackable / $_totalTrackable Workouts Completed',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.8,
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Table wrapped in a bordered, rounded frame with a shaded header row,
  // and columns aligned to match the icon/status widths used in each row.
  Widget _buildWorkoutTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: tableBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeaderRow(),
          for (int i = 0; i < _workouts.length; i++) ...[
            const Divider(height: 1, color: tableBorder),
            _buildWorkoutRow(i, _workouts[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return Container(
      color: tableHeaderBg,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 40,
              child: Center(
                child: Text('Day', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: tableBorder),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('Workouts', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: tableBorder),
            const SizedBox(
              width: 48,
              child: Center(
                child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutRow(int index, WorkoutDay workout) {
    final Color statusColor = workout.done ? statusGreen : Colors.grey.shade400;

    return InkWell(
      onTap: () => _toggleWorkout(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(workout.day, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: tableBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          workoutIconAssets[workout.icon]!,
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(workout.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(workout.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: tableBorder),
              SizedBox(
                width: 48,
                child: Center(
                  child: workout.isRest
                  // Rest day: fixed leaf PNG, not tappable — no tick needed.
                      ? Image.asset(leafAsset, width: 24, height: 24)
                      : IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _toggleWorkout(index),
                    icon: Icon(
                      workout.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: statusColor,
                      size: 24,
                    ),
                    tooltip: workout.done ? 'Mark incomplete' : 'Mark complete',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGreenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 2),
            child: Image.asset(tipBulbAsset, width: 18, height: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(
                        text: 'Tip: ',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                      TextSpan(text: 'Stay Consistent!'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Small Steps lead to big changes.',
                  style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}