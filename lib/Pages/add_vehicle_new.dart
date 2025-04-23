// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:vehype/Controllers/garage_controller.dart';
// import 'package:vehype/Controllers/user_controller.dart';
// import 'package:vehype/Controllers/vehicle_data.dart';

// import 'package:vehype/Pages/add_vehicle.dart';
// import 'package:vehype/Pages/scan_vin.dart';
// import 'package:vehype/const.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'; // Import Google ML Kit Image Labeling

// import '../Models/vehicle_model.dart';

// class AddVehiclePage extends StatefulWidget {
//   const AddVehiclePage({super.key});

//   @override
//   State<AddVehiclePage> createState() => _AddVehiclePageState();
// }

// class _AddVehiclePageState extends State<AddVehiclePage> {
//   final TextEditingController vinController = TextEditingController();
//   bool isVinNotEmpty = false;
//   bool isVinValid = false;
//   bool isLoading = false;
//   String vehicleInfo = '';

//   @override
//   void initState() {
//     super.initState();
//     vinController.addListener(() {
//       setState(() {
//         isVinNotEmpty = vinController.text.trim().isNotEmpty;
//         isVinValid = _isValidVin(vinController.text.trim());
//       });
//     });
//   }

//   // Local VIN Validation (17 characters, no O, I, Q)
//   bool _isValidVin(String vin) {
//     final vinRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$', caseSensitive: false);
//     return vinRegex.hasMatch(vin);
//   }

//   Future<void> fetchVehicleByVIN(String vin) async {
//     String jwtToken = await getJwtToken();
//     String vinApi = 'https://carapi.app/api/vin/$vin';

//     try {
//       http.Response response = await http.get(
//         Uri.parse(vinApi),
//         headers: {
//           'Content-type': 'application/json',
//           'Authorization': 'Bearer $jwtToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         print('Vehicle Data: $data');
//       } else {
//         print(
//             'Failed to fetch vehicle data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> _captureVin() async {
//     String? scannedVin = await Get.to(() => VinScannerPage());
//     if (scannedVin != null) {
//       setState(() {
//         vinController.text = scannedVin;
//         isVinValid = scannedVin.length == 17;
//       });
//     }
//   }

//   List<VehicleType> vehicleTypeList = [
//     VehicleType(
//         title: "Passenger vehicles", icon: 'assets/passenger_vehicle.svg'),
//     VehicleType(title: "Pickup Trucks", icon: 'assets/pickup_truck_light.svg'),
//     VehicleType(title: "Motorcycles", icon: 'assets/motorcycle.svg'),
//     VehicleType(title: "Bus/Van", icon: 'assets/bus.svg'),
//     VehicleType(title: "Semi-trucks", icon: 'assets/truck.svg'),
//     VehicleType(title: "Trailers", icon: 'assets/trailer.svg'),
//     VehicleType(
//         title: "Incomplete Vehicles", icon: 'assets/incomplete_vehicle.svg'),
//     VehicleType(
//         title: "Low-speed vehicles", icon: 'assets/low_speed_vehicle.svg'),
//     VehicleType(
//         title: "Off-road vehicles", icon: 'assets/off_road_vehicle.svg'),
//   ];
// // Function to map vehicle type from VIN API response
//   VehicleType? mapVehicleType(String? apiVehicleType) {
//     if (apiVehicleType == null) return null;

//     apiVehicleType = apiVehicleType.toUpperCase();

//     if (apiVehicleType.contains("PASSENGER")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Passenger vehicles");
//     } else if (apiVehicleType.contains("PICKUP") ||
//         apiVehicleType.contains("MPV")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Pickup Trucks");
//     } else if (apiVehicleType.contains("MOTORCYCLE")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Motorcycles");
//     } else if (apiVehicleType.contains("BUS") ||
//         apiVehicleType.contains("VAN")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Bus/Van");
//     } else if (apiVehicleType.contains("TRUCK")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Semi-trucks");
//     } else if (apiVehicleType.contains("TRAILER")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Trailers");
//     } else if (apiVehicleType.contains("INCOMPLETE")) {
//       return vehicleTypeList
//           .firstWhere((v) => v.title == "Incomplete Vehicles");
//     } else if (apiVehicleType.contains("LOW SPEED")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Low-speed vehicles");
//     } else if (apiVehicleType.contains("OFF ROAD")) {
//       return vehicleTypeList.firstWhere((v) => v.title == "Off-road vehicles");
//     } else {
//       return null;
//     }
//   }

