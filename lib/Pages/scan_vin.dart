// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
// import 'package:provider/provider.dart';
// import 'package:vehype/Controllers/user_controller.dart';
// import 'package:vehype/const.dart';

// class VinScannerPage extends StatefulWidget {
//   const VinScannerPage({super.key});

//   @override
//   _VinScannerPageState createState() => _VinScannerPageState();
// }

// class _VinScannerPageState extends State<VinScannerPage> {
//   MobileScannerController cameraController = MobileScannerController();
//   final ImagePicker _picker = ImagePicker();
//   // Handle gallery photo selection
//   void _pickFromGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       final File imageFile = File(image.path);
//       final BarcodeCapture? capture =
//           await cameraController.analyzeImage(imageFile.path);
//       if (capture != null) {
//         final List<Barcode?> barcodes = capture.barcodes;
//         if (barcodes.isNotEmpty) {
//           String scannedVin = barcodes.first!.rawValue ?? '';
//           if (scannedVin.isNotEmpty) {
//             Navigator.pop(context, scannedVin);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('No VIN detected in the image.'),
//             ));
//           }
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('No VIN detected in the image.'),
//         ));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }

//   void _barcodeScan() async {
//     var result = await BarcodeScanner.scan();
//     if (result.rawContent.isNotEmpty) {
//       Navigator.pop(context, result.rawContent);
//     }
//   }

//   final TextRecognizer _textRecognizer =
//       TextRecognizer(script: TextRecognitionScript.latin);

//   Future<void> _processImage(InputImage inputImage) async {
//     try {
//       if (_isProcessing) return;
//       _isProcessing = true;

//       final RecognizedText recognizedText =
//           await _textRecognizer.processImage(inputImage);

//       // VIN pattern: 17 characters, uppercase letters & digits, no I, O, Q
//       final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');

//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           final match = vinRegex.firstMatch(line.text);
//           if (match != null) {
//             Navigator.pop(context, match.group(0)); // Return detected VIN
//             return;
//           }
//         }
//       }
//     } catch (e) {
//       print('Error recognizing text: $e');
//     } finally {
//       _isProcessing = false;
//     }
//   }

//   bool _isProcessing = false; // Add this flag at the top of your widget class

//   @override
//   Widget build(BuildContext context) {
//     final UserController userController = Provider.of<UserController>(context);
//     return Scaffold(
//       backgroundColor: userController.isDark ? primaryColor : Colors.white,
//       appBar: AppBar(
//         backgroundColor: userController.isDark ? primaryColor : Colors.white,
//         title: Text(
//           'Scan VIN',
//           style: TextStyle(
//             color: userController.isDark ? Colors.white : primaryColor,
//             fontSize: 17,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//             onPressed: () => Get.back(),
//             icon: Icon(
//               Icons.arrow_back_ios_new_outlined,
//             )),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: MobileScanner(
//               controller: cameraController,
//               onDetect: (capture) {
//                 if (_isProcessing) return; // Prevent multiple pops
//                 _isProcessing = true;

//                 final List<Barcode> barcodes = capture.barcodes;
//                 if (barcodes.isNotEmpty) {
//                   String scannedVin = barcodes.first.rawValue ?? '';
//                   if (scannedVin.isNotEmpty) {
//                     Navigator.pop(context, scannedVin);
//                   }
//                 }

//                 // Optional: Reset after a short delay if needed (e.g., for continuous scanning)
//                 Future.delayed(const Duration(seconds: 1), () {
//                   _isProcessing = false;
//                 });
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                   // backgroundColor: userController.isDark ?
//                   shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               )),
//               icon: const Icon(Icons.qr_code_scanner),
//               label: const Text('Use Barcode Scan'),
//               onPressed: _barcodeScan,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                   // backgroundColor: userController.isDark ?
//                   shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               )),
//               icon: const Icon(Icons.photo),
//               label: const Text('Pick from Gallery'),
//               onPressed: _pickFromGallery,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
