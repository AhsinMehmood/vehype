import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers/firebase_storage_provider.dart';
import 'qr_camera_scan.dart';

class ExtractVINFromImageAndCameraUsingAI extends StatefulWidget {
  final ImageSource imageSource;
  const ExtractVINFromImageAndCameraUsingAI(
      {super.key, required this.imageSource});

  @override
  State<ExtractVINFromImageAndCameraUsingAI> createState() =>
      _ExtractVINFromImageAndCameraUsingAIState();
}

class _ExtractVINFromImageAndCameraUsingAIState
    extends State<ExtractVINFromImageAndCameraUsingAI> {
  final MobileScannerController controller = MobileScannerController(
    // cameraResolution: size,
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 500,
    formats: [BarcodeFormat.all],
    returnImage: false,
    torchEnabled: true,
    // invertImage: invertImage,
    // autoZoom: autoZoom,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: const Text("Scan VIN")),
        body: MobileScanner(
      controller: controller,
      onDetect: (result) {
        print(result.barcodes.first.rawValue);
      },
    ));
  }
}
