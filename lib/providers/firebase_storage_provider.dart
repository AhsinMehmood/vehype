import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FirebaseStorageProvider with ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  int _uploadSpeed = 0;
  int get uploadSpeed => _uploadSpeed;

  int _timeRemaining = 0;
  int get timeRemaining => _timeRemaining;

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  bool isUploading = false;
  UploadTask? _uploadTask;
  int _uploadedBytes = 0;
  int _totalBytes = 0;
  DateTime _startTime = DateTime.now();
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get uploadProgressStream => _progressController.stream;

  Map<int, double> _uploadProgressmulti = {};
  Map<int, double> get uploadProgressmulti => _uploadProgressmulti;
  Future<Uint8List> compressFileandGetList(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 90,
    );
    // print(file.lengthSync());

    return result!;
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    String targetPath2 = targetPath;
    if (!targetPath2.endsWith('.jpg') && !targetPath2.endsWith('.jpeg')) {
      targetPath2 = '${targetPath2.replaceAll(RegExp(r'\.\w+$'), '')}.jpg';
    }
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath2,
      quality: 70,
      // rotate: 180,
    );

    // print(file.lengthSync());
    // print(result.lengthSync());

    return File(result!.path);
  }

  Future<String?> uploadImage(File imageFile, String userId, int index) async {
    try {
      final extension = path.extension(imageFile.path);

      // Get original file size (before compression)
      final originalSize = imageFile.lengthSync();
      print('Original Size: ${originalSize / 1024} KB');

      final fileName =
          'users/$userId/request_images/${imageFile.path}/$index$extension';
      final tempDir = await getTemporaryDirectory(); // Temporary directory
      final targetPath = path.join(tempDir.path, 'compressed_$index$extension');
      File file = await compressAndGetFile(imageFile, targetPath);
      final compressedSize = file.lengthSync();
      print('Compressed Size: ${compressedSize / 1024} KB');
      final uploadTask = _storage.ref(fileName).putFile(file);

      // Track progress per index
      uploadTask.snapshotEvents.listen((event) {
        _uploadProgressmulti[index] = event.bytesTransferred / event.totalBytes;
        notifyListeners();
      });

      final snapshot = await uploadTask;
      _uploadProgressmulti.remove(index);

      notifyListeners();

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      _uploadProgressmulti.remove(index);
      notifyListeners();
      return null;
    }
  }

  Future<String?> uploadMedia(File file, bool isProfilePic,
      {bool isVideo = false}) async {
    resetUploadState(); // Reset upload state
    isUploading = true;
    notifyListeners();
    int uploadedBytes = 0;
    _totalBytes = file.lengthSync();
    final extension = path.extension(file.path);

    final tempDir = await getTemporaryDirectory(); // Temporary directory
    final targetPath = path.join(tempDir.path,
        'compressed_${DateTime.now().microsecondsSinceEpoch}$extension');
    File compressedFile = isProfilePic == false
        ? await compressAndGetFile(file, targetPath)
        : file;
    // File  = file;

    final ref =
        _storage.ref().child('uploads/${path.basename(compressedFile.path)}');
    _uploadTask = ref.putFile(compressedFile);

    // Listen for upload progress
    _uploadTask!.snapshotEvents.listen((event) {
      if (_isPaused) return; // Pause upload if _isPaused is true

      uploadedBytes = event.bytesTransferred;
      _uploadProgress = uploadedBytes / _totalBytes;

      _uploadSpeed = uploadedBytes ~/
          (DateTime.now().difference(_startTime).inSeconds + 1);
      _timeRemaining = _uploadSpeed > 0
          ? ((_totalBytes - uploadedBytes) ~/ _uploadSpeed)
          : 0;
      // _progressController.add(_uploadProgress);
      notifyListeners();
    });

    // Wait for upload to complete
    final snapshot = await _uploadTask!.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    // _progressController.close();
    isUploading = false;
    notifyListeners();

    return downloadUrl;
  }

  // Method to pause the upload
  void pauseUpload() {
    _isPaused = true;
    notifyListeners();
  }

  // Method to resume the upload
  // Future<void> resumeUpload() async {
  //   _isPaused = false;
  //   await uploadMedia(File(_uploadTask!.snapshot.ref.fullPath),
  //       isVideo: false); // You can pass the same file again
  //   notifyListeners();
  // }

  // Reset the upload progress
  void resetUploadState() {
    _uploadProgress = 0.0;
    _uploadSpeed = 0;
    _timeRemaining = 0;
    _uploadProgressmulti = {};
    _isPaused = false;
    isUploading = false;

    // _progressController.close();
    notifyListeners();
  }
}
