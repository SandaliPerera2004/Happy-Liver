import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EducationalVideoScreen extends StatefulWidget {
  const EducationalVideoScreen({super.key});

  @override
  State<EducationalVideoScreen> createState() =>
      _EducationalVideoScreenState();
}

class _EducationalVideoScreenState
    extends State<EducationalVideoScreen> {
  late VideoPlayerController fattyLiverController;
  late VideoPlayerController cholesterolController;

  bool fattyLiverReady = false;
  bool cholesterolReady = false;

  static const Color backgroundColor = Color(0xFFF8FBF7);
  static const Color darkGreen = Color(0xFF1B6B1A);
  static const Color borderColor = Color(0xFFB7B7B7);

  @override
  void initState() {
    super.initState();

    fattyLiverController = VideoPlayerController.asset(
      'assets/videos/fatty_liver.mp4',
    );

    cholesterolController = VideoPlayerController.asset(
      'assets/videos/cholesterol.mp4',
    );

    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    await fattyLiverController.initialize();
    await cholesterolController.initialize();

    if (!mounted) return;

    setState(() {
      fattyLiverReady = true;
      cholesterolReady = true;
    });
  }

  @override
  void dispose() {
    fattyLiverController.dispose();
    cholesterolController.dispose();
    super.dispose();
  }

  void _toggleFattyLiver() {
    if (!fattyLiverReady) return;

    setState(() {
      if (fattyLiverController.value.isPlaying) {
        fattyLiverController.pause();
      } else {
        cholesterolController.pause();
        fattyLiverController.play();
      }
    });
  }

  void _toggleCholesterol() {
    if (!cholesterolReady) return;

    setState(() {
      if (cholesterolController.value.isPlaying) {
        cholesterolController.pause();
      } else {
        fattyLiverController.pause();
        cholesterolController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 45,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFDDF2D7),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Text(
                    'Explore Learning',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF252A25),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Do you know Fatty Liver?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF252A25),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _VideoCard(
                      controller: fattyLiverController,
                      isReady: fattyLiverReady,
                      thumbnailPath:
                      'assets/images/fatty_liver_thumbnail.png',
                      onPlayPressed: _toggleFattyLiver,
                      points: const [
                        'Preventable with healthy diet, exercise, and weight control.',
                        'Can progress to inflammation, fibrosis, or cirrhosis.',
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Do you know Cholesterol?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF252A25),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _VideoCard(
                      controller: cholesterolController,
                      isReady: cholesterolReady,
                      thumbnailPath:
                      'assets/images/cholesterol_thumbnail.png',
                      onPlayPressed: _toggleCholesterol,
                      points: const [
                        'Managed through balanced diet, physical activity, and medication if needed.',
                        'High LDL increases risk of heart disease and stroke.',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isReady;
  final String thumbnailPath;
  final VoidCallback onPlayPressed;
  final List<String> points;

  const _VideoCard({
    required this.controller,
    required this.isReady,
    required this.thumbnailPath,
    required this.onPlayPressed,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaying =
        isReady && controller.value.isPlaying;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xE2FFFFFF),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: onPlayPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isReady && isPlaying)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.value.size.width,
                              height: controller.value.size.height,
                              child: VideoPlayer(controller),
                            ),
                          ),
                        )
                      else
                        Positioned.fill(
                          child: Image.asset(
                            thumbnailPath,
                            fit: BoxFit.cover,
                          ),
                        ),

                      if (!isPlaying)
                        Container(
                          color: Colors.black.withValues(alpha: 0.10),
                        ),

                      if (!isPlaying)
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.50),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 31,
                            color: Color(0xFF374137),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 11),

          ...points.map(
                (point) => Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                3,
                12,
                3,
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(
                      top: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6E8F72),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF596159),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isReady && isPlaying)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                0,
              ),
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF1B6B1A),
                  bufferedColor: Color(0xFFA8D7A0),
                  backgroundColor: Color(0xFFE5E5E5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}