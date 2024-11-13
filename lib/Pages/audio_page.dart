import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Widgets/audio_message.dart';
import 'package:vehype/const.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final _recorder = AudioRecorder();
  bool isRecording = false;

  String filePath = '';

  void startRecording() async {
    try {
      Directory directory = await getTemporaryDirectory();
      await _recorder.start(const RecordConfig(),
          path:
              '${directory.path}${DateTime.now().microsecondsSinceEpoch}.m4a');
    } catch (e) {
      log(e.toString());
    }
  }

  void stopRecording() async {
    try {
      final path = await _recorder.stop();
      filePath = path ?? 'null';
      log('Recording stopped. File path: $filePath');
      final file = File(filePath);
      if (!await file.exists()) {
        log('File does not exist at the specified path.');
        return;
      }

      ;
      String url = await uploadImage(file, 'user');
      log('Audio URL: $url');
      FirebaseFirestore.instance.collection('audios').add({
        'audioUrl': url,
      });
      log('Audio uploaded successfully: ');
    } catch (e) {
      log(e.toString());
    }
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> uploadImage(File file, String userId) async {
    final poiImageRef = storageRef
        .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.m4a");
    await poiImageRef.putData(file.readAsBytesSync());
    // uploadTaskOne!.
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Audio Settings',
          style: TextStyle(
            fontSize: 17,
          ),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () async {
          if (userController.currentPlayer != null) {
            userController.currentPlayer!.stop();
          }

          startRecording();
          Future.delayed(Duration(seconds: 10)).then((s) {
            stopRecording();
          });
        },
        icon: Icon(Icons.mic),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('audios').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            return ListView.builder(
                itemCount:
                    snapshot.data == null ? 0 : snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      AudioMessage(url: snapshot.data!.docs[index]['audioUrl']),
                      const SizedBox(
                        height: 20,
                      ),
                      // AudioMessage(
                      //     url:
                      //         'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/TU%20AAKE%20DEKH%20LE%20%7C%20KING%20%F0%9F%91%91%20%7C%20SLOWED-REVERB%20%7C%20NIGHT%20RLXX.mp3?alt=media&token=baa5eaf5-2cd5-439e-b54d-375263ad2206'),
                    ],
                  );
                });
          }),
    );
  }
}
