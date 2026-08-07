import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {

  final String title;
  final String videoPath;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.videoPath,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();

}


class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController _controller;


  @override
  void initState() {
    super.initState();


    _controller = VideoPlayerController.asset(
      widget.videoPath,
    )

      ..initialize().then((_) {

        setState(() {});

      });


  }


  @override
  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  void toggleVideo() {

    setState(() {

      if(_controller.value.isPlaying){

        _controller.pause();

      }
      else{

        _controller.play();

      }

    });

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.black,




      body: Center(

        child: _controller.value.isInitialized

            ?

        Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [


            AspectRatio(

              aspectRatio:
              _controller.value.aspectRatio,


              child: VideoPlayer(
                _controller,
              ),

            ),



            const SizedBox(height: 20),



            VideoProgressIndicator(

              _controller,

              allowScrubbing: true,

              colors: const VideoProgressColors(

                playedColor: Colors.green,

                bufferedColor: Colors.grey,

                backgroundColor: Colors.white,

              ),

            ),



            const SizedBox(height: 20),



            Row(

              mainAxisAlignment:
              MainAxisAlignment.center,


              children: [


                IconButton(

                  onPressed: toggleVideo,


                  icon: Icon(

                    _controller.value.isPlaying

                        ? Icons.pause_circle

                        : Icons.play_circle,


                    color: Colors.white,

                    size: 55,

                  ),

                ),



                const SizedBox(width: 20),



                IconButton(

                  onPressed: () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context)=> FullScreenVideo(

                          controller: _controller,

                        ),

                      ),

                    );


                  },


                  icon: const Icon(

                    Icons.fullscreen,

                    color: Colors.white,

                    size: 45,

                  ),

                ),


              ],

            ),


          ],


        )

            :


        const CircularProgressIndicator(

          color: Colors.green,

        ),

      ),


    );

  }

}




class FullScreenVideo extends StatelessWidget {


  final VideoPlayerController controller;


  const FullScreenVideo({

    super.key,

    required this.controller,

  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.black,


      body: Center(

        child: AspectRatio(

          aspectRatio:
          controller.value.aspectRatio,


          child: VideoPlayer(

            controller,

          ),

        ),

      ),


    );

  }

}