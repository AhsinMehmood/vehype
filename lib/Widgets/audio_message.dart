import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';
import 'package:vehype/providers/audio_player_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'audio_video_progress.dart';

class AudioMessage extends StatefulWidget {
  final String url;

  const AudioMessage({super.key, required this.url});

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  Duration totalDuration = Duration.zero;
  Duration position = Duration.zero;
  Duration bufferedPosition = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool loading = false;

  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration> _bufferedSubscription;
  late StreamSubscription<bool> playingStream;
  late StreamSubscription<PlaybackEvent> playbackEventStream;
  // late Stream<WaveformProgress> progressStream;
  File? waveFile;
  @override
  void initState() {
    super.initState();
    getDuration();
    final userControler = Provider.of<UserController>(context, listen: false);

    playingStream = audioPlayer.playingStream.listen((bool playing) {
      isPlaying = playing;
      setState(() {});
    });
    playbackEventStream = audioPlayer.playbackEventStream.listen((onData) {
      if (onData.processingState == ProcessingState.completed) {
        audioPlayer.pause();

        // audioPlayer.stop();

        setState(() {
          position = Duration.zero;
          userControler.currentPlayer = null;
          isPlaying = false;
        });
      }
      if (onData.processingState == ProcessingState.loading) {
        loading = true;
        setState(() {});
      }
      if (onData.processingState == ProcessingState.ready) {
        loading = false;
        setState(() {});
      }
    });
    _positionSubscription = audioPlayer.positionStream.listen((positions) {
      if (positions == totalDuration) {
        position = Duration.zero;
      } else {
        position = positions;
      }
      // notifyListeners();
      setState(() {});
    });
    // Listen to buffered position updates
    _bufferedSubscription =
        audioPlayer.bufferedPositionStream.listen((bufferedPositio) {
      bufferedPosition = bufferedPositio;
      // notifyListeners();
      setState(() {});
    });
    // progressStream.listen((WaveformProgress waveProgress) {});
  }

  getDuration() async {
    try {
      final audioSource = AudioSource.uri(Uri.parse(widget.url));
      // File audioFile = await audioSource.cacheFile;
      // final waveFile =
      //     File(p.join((await getTemporaryDirectory()).path, 'waveform.wave'));

      // final audioManager = Provider.of<AudioPlayerProvider>(context, listen: false);
      // progressStream = JustWaveform.extract(
      //   audioInFile: audioFile,
      //   waveOutFile: waveFile,
      //   zoom: const WaveformZoom.pixelsPerSecond(100),
      // );

      await audioPlayer.setAudioSource(audioSource).then((duration) async {
        if (duration != null) {
          totalDuration = duration;
        }
        setState(() {});
        return duration;
      });
      audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      dev.log(e.toString());
    }
  }

  String _getTimeString(Duration time) {
    final minutes =
        time.inMinutes.remainder(Duration.minutesPerHour).toString();
    final seconds = time.inSeconds
        .remainder(Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0');
    return time.inHours > 0
        ? "${time.inHours}:${minutes.padLeft(2, "0")}:$seconds"
        : "$minutes:$seconds";
  }

  void seekAudio(Duration position) {
    audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _bufferedSubscription.cancel();
    playbackEventStream.cancel();

    audioPlayer.dispose();
    super.dispose();
  }

  playPause() async {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userControler = Provider.of<UserController>(context);

    return Container(
      // color: Colors.red,
      child: Row(
        children: [
          if (loading)
            CupertinoActivityIndicator()
          else
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                // audioManager.play(widget.url);

                if (userControler.currentPlayer == null) {
                  playPause();

                  userControler.setCurrentPlayer(audioPlayer);
                } else {
                  if (userControler.currentPlayer == audioPlayer) {
                    playPause();
                  } else {
                    userControler.currentPlayer!.pause();
                    playPause();

                    userControler.setCurrentPlayer(audioPlayer);
                  }
                }

                setState(() {});
              },
            ),
          SizedBox(
            width: 45,
            child: Text(_getTimeString(isPlaying ? position : totalDuration)),
          ),
          Expanded(
            child: ProgressBar(
              barHeight: 0.0,
              progress: position,
              total: totalDuration,
              progressBarColor: Colors.green,
              baseBarColor: Colors.cyan,
              timeLabelLocation: TimeLabelLocation.none,

              onSeek: seekAudio,
              buffered: bufferedPosition, // Handle seek interaction
            ),
          ),
          SizedBox(
            width: 45,
          )
        ],
      ),
    );
  }
}

class WaveformSeekbar extends StatelessWidget {
  final List<int> waveformData;
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const WaveformSeekbar({
    super.key,
    required this.waveformData,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // onHorizontalDragUpdate: (details) {
        //   final seekPosition =
        //       (details.localPosition.dx / context.size!.width) *
        //           duration.inMilliseconds;
        //   onSeek(Duration(milliseconds: seekPosition.toInt()));
        // },
        child: SquigglyWaveform(
      samples: waveformData.map((e) => e.toDouble()).toList(),
      height: 50,
      width: 301,
      activeColor: Colors.green,
      inactiveColor: Colors.blueAccent,
      maxDuration: duration,
      elapsedDuration: position,
    ));
  }
}
