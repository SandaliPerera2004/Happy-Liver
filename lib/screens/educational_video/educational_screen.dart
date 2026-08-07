import '../../widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:happy_liver/screens/educational_video/video_player_screen.dart';

class EducationalScreen extends StatelessWidget {
  const EducationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),

      appBar: const CustomHeader(title: 'Educational Videos' , showBack:true),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(
              "Learn more about Fatty Liver and Cholesterol through short educational videos.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            VideoCard(
              title: "Do you know Fatty Liver?",
              thumbnail: "assets/images/fatty_liver_thumbnail.png",
              videoPath: "assets/videos/fatty_liver.mp4",
            ),

            const SizedBox(height: 50),

            VideoCard(
              title: "Do you know Cholesterol?",
              thumbnail: "assets/images/cholesterol_thumbnail.png",
              videoPath: "assets/videos/cholesterol.mp4",
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {

  final String title;
  final String thumbnail;
  final String videoPath;

  const VideoCard({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.videoPath,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  title: title,
                  videoPath: videoPath,
                ),
              ),
            );

          },

          child: Stack(
            alignment: Alignment.center,

            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(15),

                child: Image.asset(
                  thumbnail,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.9),

                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.green,
                  size: 42,
                ),
              ),

            ],
          ),
        ),

      ],
    );
  }
}