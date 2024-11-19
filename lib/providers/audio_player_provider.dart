import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:record/record.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  bool _isPlaying = false;

  String? get currentAudioUrl => _currentAudioUrl;
  bool get isPlaying => _isPlaying;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration> _bufferedSubscription;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _bufferedPosition = Duration.zero;
  Duration get bufferedPosition => _bufferedPosition;
  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  void play(String url) async {
    // _audioPlayer.setAllowsExternalPlayback(true);
    // _audioPlayer.

    if (_currentAudioUrl == url && _isPlaying) {
      // Pause if the same audio is playing
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } else {
      // Stop any current playback
      await _audioPlayer.stop();
      _position = Duration.zero;

      _isPlaying = false;
      notifyListeners();

      // Setup caching audio source
      try {
        final audioSource = LockCachingAudioSource(Uri.parse(url));
        await _audioPlayer.setAudioSource(audioSource).then((duration) async {
          if (duration != null) {
            _duration = duration;
          }
          return duration;
        });

        _currentAudioUrl = url;
        _isPlaying = true;
        await _audioPlayer.play();
        notifyListeners();
      } catch (e) {
        print("Error setting audio source: $e");
      }

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _currentAudioUrl = null;
          notifyListeners();
        }
        if (state.playing) {
          _isPlaying = true;
          notifyListeners();
        } else {
          _isPlaying = false;
          notifyListeners();
        }
      });
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        _position = position;
        notifyListeners();
      });
      // Listen to buffered position updates
      _bufferedSubscription =
          _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
        _bufferedPosition = bufferedPosition;
        notifyListeners();
      });
    }
  }

  void stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentAudioUrl = null;
    _position = Duration.zero;

    notifyListeners();
  }

  // final record = AudioRecorder();

  recordAudio() async {
    // if (await record.hasPermission()) {
    //   // Start recording to file
    //   await record.start(const RecordConfig(), path: 'aFullPath/myFile.m4a');
    //   // ... or to stream
    //   // final stream = await record.startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));
    // }
  }
}
