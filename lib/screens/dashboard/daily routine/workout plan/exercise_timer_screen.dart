import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseTimerScreen extends StatefulWidget {
  const ExerciseTimerScreen({
    super.key,
    this.workoutName = 'March in Place',
    this.totalDuration = const Duration(minutes: 30),
  });

  final String workoutName;
  final Duration totalDuration;

  @override
  State<ExerciseTimerScreen> createState() => _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen> {
  static const Color _green = Color(0xFF2DCB59);
  static const Color _lightGreenTrack = Color(0xFFDFF3D8);
  static const Color _lightGreenBg = Color(0xFFEAFBF0);
  static const Color _darkText = Color(0xFF263A31);
  static const Color _grayText = Color(0xFF8A948E);

  Timer? _timer;
  late Duration _remaining;
  bool _isPaused = false;

  // Mock stats — replace with real sensor/tracking data if available.
  int _calories = 0;
  int _heartRate = 92;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _remaining -= const Duration(seconds: 1);

        // Mock incrementing stats as the workout progresses.
        _calories = (widget.totalDuration.inSeconds - _remaining.inSeconds) ~/ 3;
        _steps = (widget.totalDuration.inSeconds - _remaining.inSeconds) * 3;
        _heartRate = 88 + ((_remaining.inSeconds ~/ 10) % 10);
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _endWorkout() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    final total = widget.totalDuration.inSeconds;
    if (total == 0) return 0;
    final elapsed = total - _remaining.inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              // ==========================================================
              // TOP APP BAR
              // ==========================================================
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD5DAD7)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/Arrow left-circle.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          _darkText,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.workoutName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _darkText,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD5DAD7)),
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      size: 18,
                      color: _darkText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ==========================================================
              // CIRCULAR TIMER
              // ==========================================================
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: _lightGreenTrack,
                        valueColor: const AlwaysStoppedAnimation<Color>(_green),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDuration(_remaining),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'TIME REMAINING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: _grayText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================================
              // STATS ROW
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      iconAsset: 'assets/icons/fire.svg',
                      iconColor: const Color(0xFF34B24A),
                      value: '$_calories',
                      label: 'kcal',
                      sublabel: 'Calories',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      iconAsset: 'assets/icons/heart.svg',
                      iconColor: const Color(0xFFE0517A),
                      value: '$_heartRate',
                      label: 'bpm',
                      sublabel: 'Heart Rate',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      iconAsset: 'assets/icons/steps.svg',
                      iconColor: _green,
                      value: '$_steps',
                      label: '',
                      sublabel: 'Steps',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================================
              // MOTIVATIONAL BANNER
              // ==========================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: _lightGreenBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        _green,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Keep going! You're doing great.",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ==========================================================
              // PAUSE / RESUME BUTTON
              // ==========================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _togglePause,
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isPaused ? 'Resume Workout' : 'Pause Workout',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================================
              // END WORKOUT
              // ==========================================================
              GestureDetector(
                onTap: _endWorkout,
                child: const Text(
                  'End Workout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String iconAsset,
    required Color iconColor,
    required String value,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _lightGreenBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 32,
            height: 32,
            placeholderBuilder: (context) => Icon(
              Icons.image_not_supported_outlined,
              size: 18,
              color: iconColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.isEmpty ? value : '$value $label',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 11,
              color: _grayText,
            ),
          ),
        ],
      ),
    );
  }
}