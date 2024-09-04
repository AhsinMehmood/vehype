// ignore_for_file: prefer_const_constructors

import 'dart:io';

// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerLocal extends StatefulWidget {
  final double height;
  final double widht;
  final File file;
  const VideoPlayerLocal(
      {super.key,
      required this.height,
      required this.widht,
      required this.file});

  @override
  State<VideoPlayerLocal> createState() => _VideoPlayerLocalState();
}

class _VideoPlayerLocalState extends State<VideoPlayerLocal> {
  late VideoPlayerController _controller;
  Image? _thumbnail;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final ChatController chatController = Provider.of<ChatController>(context);

    UserModel userModel = userController.userModel!;
    return Container(
      height: widget.height,
      width: widget.widht,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: _controller.value.isInitialized
          ? Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: VideoPlayer(_controller)),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                      // chatController.pickedMedia = null;
                      setState(() {});
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        color: Colors.white,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        // size: 90,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class VideoPlayerNetwork extends StatefulWidget {
  final String url;
  const VideoPlayerNetwork({super.key, required this.url});

  @override
  State<VideoPlayerNetwork> createState() => _VideoPlayerNetworkState();
}

class _VideoPlayerNetworkState extends State<VideoPlayerNetwork> {
  late FlickManager flickManager;
  bool loading = false;
  File? file;

  @override
  void initState() {
    super.initState();
    downloadAndGetFile();
  }

  downloadAndGetFile() async {
    try {
      setState(() {
        loading = true;
      });
      Future.delayed(const Duration(seconds: 0)).then((value) async {
        if (Platform.isIOS) {
          file = await ChatController().saveVideoAndGetFile(widget.url);
          if (file != null) {
            flickManager = FlickManager(
                videoPlayerController: VideoPlayerController.file(file!));
            setState(() {
              loading = false;
            });
          } else {
            flickManager = FlickManager(
                videoPlayerController:
                    VideoPlayerController.networkUrl(Uri.parse(widget.url)));
            setState(() {
              loading = false;
            });
          }
          // flickManager = FlickManager(
          //     videoPlayerController:
          //         VideoPlayerController.networkUrl(Uri.parse(widget.url)));
          // setState(() {
          //   loading = false;
          // });
        } else {
          file = await ChatController().saveVideoAndGetFile(widget.url);
          if (file != null) {
            flickManager = FlickManager(
                videoPlayerController: VideoPlayerController.file(file!));
            setState(() {
              loading = false;
            });
          } else {
            flickManager = FlickManager(
                videoPlayerController:
                    VideoPlayerController.networkUrl(Uri.parse(widget.url)));
            setState(() {
              loading = false;
            });
          }
        }
      });
    } catch (exception) {
      // await Sentry.captureException(
      //   exception,
      //   stackTrace: stackTrace,
      // );
    }
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final ChatController chatController = Provider.of<ChatController>(context);

    UserModel userModel = userController.userModel!;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            (loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Center(
                    child: FlickVideoPlayer(flickManager: flickManager),
                  )),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 10),
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close, color: Colors.white)),
            )
          ],
        ));
  }
}