//   Future<String?> extractVinFromImage(ImageSource imageSource) async {
//     // Pick an image from gallery
//     final pickedFile = await ImagePicker().pickImage(source: imageSource);
//     if (pickedFile == null) return null;

//     final inputImage = InputImage.fromFilePath(pickedFile.path);
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final RecognizedText recognizedText =
//         await textRecognizer.processImage(inputImage);

//     // Regex to match VIN (17 characters: digits & uppercase letters, no O, I, Q)
//     // final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');

//     for (TextBlock block in recognizedText.blocks) {
//       for (TextLine line in block.lines) {
//         await textRecognizer.close();

//         return line.text.trim();
//       }
//     }

//     await textRecognizer.close();
//     return null;
//   }

//   void _scanVinFromGallery() async {
//     final vin = await extractVinFromImage(ImageSource.gallery);
//     if (vin != null) {
//       setState(() {
//         vinController.text = vin;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No VIN found in the image')),
//       );
//     }
//   }

//   void _scanVinFromCamera() async {
//   final vin = await extractVinFromImage(ImageSource.camera);
//     if (vin != null) {
//       setState(() {
//         vinController.text = vin;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No VIN found in the image')),
//       );
//     }
//   }

//   // Call NHTSA API with VIN
//   Future<void> _fetchVehicleData(String vin) async {
//     setState(() {
//       isLoading = true;
//       vehicleInfo = '';
//     });

//     final url =
//         'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/$vin?format=json';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<dynamic> results = data['Results'];

//         String make = results.firstWhere((e) => e['Variable'] == 'Make',
//                 orElse: () => null)?['Value'] ??
//             'Unknown';
//         String model = results.firstWhere((e) => e['Variable'] == 'Model',
//                 orElse: () => null)?['Value'] ??
//             'Unknown';
//         String year = results.firstWhere((e) => e['Variable'] == 'Model Year',
//                 orElse: () => null)?['Value'] ??
//             'Unknown';

//         String vehicleType = results.firstWhere(
//                 (e) => e['Variable'] == 'Vehicle Type',
//                 orElse: () => null)?['Value'] ??
//             'Unknown';
//         VehicleType? mappedType = mapVehicleType(vehicleType);
//         // Fetch trims from Car API
//         String carApiUrl =
//             'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
//         String jwtToken = await getJwtToken(); // Replace with your token

//         final carApiResponse = await http.get(Uri.parse(carApiUrl), headers: {
//           'Content-type': 'application/json',
//           'Authorization': 'Bearer $jwtToken',
//         });

//         String trims = 'No trims found';
//         List<dynamic> listTrims = [];
//         log(carApiResponse.body.toString());

//         if (carApiResponse.statusCode == 200) {
//           final carApiData = json.decode(carApiResponse.body);
//           List<dynamic> trimsList = carApiData['data'] ?? [];
//           listTrims = trimsList;
//           if (trimsList.isNotEmpty) {
//             trims = trimsList.first['description'];
//           }
//         } else {
//           print('Failed to fetch trims: ${carApiResponse.statusCode}');
//         }

//         setState(() {
//           vehicleInfo =
//               'Make: $make\nModel: $model\nYear: $year\nVehicle Type: ${mappedType?.title ?? "Unknown"}\nTrims: $trims';
//         });
//         final GarageController garageController =
//             Provider.of<GarageController>(context, listen: false);

//         await garageController.initVehicleForVin(
//             bodyStyle: mappedType?.title ?? '',
//             make: make,
//             model: model,
//             submodel: listTrims,
//             year: year);
//         Get.to(() => AddVehicle(
//               garageModel: null,
//               vin: vin,
//               query:
//                   'Make: $make Model: $model Year: $year Vehicle Type: ${mappedType?.title ?? ""}',
//             ));
//       } else {
//         throw Exception('Failed to load vehicle data');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _submitVin() {
//     String vin = vinController.text.trim();
//     if (_isValidVin(vin)) {
//       _fetchVehicleData(vin);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Invalid VIN. Please check and try again.')),
//       );
//     }
//   }

//   Future<Map<String, String>?> detectVehicleFromImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) return null;

//     final inputImage = InputImage.fromFilePath(pickedFile.path);
//     final imageLabeler =
//         ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
//     final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

//     Map<String, String> vehicleDetails = {};

