// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'dart:developer' as dev;

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:just_waveform/just_waveform.dart';
// import 'package:provider/provider.dart';
// import 'package:vehype/Controllers/user_controller.dart';
// import 'package:vehype/const.dart';
// import 'package:vehype/providers/audio_player_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:voice_message_package/voice_message_package.dart';
// import 'audio_video_progress.dart';
// import 'package:dio/dio.dart';

// class AudioMessage extends StatefulWidget {
//   final String url;
//   final bool isMe;

//   const AudioMessage({super.key, required this.url, required this.isMe});

//   @override
//   State<AudioMessage> createState() => _AudioMessageState();
// }

// class _AudioMessageState extends State<AudioMessage> {
//   // Duration totalDuration = Duration.zero;
//   // Duration position = Duration.zero;
//   // Duration bufferedPosition = Duration.zero;
//   AudioPlayer audioPlayer = AudioPlayer();
//   // bool isPlaying = false;
//   // bool loading = false;

//   // late StreamSubscription<Duration> _positionSubscription;
//   // late StreamSubscription<Duration> _bufferedSubscription;
//   // late StreamSubscription<bool> playingStream;
//   // late StreamSubscription<PlaybackEvent> playbackEventStream;
//   // // late Stream<WaveformProgress> progressStream;
//   // File? waveFile;
//   @override
//   void initState() {
//     super.initState();
//     // getDuration();

//     // progressStream.listen((WaveformProgress waveProgress) {});
//   }

//   // getDuration() async {
//   //   try {
//   //     // final cachedFile = await _downloadAndCacheAudio(widget.url);
//   //     // dev.log(cachedFile!.path);
//   //     await audioPlayer.setUrl(widget.url).then((duration) async {
//   //       if (duration != null) {
//   //         totalDuration = duration;
//   //       }
//   //       setState(() {});
//   //       return duration;
//   //     });
//   //     // audioPlayer.setLoopMode(LoopMode.all);
//   //   } catch (e) {
//   //     dev.log('${e}Heello');
//   //   }
//   // }

//   // final Dio _dio = Dio();

//   // Future<String> _getCacheDirPath() async {
//   //   final dir = await getTemporaryDirectory();
//   //   return dir.path;
//   // }

//   // Future<File?> _downloadAndCacheAudio(String url) async {
//   //   try {
//   //     final cacheDir = await _getCacheDirPath();
//   //     final fileName = url.split('/').last;
//   //     final filePath = '$cacheDir/$fileName';

//   //     final file = File(filePath);

//   //     // Download if file does not already exist in cache
//   //     if (!await file.exists()) {
//   //       final response = await _dio.download(url, filePath);

//   //       if (response.statusCode == 200) {
//   //         return file;
//   //       } else {
//   //         print("Failed to download audio: ${response.statusCode}");
//   //         return null;
//   //       }
//   //     }
//   //     return file;
//   //   } catch (e) {
//   //     print("Error downloading or caching audio: $e");
//   //     return null;
//   //   }
//   // }

//   // String _getTimeString(Duration time) {
//   //   final minutes =
//   //       time.inMinutes.remainder(Duration.minutesPerHour).toString();
//   //   final seconds = time.inSeconds
//   //       .remainder(Duration.secondsPerMinute)
//   //       .toString()
//   //       .padLeft(2, '0');
//   //   return time.inHours > 0
//   //       ? "${time.inHours}:${minutes.padLeft(2, "0")}:$seconds"
//   //       : "$minutes:$seconds";
//   // }

//   // void seekAudio(Duration position) {
//   //   audioPlayer.seek(position);
//   // }

//   // @override
//   // void dispose() {
//   //   _positionSubscription.cancel();
//   //   _bufferedSubscription.cancel();
//   //   playbackEventStream.cancel();

//   //   audioPlayer.dispose();
//   //   super.dispose();
//   // }

//   // playPause() async {
//   //   if (audioPlayer.playing) {
//   //     audioPlayer.pause();
//   //   } else {
//   //     audioPlayer.play();
//   //   }
//   //   setState(() {});
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final userControler = Provider.of<UserController>(context);

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6),
//         color: widget.isMe
//             ? userControler.isDark
//                 ? Colors.white
//                 : primaryColor
//             : changeColor(color: 'F1F1F1'),
//       ),
//       padding: const EdgeInsets.only(
//         top: 8,
//         bottom: 8,
//       ),
//       child: VoiceMessageView(
//         controller: VoiceController(
//           maxDuration: Duration(seconds: 9),
//           isFile: false,
//           audioSrc: widget.url,
//           onComplete: () {
//             /// do something on complete
//           },
//           onPause: () {
//             /// do something on pause
//           },
//           onPlaying: () {
//             /// do something on playing
//           },
//           onError: (err) {
//             /// do somethin on error
//             /// 
//           },
//         ),
//         innerPadding: 12,
//         cornerRadius: 20,
//       ),
//     );
//   }
// }

// class WaveformSeekbar extends StatelessWidget {
//   final List<int> waveformData;
//   final Duration position;
//   final Duration duration;
//   final Function(Duration) onSeek;

//   const WaveformSeekbar({
//     super.key,
//     required this.waveformData,
//     required this.position,
//     required this.duration,
//     required this.onSeek,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         // onHorizontalDragUpdate: (details) {
//         //   final seekPosition =
//         //       (details.localPosition.dx / context.size!.width) *
//         //           duration.inMilliseconds;
//         //   onSeek(Duration(milliseconds: seekPosition.toInt()));
//         // },
//         child: SquigglyWaveform(
//       samples: waveformData.map((e) => e.toDouble()).toList(),
//       height: 50,
//       width: 301,
//       activeColor: Colors.green,
//       inactiveColor: Colors.blueAccent,
//       maxDuration: duration,
//       elapsedDuration: position,
//     ));
//   }
// }
