import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';
import 'package:happy_liver/services/workout_progress_service.dart';

class ExerciseTimerScreen extends StatefulWidget {
  const ExerciseTimerScreen({
    super.key,
    required this.workoutId,
    this.workoutName = 'March in Place',
    this.totalDuration = const Duration(minutes: 30),
  });

  final String workoutId;
  final String workoutName;
  final Duration totalDuration;

  @override
  State<ExerciseTimerScreen> createState() =>
      _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen> {
  final WorkoutProgressService _progressService =
  WorkoutProgressService();

  static const Color _green = Color(0xFF2DCB59);
  static const Color _lightGreenTrack = Color(0xFFDFF3D8);
  static const Color _lightGreenBg = Color(0xFFEAFBF0);

  static const Color _lightText = Color(0xFF263A31);
  static const Color _darkText = Colors.white;

  static const Color _lightGrayText = Color(0xFF8A948E);
  static const Color _darkGrayText = Colors.white70;

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

  Timer? _timer;
  late Duration _remaining;

  bool _isPaused = false;

  // True ONLY when timer reaches 00:00.
  bool _workoutCompleted = false;

  // Prevent multiple Firestore writes at the same time.
  bool _isSaving = false;

  // Mock stats — replace with real sensor/tracking data later.
  int _calories = 0;
  int _heartRate = 92;
  int _steps = 0;

  @override
  void initState() {
    super.initState();

    _remaining = widget.totalDuration;

    _startTimer();
  }

  // ==============================================================
  // START TIMER
  // ==============================================================

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        // ==========================================================
        // TIMER REACHED 00:00
        // ==========================================================

        if (_remaining.inSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remaining = Duration.zero;
            _workoutCompleted = true;
          });

          // ========================================================
          // SAVE FULL COMPLETION
          // ========================================================

          try {
            await _progressService.markWorkoutCompleted(
              workoutId: widget.workoutId,
              totalDurationSeconds:
              widget.totalDuration.inSeconds,
            );

            debugPrint(
              '================================================',
            );

            debugPrint('WORKOUT FULLY COMPLETED');

            debugPrint(
              'Workout ID: ${widget.workoutId}',
            );

            debugPrint('Progress: 100%');

            debugPrint(
              '================================================',
            );
          } catch (e) {
            debugPrint(
              'ERROR SAVING WORKOUT COMPLETION: $e',
            );
          }