//     for (ImageLabel label in labels) {
//       if (label.label.toLowerCase().contains("car") ||
//           label.label.toLowerCase().contains("truck") ||
//           label.label.toLowerCase().contains("vehicle") ||
//           label.label.toLowerCase().contains("maserati")) {
//         // You can add more specific label checks if needed
//         vehicleDetails['vehicleType'] = label.label;
//       } else if (label.label.toLowerCase().contains("maserati")) {
//         vehicleDetails['make'] = "Maserati";
//       }
//       log(label.label.toString());
//     }
//     await imageLabeler.close();
//     return vehicleDetails;
//   }

//   @override
//   void dispose() {
//     vinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final UserController userController = Provider.of<UserController>(context);
//     return Scaffold(
//       backgroundColor: userController.isDark ? primaryColor : Colors.white,
//       appBar: AppBar(
//         title: const Text('Add Vehicle'),
//         backgroundColor: userController.isDark ? primaryColor : Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // VIN Entry Section
//             TextField(
//               controller: vinController,
//               decoration: InputDecoration(
//                 labelText: 'Enter VIN',
//                 suffixIcon: vinController.text.isNotEmpty
//                     ? (isVinValid
//                         ? const Icon(Icons.check_circle, color: Colors.green)
//                         : const Icon(Icons.error, color: Colors.red))
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             if (!isVinNotEmpty)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           // backgroundColor: userController.isDark ?
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4),
//                           )),
//                       icon: Icon(
//                         Icons.camera_alt_outlined,
//                         color:
//                             userController.isDark ? primaryColor : Colors.white,
//                       ),
//                       label: Text(
//                         'Camera',
//                         style: TextStyle(
//                           color: userController.isDark
//                               ? primaryColor
//                               : Colors.white,
//                         ),
//                       ),
//                       onPressed: _scanVinFromCamera,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4),
//                           )),
//                       icon: Icon(
//                         Icons.photo,
//                         color:
//                             userController.isDark ? primaryColor : Colors.white,
//                       ),
//                       label: Text(
//                         'Gallery',
//                         style: TextStyle(
//                           color: userController.isDark
//                               ? primaryColor
//                               : Colors.white,
//                         ),
//                       ),
//                       onPressed: _scanVinFromGallery,
//                     ),
//                   ),
//                 ],
//               ),

//             if (!isVinNotEmpty) const SizedBox(height: 10),
//             if (!isVinNotEmpty)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           minimumSize: Size(Get.width * 0.8, 55),
//                           backgroundColor: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           // backgroundColor: userController.isDark ?
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4),
//                           )),
//                       icon: Icon(
//                         Icons.camera_alt_outlined,
//                         color:
//                             userController.isDark ? primaryColor : Colors.white,
//                       ),
//                       label: Text(
//                         'Barcode Scanner',
//                         style: TextStyle(
//                           color: userController.isDark
//                               ? primaryColor
//                               : Colors.white,
//                         ),
//                       ),
//                       onPressed: _captureVin,
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 10),

//             // Privacy Info
//             Text(
//               'Why do we need your VIN?\n'
//               '- To accurately identify your vehicle.\n'
//               '- We respect your privacy and do not share this information.',
//               style: TextStyle(
//                   color: userController.isDark
//                       ? Colors.white70
//                       : primaryColor.withOpacity(0.8),
//                   fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             // Loading Indicator
//             if (isLoading) const Center(child: CircularProgressIndicator()),

//             // Vehicle Info Display

//             // Show Submit Button only if VIN is not empty
//             if (isVinNotEmpty)
//               Expanded(
//                 child: Center(
//                   child: ElevatedButton(
//                     onPressed: _submitVin,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(Get.width * 0.85, 55),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       backgroundColor:
//                           userController.isDark ? Colors.white : primaryColor,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 15),
//                     ),
//                     child: Text('Submit',
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: userController.isDark
//                                 ? primaryColor
//                                 : Colors.white)),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Divider
//             const Divider(thickness: 1),
//             const SizedBox(height: 20),

//             // Manual Entry Option
//             if (!isVinNotEmpty)
//               Expanded(
//                 child: Center(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       // Navigate to manual entry page
//                       Get.to(() => AddVehicle(garageModel: null));
//                     },
//                     icon: Icon(Icons.directions_car,
//                         color: userController.isDark
//                             ? primaryColor
//                             : Colors.white),
//                     label: Text('Enter Manually',
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: userController.isDark
//                                 ? primaryColor
//                                 : Colors.white)),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(Get.width * 0.85, 55),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       backgroundColor:
//                           userController.isDark ? Colors.white : primaryColor,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 40, vertical: 15),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
