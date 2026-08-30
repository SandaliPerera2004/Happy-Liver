import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'exercise_timer_screen.dart';
import 'package:happy_liver/models/workout_model.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  VideoPlayerController? _videoController;

  bool _videoError = false;
  String? _videoErrorMessage;

  @override
  void initState() {
    super.initState();

    debugPrint('====================================');
    debugPrint('WORKOUT DETAIL SCREEN');
    debugPrint('Workout ID: ${widget.workout.id}');
    debugPrint('Workout Name: ${widget.workout.name}');
    debugPrint('Video URL received: "${widget.workout.videoUrl}"');
    debugPrint('Video URL length: ${widget.workout.videoUrl.length}');
    debugPrint('====================================');

    _initializeVideo();
  }

  // ==============================================================
  // INITIALIZE VIDEO
  // ==============================================================
  Future<void> _initializeVideo() async {
    final String videoUrl = widget.workout.videoUrl.trim();

    if (videoUrl.isEmpty) {
      debugPrint(
        'VIDEO ERROR: videoUrl received from WorkoutModel is EMPTY',
      );

      if (mounted) {
        setState(() {
          _videoError = true;
          _videoErrorMessage = 'Video URL is empty.';
        });
      }

      return;
    }

    debugPrint('VIDEO URL TO LOAD: $videoUrl');

    try {
      final Uri videoUri = Uri.tryParse(videoUrl) ??
          (throw Exception('Invalid video URL.'));

      if (videoUri.scheme != 'http' &&
          videoUri.scheme != 'https') {
        throw Exception(
          'Video URL must start with http:// or https://',
        );
      }

      _videoController = VideoPlayerController.networkUrl(
        videoUri,
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() {});
      }

      debugPrint('VIDEO INITIALIZED SUCCESSFULLY');
      debugPrint(
        'VIDEO ASPECT RATIO: ${_videoController!.value.aspectRatio}',
      );
      debugPrint(
        'VIDEO SIZE: ${_videoController!.value.size}',
      );
    } catch (e, stackTrace) {
      debugPrint('====================================');
      debugPrint('VIDEO INITIALIZATION ERROR');
      debugPrint('URL: $videoUrl');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('====================================');

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
    _videoController?.dispose();
    super.dispose();
  }

  // ==============================================================
  // OPEN FULL SCREEN VIDEO
  // ==============================================================
  void _openFullScreenVideo() {
    final controller = _videoController;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    // Pause the video on the detail screen before opening
    // the full-screen player.
    controller.pause();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoScreen(
          controller: controller,
          workoutName: widget.workout.name,
        ),
      ),
    );
  }

  // ==============================================================
  // BUILD
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // TITLE + DURATION
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.workout.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF263A31),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Duration
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFE9F9EE),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Color(0xFF2BCB5A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.workout.duration} min',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.w600,
                                        color:
                                        Color(0xFF2BCB5A),
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
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFEAFBF0),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monitor_heart_outlined,
                                  size: 14,
                                  color: Color(0xFF25C95A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.workout.riskLevel} Risk Level',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Color(0xFF25C95A),
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
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFF0EEFF),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 13,
                                  color: Color(0xFF6755E8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.workout.support,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Color(0xFF6755E8),
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
                        children: List.generate(
                          widget.workout.instructions.length,
                              (index) {
                            return _instruction(
                              '${index + 1}',
                              widget.workout.instructions[index],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // BENEFITS
                    // =================================================
                    _buildSectionCard(
                      title: 'Benefits',
                      child: Column(
                        children: widget.workout.benefits
                            .map(
                              (benefit) =>
                              _benefit(benefit),
                        )
                            .toList(),
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
                          final controller =
                              _videoController;

                          if (controller != null &&
                              controller
                                  .value.isInitialized) {
                            controller.pause();
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseTimerScreen(
                                    workoutName:
                                    widget.workout.name,
                                    totalDuration:
                                    Duration(
                                      minutes:
                                      widget.workout.duration,
                                    ),
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
                            fontWeight:
                            FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF2DCB59),
                          elevation: 4,
                          shadowColor:
                          const Color(0x552DCB59),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30),
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
    // --------------------------------------------------------------
    // VIDEO ERROR
    // --------------------------------------------------------------
    if (_videoError) {
      return Container(
        width: double.infinity,
        height: double.infinity,
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
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                if (_videoErrorMessage != null) ...[
                  const SizedBox(height: 6),

                  Text(
                    _videoErrorMessage!,
                    textAlign:
                    TextAlign.center,
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

    final controller = _videoController;

    // --------------------------------------------------------------
    // LOADING
    // --------------------------------------------------------------
    if (controller == null ||
        !controller.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF2F2F2),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2DCB59),
          ),
        ),
      );
    }

    // --------------------------------------------------------------
    // VIDEO PREVIEW
    // --------------------------------------------------------------
    return GestureDetector(
      onTap: _openFullScreenVideo,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // ==========================================================
          // VIDEO
          // ==========================================================
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),

          // ==========================================================
          // DARK OVERLAY
          // ==========================================================
          Container(
            color: Colors.black.withOpacity(0.12),
          ),

          // ==========================================================
          // PLAY BUTTON
          // ==========================================================
          Center(
            child: Container(
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
          ),

          // ==========================================================
          // FULL SCREEN HINT
          // ==========================================================
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
      padding:
      const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 15,
            decoration:
            const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9F9EE),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(0xFF2DCB59),
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
                color:
                Color(0xFF65716B),
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
      padding:
      const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 15,
            color: Color(0xFF2DCB59),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color:
                Color(0xFF65716B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FULL SCREEN VIDEO SCREEN
// ==================================================================

class FullScreenVideoScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final String workoutName;

  const FullScreenVideoScreen({
    super.key,
    required this.controller,
    required this.workoutName,
  });

  @override
  State<FullScreenVideoScreen> createState() =>
      _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState
    extends State<FullScreenVideoScreen> {

  @override
  void initState() {
    super.initState();

    // Start playing automatically
    widget.controller.play();
  }

  @override
  void dispose() {
    // Only pause here.
    // DO NOT dispose the controller because it belongs
    // to WorkoutDetailScreen.
    widget.controller.pause();

    super.dispose();
  }

  // ==============================================================
  // PLAY / PAUSE
  // ==============================================================
  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }

    setState(() {});
  }

  // ==============================================================
  // BUILD
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Stack(
          children: [

            // ======================================================
            // VIDEO
            // ======================================================
            Center(
              child: AspectRatio(
                aspectRatio:
                controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),

            // ======================================================
            // TOP BAR
            // ======================================================
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [

                  // Close button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                        Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Workout name
                  Expanded(
                    child: Text(
                      widget.workoutName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // PLAY / PAUSE BUTTON
            // ======================================================
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color:
                    Colors.white.withOpacity(0.90),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color:
                    const Color(0xFF263A31),
                    size: 38,
                  ),
                ),
              ),
            ),

            // ======================================================
            // VIDEO PROGRESS BAR
            // ======================================================
            Positioned(
              left: 15,
              right: 15,
              bottom: 12,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                colors:
                const VideoProgressColors(
                  playedColor:
                  Color(0xFF2DCB59),
                  bufferedColor:
                  Colors.white54,
                  backgroundColor:
                  Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}