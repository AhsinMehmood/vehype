import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
// import 'package:simple_barcode_scanner/enum.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
// import 'package:barcode_scanner/scanbot_barcode_sdk.dart' as scanbot;
// import 'package:scanbot_sdk/rtu_ui_barcode.dart' as scanbotUi;

import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../Models/vehicle_model.dart';
import '../../providers/firebase_storage_provider.dart';
import 'add_vehicle.dart';
import 'qr_camera_scan.dart';
import 'scan_vin.dart'; // Import Google ML Kit Image Labeling

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final TextEditingController vinController = TextEditingController();
  bool isVinNotEmpty = false;
  bool isVinValid = false;
  bool isLoading = false;
  String vehicleInfo = '';

  @override
  void initState() {
    super.initState();
    vinController.addListener(() {
      final vinText = vinController.text.trim();
      final isNowValid = _isValidVin(vinText);

      if (isVinValid != isNowValid) {
        setState(() {
          isVinNotEmpty = vinText.isNotEmpty;
          isVinValid = isNowValid;
        });

        if (isNowValid) {
          _fetchVehicleData(vinText); // 🚀 Call API when valid VIN entered
        }
      } else {
        setState(() {
          isVinNotEmpty = vinText.isNotEmpty;
        });
      }
    });
  }

  // Local VIN Validation (17 characters, no O, I, Q)
  bool _isValidVin(String vin) {
    final vinRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$', caseSensitive: false);
    return vinRegex.hasMatch(vin);
  }

  // Future<void> fetchVehicleByVIN(String vin) async {
  //   String jwtToken = await getJwtToken();
  //   String vinApi = 'https://carapi.app/api/vin/$vin';

  //   try {
  //     http.Response response = await http.get(
  //       Uri.parse(vinApi),
  //       headers: {
  //         'Content-type': 'application/json',
  //         'Authorization': 'Bearer $jwtToken',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       print('Vehicle Data: $data');
  //     } else {
  //       print(
  //           'Failed to fetch vehicle data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> _captureVin() async {
    // await _initScanbotSdk();
    // String? scannedVin = await SimpleBarcodeScannerPage(

    //             );

    // final result = await scanbotUi.SingleScanningMode().;

    // if (result.operationResult == scanbot.OperationResult.SUCCESS) {
    //   final barcodes = result.barcodes;
    //   // Process barcodes as needed
    // }
    // _startBarcodeScanning();
    final scannedVin = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => ExtractVINFromImageAndCameraUsingAI(
                imageSource: ImageSource.camera,
              )),
    );

    if (scannedVin != null) {
      setState(() {
        isVinValid = scannedVin.length == 17;
        if (isVinValid) {
          vinController.text = scannedVin.replaceAll(' ', '');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No VIN found in the barcode')),
          );
        }
      });
    }
  }

  // Future<String?> extractVinFromImage(ImageSource imageSource) async {
  //   // Pick an image from gallery
  //   final pickedFile = await ImagePicker().pickImage(source: imageSource);
  //   if (pickedFile == null) return null;

  //   final inputImage = InputImage.fromFilePath(pickedFile.path);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText =
  //       await textRecognizer.processImage(inputImage);

  //   // Regex to match VIN (17 characters: digits & uppercase letters, no O, I, Q)
  //   // final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');

  //   for (TextBlock block in recognizedText.blocks) {
  //     for (TextLine line in block.lines) {
  //       await textRecognizer.close();

  //       return line.text.trim();
  //     }
  //   }

  //   await textRecognizer.close();
  //   return null;
  // }

  // void _scanVinFromGallery() async {
  //   final scannedVin = await Navigator.push<String>(
  //     context,
  //     MaterialPageRoute(
  //         builder: (_) => const ExtractVINFromImageAndCameraUsingAI(
  //               imageSource: ImageSource.gallery,
  //             )),
  //   );

  //   if (scannedVin != null) {
  //     setState(() {
  //       isVinValid = scannedVin.length == 17;
  //       if (isVinValid) {
  //         vinController.text = scannedVin.replaceAll(' ', '');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('No VIN found in the barcode')),
  //         );
  //       }
  //     });
  //   }
  // }

  // void _scanVinFromCamera() async {
  //   final scannedVin = await Navigator.push<String>(
  //     context,
  //     MaterialPageRoute(
  //         builder: (_) => const ExtractVINFromImageAndCameraUsingAI(
  //               imageSource: ImageSource.camera,
  //             )),
  //   );

  //   if (scannedVin != null) {
  //     setState(() {
  //       isVinValid = scannedVin.length == 17;
  //       if (isVinValid) {
  //         vinController.text = scannedVin.replaceAll(' ', '');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('No VIN found in the barcode')),
  //         );
  //       }
  //     });
  //   }
  // }

  // Call NHTSA API with VIN
  Future<void> _fetchVehicleData(String vin) async {
    setState(() {
      isLoading = true;
      vehicleInfo = '';
    });

    final url =
        'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/$vin?format=json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> results = data['Results'];

        String make = results.firstWhere((e) => e['Variable'] == 'Make',
                orElse: () => null)?['Value'] ??
            'Unknown';
        String model = results.firstWhere((e) => e['Variable'] == 'Model',
                orElse: () => null)?['Value'] ??
            'Unknown';
        String year = results.firstWhere((e) => e['Variable'] == 'Model Year',
                orElse: () => null)?['Value'] ??
            'Unknown';

        String vehicleType = results.firstWhere(
                (e) => e['Variable'] == 'Vehicle Type',
                orElse: () => null)?['Value'] ??
            'Unknown';
        VehicleType? mappedType = mapVehicleType(vehicleType);
        // Fetch trims from Car API
        String carApiUrl =
            'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
        String jwtToken = await getJwtToken(); // Replace with your token

        final carApiResponse = await http.get(Uri.parse(carApiUrl), headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        });

        String trims = 'No trims found';
        List<dynamic> listTrims = [];
        log(carApiResponse.body.toString());

        if (carApiResponse.statusCode == 200) {
          final carApiData = json.decode(carApiResponse.body);
          List<dynamic> trimsList = carApiData['data'] ?? [];
          listTrims = trimsList;
          if (trimsList.isNotEmpty) {
            trims = trimsList.first['description'];
          }
        } else {
          print('Failed to fetch trims: ${carApiResponse.statusCode}');
        }

        setState(() {
          vehicleInfo =
              'Make: $make\nModel: $model\nYear: $year\nVehicle Type: ${mappedType?.title ?? "Unknown"}\nTrims: $trims';
        });
        final GarageController garageController =
            Provider.of<GarageController>(context, listen: false);

        await garageController.initVehicleForVin(
            bodyStyle: mappedType?.title ?? '',
            make: make,
            model: model,
            submodel: listTrims,
            year: year);
        Get.to(() => AddVehicle(
              garageModel: null,
              vin: vin,
              query:
                  'Make: $make Model: $model Year: $year Vehicle Type: ${mappedType?.title ?? ""}',
            ));
      } else {
        throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submitVin() {
    String vin = vinController.text.trim();
    if (_isValidVin(vin)) {
      _fetchVehicleData(vin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid VIN. Please check and try again.')),
      );
    }
  }

  Future<void> _pickAndProcessImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    if (pickedFile == null) {
      // Navigator.pop(context); // User cancelled
      return;
    } else {
      final imageFile = File(pickedFile.path);
      Get.dialog(LoadingDialog());

      final vin = await _detectVinWithVertexAI(imageFile);

      if (vin != null) {
        setState(() => vinController.text = vin);
        // Navigator.pop(context, vin.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid VIN. Please check and try again.')),
        );
        // setState(() => _resultText = "Could not detect a valid VIN. Try again.");
      }

      // setState(() => _isProcessing = false);
      // if (mounted) {
      Get.close(1);
    }

    // setState(() => _isProcessing = true);

    // }
  }

  Future<String?> _detectVinWithVertexAI(File imageFile) async {
    try {
      final GenerativeModel model = FirebaseVertexAI.instance.generativeModel(
        systemInstruction: Content.system('''
You are a VIN recognition assistant. A Vehicle Identification Number (VIN) is a 17-character string consisting of capital letters (A-Z, excluding I, O, and Q) and digits (0-9). Extract and return only the VIN from the uploaded image.
'''),
        model: 'gemini-2.0-flash',
      );
      final stopwatch = Stopwatch()..start();

      Uint8List compressBytes =
          await FirebaseStorageProvider().compressFileandGetList(imageFile);
      stopwatch.stop();
      log('Compression took: ${stopwatch.elapsedMilliseconds} ms');
      // String? imageUrl = await firebaseStorageProvider.uploadMedia(im, false);
      // generativeModel.makeRequest(task, params, parse);
      final imagePart = InlineDataPart('image/jpeg', compressBytes);

      final response = await model.generateContent(
        [
          Content.multi([imagePart]),
          Content.text('Extract VIN'),
        ],
      );

      final vinRegex = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
      return vinRegex.firstMatch(response.text ?? '')?.group(0);
    } catch (e) {
      print('Error calling Vertex AI: $e');
      return null;
    }
  }

  // Future<Map<String, String>?> detectVehicleFromImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile == null) return null;

  //   final inputImage = InputImage.fromFilePath(pickedFile.path);
  //   final imageLabeler =
  //       ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  //   final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

  //   Map<String, String> vehicleDetails = {};

  //   for (ImageLabel label in labels) {
  //     if (label.label.toLowerCase().contains("car") ||
  //         label.label.toLowerCase().contains("truck") ||
  //         label.label.toLowerCase().contains("vehicle") ||
  //         label.label.toLowerCase().contains("maserati")) {
  //       // You can add more specific label checks if needed
  //       vehicleDetails['vehicleType'] = label.label;
  //     } else if (label.label.toLowerCase().contains("maserati")) {
  //       vehicleDetails['make'] = "Maserati";
  //     }
  //     log(label.label.toString());
  //   }
  //   await imageLabeler.close();
  //   return vehicleDetails;
  // }

  @override
  void dispose() {
    vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: userController.isDark ? Colors.white : primaryColor,
          ),
        ),
        title: Text(
          'Add Vehicle',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIN Entry Section
              TextField(
                controller: vinController,
                decoration: InputDecoration(
                  labelText: 'Enter VIN',
                  suffixIcon: vinController.text.isNotEmpty
                      ? (isVinValid
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.error, color: Colors.red))
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (!isVinNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 10),

                    // Privacy Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          child: InkWell(
                            onTap: () {
                              _pickAndProcessImage(ImageSource.camera);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 15,
                                top: 15,
                              ),
                              // height: 55,
                              width: Get.width * 0.8,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(),
                                  Column(
                                    children: [
                                      Text(
                                        'VIN Scanner',
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '(More accurately)',
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Image.asset(
                                    'assets/icon.png',
                                    height: 45,
                                    width: 45,
                                  ),
                                  const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),

              if (!isVinNotEmpty) const SizedBox(height: 15),
              if (!isVinNotEmpty)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'VIN Detection via Barcode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(Get.width * 0.85, 50),
                                backgroundColor: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                // backgroundColor: userController.isDark ?
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                            label: Text(
                              'Barcode Scanner',
                              style: TextStyle(
                                color: userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                              ),
                            ),
                            onPressed: _captureVin,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 10),

              // Privacy Info
              Text(
                'Look for the VIN barcode in these common places:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '• Windshield (driver’s side, lower corner)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '• Driver’s side door frame (label/sticker)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '• Under the hood (engine bay)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Privacy Notice:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your VIN is scanned and decoded locally on your device. It is not shared, uploaded, or saved to our servers or AI models.',
              ),
              SizedBox(height: 8),
              Text(
                'The processing happens securely on your device for your privacy.',
              ),
              const SizedBox(height: 20),
              // Loading Indicator
              if (isLoading) const Center(child: CircularProgressIndicator()),

              // Vehicle Info Display

              // Show Submit Button only if VIN is not empty
              if (isVinNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: _submitVin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(Get.width * 0.85, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: Text('Submit',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white)),
                  ),
                ),
              const SizedBox(height: 20),

              const Divider(thickness: 1),
              const SizedBox(height: 20),

              // Manual Entry Option
              if (!isVinNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to manual entry page
                      Get.to(() => AddVehicle(garageModel: null));
                    },
                    icon: Icon(Icons.directions_car,
                        color: userController.isDark
                            ? primaryColor
                            : Colors.white),
                    label: Text('Enter Manually',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(Get.width * 0.85, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