          return;
        }

        // ==========================================================
        // NORMAL TIMER TICK
        // ==========================================================

        setState(() {
          _remaining -= const Duration(seconds: 1);

          final elapsedSeconds =
              widget.totalDuration.inSeconds -
                  _remaining.inSeconds;

          // Mock stats
          _calories = elapsedSeconds ~/ 3;

          _steps = elapsedSeconds * 3;

          _heartRate =
              88 + ((_remaining.inSeconds ~/ 10) % 10);
        });

        // ==========================================================
        // SAVE PARTIAL PROGRESS
        // ==========================================================
        //
        // Saves every 10 seconds.
        //
        // Example with a 30-minute workout:
        //
        // 29:50 -> small progress
        // 29:40 -> more progress
        // 29:30 -> more progress
        //
        // It DOES NOT mark the workout as completed.
        //
        // ==========================================================

        final elapsedSeconds =
            widget.totalDuration.inSeconds -
                _remaining.inSeconds;

        if (elapsedSeconds > 0 &&
            elapsedSeconds % 10 == 0 &&
            !_workoutCompleted) {
          await _savePartialProgress();
        }
      },
    );
  }

  // ==============================================================
  // SAVE PARTIAL PROGRESS
  // ==============================================================

  Future<void> _savePartialProgress() async {
    if (_isSaving || _workoutCompleted) {
      return;
    }

    _isSaving = true;

    final totalSeconds =
        widget.totalDuration.inSeconds;

    final elapsedSeconds =
        totalSeconds - _remaining.inSeconds;

    try {
      await _progressService.saveWorkoutProgress(
        workoutId: widget.workoutId,
        totalDurationSeconds: totalSeconds,
        completedDurationSeconds: elapsedSeconds,
      );

      final progressPercentage =
      totalSeconds > 0
          ? ((elapsedSeconds / totalSeconds) * 100)
          .round()
          : 0;

      debugPrint(
        '================================================',
      );

      debugPrint('PARTIAL WORKOUT PROGRESS SAVED');

      debugPrint(
        'Workout ID: ${widget.workoutId}',
      );

      debugPrint(
        'Elapsed: $elapsedSeconds seconds',
      );

      debugPrint(
        'Remaining: ${_remaining.inSeconds} seconds',
      );

      debugPrint(
        'Progress: $progressPercentage%',
      );

      debugPrint(
        'Completed: false',
      );

      debugPrint(
        '================================================',
      );
    } catch (e) {
      debugPrint(
        'ERROR SAVING PARTIAL PROGRESS: $e',
      );
    } finally {
      _isSaving = false;
    }
  }

  // ==============================================================
  // PAUSE / RESUME
  // ==============================================================

  void _togglePause() {
    if (_workoutCompleted) {
      return;
    }

    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _timer?.cancel();

      // Save the progress at the moment user pauses.
      _savePartialProgress();
    } else {
      _startTimer();
    }
  }

  // ==============================================================
  // END WORKOUT
  // ==============================================================

  Future<void> _endWorkout() async {
    _timer?.cancel();

    // ==========================================================
    // IMPORTANT
    //
    // End Workout ≠ Completed
    //
    // Only save the amount actually completed.
    // ==========================================================

    if (!_workoutCompleted) {
      await _savePartialProgress();

      final percentage =
      (_progress * 100).round();

      debugPrint(
        '================================================',
      );

      debugPrint(
        'WORKOUT ENDED WITHOUT COMPLETION',
      );

      debugPrint(
        'Workout ID: ${widget.workoutId}',
      );

      debugPrint(
        'Progress: $percentage%',
      );

      debugPrint(
        'Completed: false',
      );

      debugPrint(
        '================================================',
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  // ==============================================================
  // FORMAT DURATION
  // ==============================================================

  String _formatDuration(Duration d) {
    final minutes =
    d.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
    d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ==============================================================
  // PROGRESS
  // ==============================================================

  double get _progress {
    final total =
        widget.totalDuration.inSeconds;

    if (total == 0) {
      return 0;
    }

    final elapsed =
        total - _remaining.inSeconds;

    return (elapsed / total).clamp(0.0, 1.0);
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? _darkBackground
              : Colors.white,

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),

              child: Column(
                children: [
                  // ==================================================
                  // TOP APP BAR
                  // ==================================================

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),

                        child: Container(
                          width: 38,
                          height: 38,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFD5DAD7),
                            ),
                          ),

                          child: SvgPicture.asset(
                            'assets/icons/Arrow left-circle.svg',

                            width: 20,
                            height: 20,

                            colorFilter:
                            ColorFilter.mode(
                              isDarkMode
                                  ? Colors.white
                                  : _lightText,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            widget.workoutName,

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w600,

                              color: isDarkMode
                                  ? _darkText
                                  : _lightText,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _togglePause,

                        child: Container(
                          width: 38,
                          height: 38,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFFD5DAD7),
                            ),
                          ),

                          child: Icon(
                            _isPaused
                                ? Icons.play_arrow
                                : Icons.pause,

                            size: 18,

                            color: isDarkMode
                                ? Colors.white
                                : _lightText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ==================================================
                  // CIRCULAR TIMER
                  // ==================================================

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

                            strokeCap:
                            StrokeCap.round,

                            backgroundColor:
                            isDarkMode
                                ? const Color(0xFF29402D)
                                : _lightGreenTrack,

                            valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                              _green,
                            ),
                          ),
                        ),

                        Column(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [
                            Text(
                              _formatDuration(
                                _remaining,
                              ),

                              style: TextStyle(
                                fontSize: 40,
                                fontWeight:
                                FontWeight.w800,

                                color: isDarkMode
                                    ? _darkText
                                    : _lightText,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'TIME REMAINING',

                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,

                                letterSpacing: 0.5,

                                color: isDarkMode
                                    ? _darkGrayText
                                    : _lightGrayText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // STATS ROW
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          iconAsset:
                          'assets/icons/fire.svg',

                          iconColor:
                          const Color(0xFF34B24A),

                          value: '$_calories',

                          label: 'kcal',

                          sublabel: 'Calories',

                          isDarkMode:
                          isDarkMode,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _statCard(
                          iconAsset:
                          'assets/icons/heart.svg',

                          iconColor:
                          const Color(0xFFE0517A),

                          value: '$_heartRate',

                          label: 'bpm',

                          sublabel: 'Heart Rate',

                          isDarkMode:
                          isDarkMode,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _statCard(
                          iconAsset:
                          'assets/icons/steps.svg',

                          iconColor: _green,

                          value: '$_steps',

                          label: '',

                          sublabel: 'Steps',

                          isDarkMode:
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // MOTIVATIONAL BANNER
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),

                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? _darkCard
                          : _lightGreenBg,

                      borderRadius:
                      BorderRadius.circular(16),

                      border: isDarkMode
                          ? Border.all(
                        color: Colors.white12,
                      )
                          : null,
                    ),

                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        SvgPicture.asset(
                          'assets/icons/star.svg',

                          width: 16,
                          height: 16,

                          colorFilter:
                          const ColorFilter.mode(
                            _green,
                            BlendMode.srcIn,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Flexible(
                          child: Text(
                            "Keep going! You're doing great.",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w600,

                              color: isDarkMode
                                  ? _darkText
                                  : _lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ==================================================
                  // PAUSE / RESUME BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton.icon(
                      onPressed:
                      _workoutCompleted
                          ? null
                          : _togglePause,

                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow
                            : Icons.pause,

                        color: Colors.white,
                      ),

                      label: Text(
                        _isPaused
                            ? 'Resume Workout'
                            : 'Pause Workout',

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,

                          color: Colors.white,
                        ),
                      ),

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        _green,

                        disabledBackgroundColor:
                        _green,

                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // END WORKOUT
                  // ==================================================

                  GestureDetector(
                    onTap: _isSaving
                        ? null
                        : _endWorkout,

                    child: const Text(
                      'End Workout',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,

                        color:
                        Colors.redAccent,

                        decoration:
                        TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // STAT CARD
  // ==============================================================

  Widget _statCard({
    required String iconAsset,
    required Color iconColor,
    required String value,
    required String label,
    required String sublabel,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : _lightGreenBg,

        borderRadius:
        BorderRadius.circular(16),

        border: isDarkMode
            ? Border.all(
          color: Colors.white12,
        )
            : null,
      ),

      child: Column(
        children: [
          SvgPicture.asset(
            iconAsset,

            width: 32,
            height: 32,

            placeholderBuilder:
                (context) => Icon(
              Icons.image_not_supported_outlined,
              size: 18,
              color:
              iconColor.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label.isEmpty
                ? value
                : '$value $label',

            style: TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w700,

              color: isDarkMode
                  ? _darkText
                  : _lightText,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            sublabel,

            style: TextStyle(
              fontSize: 11,

              color: isDarkMode
                  ? _darkGrayText
                  : _lightGrayText,
            ),
          ),
        ],
      ),
    );
  }
}