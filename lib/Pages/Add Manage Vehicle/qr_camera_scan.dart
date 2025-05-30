// import 'dart:developer';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// class BarcodeScannerCameraView extends StatefulWidget {
//   final void Function(String vin)? onScan;

//   const BarcodeScannerCameraView({super.key, this.onScan});

//   @override
//   _BarcodeScannerCameraViewState createState() =>
//       _BarcodeScannerCameraViewState();
// }

// class _BarcodeScannerCameraViewState extends State<BarcodeScannerCameraView> {
//   late CameraController _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isBusy = false;
//   CustomPaint? _customPaint;
//   bool _isCameraInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final backCamera = cameras.firstWhere(
//         (cam) => cam.lensDirection == CameraLensDirection.back,
//         orElse: () => throw Exception('No back-facing camera found.'),
//       );

//       _cameraController = CameraController(
//         backCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.yuv420,
//       );

//       await _cameraController.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });

//       _cameraController.startImageStream((CameraImage image) async {
//         if (_isBusy) return;
//         _isBusy = true;

//         try {
//           final inputImage = _convertCameraImage(
//             image,
//             _cameraController.description.sensorOrientation,
//           );
//           final barcodes = await _barcodeScanner.processImage(inputImage);

//           if (barcodes.isNotEmpty) {
//             final vin = barcodes.first.rawValue;
//             if (vin != null && widget.onScan != null) {
//               widget.onScan!(vin);
//             } else {
//               log(vin.toString());
//             }

//             // final painter = BarcodeOverlayPainter(barcodes.first.boundingBox);
//             // setState(() => _customPaint = CustomPaint(painter: painter));
//           } else {
//             // setState(() => _customPaint = null);
//           }
//         } catch (e, stackTrace) {
//           log('Error processing image: $e');
//           log('Stack trace: $stackTrace');
//         } finally {
//           _isBusy = false;
//         }
//       });
//     } catch (e, stackTrace) {
//       log('Error initializing camera: $e');
//       log('Stack trace: $stackTrace');
//     }
//   }

//   InputImage _convertCameraImage(CameraImage image, int rotation) {
//     final WriteBuffer bytes = WriteBuffer();
//     for (final plane in image.planes) {
//       bytes.putUint8List(plane.bytes);
//     }

//     final allBytes = bytes.done().buffer.asUint8List();

//     final InputImageMetadata inputImageData = InputImageMetadata(
//       bytesPerRow: image.planes.first.bytesPerRow,
//       format: InputImageFormat.nv21,
//       size: Size(image.width.toDouble(), image.height.toDouble()),
//       rotation: InputImageRotation.rotation90deg,
//     );

//     return InputImage.fromBytes(bytes: allBytes, metadata: inputImageData);
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isCameraInitialized) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return Stack(
//       children: [
//         Container(height: Get.height, child: CameraPreview(_cameraController)),
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             height: 120,
//             width: Get.width * 0.8,
//             decoration: BoxDecoration(
//                 border:
//                     Border.all(color: Colors.white.withOpacity(0.4), width: 5)),
//             padding: EdgeInsets.all(12),
//             child: Text(
//               "Point at VIN Barcode or QR",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: Get.height,
//             width: Get.width,
//             color: Colors.black.withOpacity(0.4),
//             padding: EdgeInsets.all(12),
//             child: Text(
//               "Point at VIN Barcode or QR",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BarcodeOverlayPainter extends CustomPainter {
//   final Rect boundingBox;

//   BarcodeOverlayPainter(this.boundingBox);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.greenAccent
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke;

//     canvas.drawRect(boundingBox, paint);
//   }

//   @override
//   bool shouldRepaint(covariant BarcodeOverlayPainter oldDelegate) {
//     return oldDelegate.boundingBox != boundingBox;
//   }
// }
