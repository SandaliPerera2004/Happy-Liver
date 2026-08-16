import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'exercise_timer_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({super.key});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late VideoPlayerController _videoController;

  bool _videoError = false;
  String? _videoErrorMessage;

  static const String _videoAssetPath = 'assets/videos/march_in_place.mp4';

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset(_videoAssetPath);

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      // Print the FULL error + stack trace so the real cause shows in console.
      debugPrint('VIDEO ERROR: $e');
      debugPrint('VIDEO ERROR STACK: $stackTrace');

      if (mounted) {
        setState(() {
          _videoError = true;
          _videoErrorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    if (!_videoController.value.isInitialized) return;

    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: Column(
          children: [

            // ======================================================
            // TOP APP BAR
            // ======================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [

                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Arrow left-circle.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF263A31),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        'Workout Detail',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF263A31),
                        ),
                      ),
                    ),
                  ),

                  // Bookmark
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                      ),
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 21,
                      color: Color(0xFF263A31),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // CONTENT
            // ======================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // =================================================
                    // VIDEO
                    // =================================================
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildVideo(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // WORKOUT HEADER
                    // =================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5EAE7),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // TITLE + DURATION
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              // Workout name
                              const Expanded(
                                child: Text(
                                  'March in Place',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF263A31),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Duration - RIGHT SIDE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9F9EE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Color(0xFF2BCB5A),
                                    ),

                                    SizedBox(width: 4),

                                    Text(
                                      '30 min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2BCB5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // =================================================
                          // RISK LEVEL
                          // =================================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAFBF0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Icon(
                                  Icons.monitor_heart_outlined,
                                  size: 14,
                                  color: Color(0xFF25C95A),
                                ),

                                SizedBox(width: 4),

                                Text(
                                  'Low Risk Level',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF25C95A),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // =================================================
                          // SUPPORT
                          // =================================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EEFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Icon(
                                  Icons.favorite,
                                  size: 13,
                                  color: Color(0xFF6755E8),
                                ),

                                SizedBox(width: 4),

                                Text(
                                  'Fatty Liver & Cholesterol Support',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6755E8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // INSTRUCTIONS
                    // =================================================
                    _buildSectionCard(
                      title: 'Instructions',
                      child: Column(
                        children: [

                          _instruction(
                            '1',
                            'Stand tall with feet hip-width apart.',
                          ),

                          _instruction(
                            '2',
                            'Lift one knee at a time.',
                          ),

                          _instruction(
                            '3',
                            'Swing your arms naturally.',
                          ),

                          _instruction(
                            '4',
                            'Keep a steady pace and breathe regularly.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // BENEFITS
                    // =================================================
                    _buildSectionCard(
                      title: 'Benefits',
                      child: Column(
                        children: [

                          _benefit(
                            'Improves cardiovascular fitness',
                          ),

                          _benefit(
                            'Increases daily physical activity',
                          ),

                          _benefit(
                            'Supports healthy weight management',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // START EXERCISE
                    // =================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _videoController.pause();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExerciseTimerScreen(
                                workoutName: 'March in Place',
                                totalDuration: Duration(minutes: 30),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Start Exercise',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2DCB59),
                          elevation: 4,
                          shadowColor: const Color(0x552DCB59),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // VIDEO WIDGET
  // ==============================================================
  Widget _buildVideo() {
    if (_videoError) {
      return Container(
        color: const Color(0xFFF2F2F2),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 35,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load video',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (_videoErrorMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _videoErrorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (!_videoController.value.isInitialized) {
      return Container(
        color: const Color(0xFFF2F2F2),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2DCB59),
          ),
        ),
      );
    }

    final bool isPlaying = _videoController.value.isPlaying;

    return GestureDetector(

      onTap: _toggleVideo,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Video
          VideoPlayer(_videoController),

          // Slight dark overlay + play button only show when PAUSED.
          if (!isPlaying) ...[
            Container(
              color: Colors.black.withOpacity(0.12),
            ),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xFF263A31),
                size: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION CARD
  // ==============================================================
  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        13,
        13,
        10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5EAE7),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263A31),
            ),
          ),

          const SizedBox(height: 8),

          child,
        ],
      ),
    );
  }

  // ==============================================================
  // INSTRUCTION
  // ==============================================================
  Widget _instruction(
      String number,
      String text,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9F9EE),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2DCB59),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF65716B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BENEFIT
  // ==============================================================
  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [

          const Icon(
            Icons.check_circle,
            size: 17,
            color: Color(0xFF2DCB59),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF65716B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}