// ignore_for_file: prefer_const_constructors, empty_catches

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
// import 'package:image_select/image_selector.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Models/vehicle_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:vehype/const.dart';

import 'package:together_ai_sdk/together_ai_sdk.dart';

Future<LatLng> getPlaceLatLng(String placeId) async {
  // Use Google Maps Geocoding API to get lat/lng from place ID
  // You can use any HTTP client like http package or Dio
  // Example using http package:
  String apiKey = 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E';
  String url =
      'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$apiKey';

  // Make the HTTP request
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // Parse the JSON response
    var json = jsonDecode(response.body);
    var location = json['results'][0]['geometry']['location'];
    double lat = location['lat'];
    double lng = location['lng'];
    return LatLng(lat, lng);
  } else {
    throw Exception('Failed to load place details');
  }
}

class GarageController with ChangeNotifier {
  final togetherAI = TogetherAISdk(togetherAIKey);

  Stream<List<GarageModel>> myVehicles(String userId) {
    return FirebaseFirestore.instance
        .collection('garages')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => GarageModel.fromJson(e)).toList());
  }

  String selectedYear = '';

  File? selectedImageOne;
  File? selectedImageTwo;
  String imageOneUrl = '';
  String imageTwoUrl = '';
  // List imagesUrls = [];

  VehicleType? selectedVehicleType;
  VehicleMake? selectedVehicleMake;
  VehicleModel? selectedVehicleModel;
  VehicleModel? selectedSubModel;

  List fuelTypes = [
    'Electric',
    'Hybrid',
    'Petrol',
    'Diesel',
    'LPG',
    'CNG',
  ];

  String selectedFuelType = '';
  selectFuelType(String fuelType) {
    selectedFuelType = fuelType;
    notifyListeners();
  }

  List<VehicleMake> vehiclesMakesByVehicleType = [];
  List<VehicleModel> vehiclesModelsByYear = [];
  List<int> vehicleYearsByMake = [];
  List<VehicleModel> vehicleSubModels = [];
  String jwtToken = '';
  bool isCustomModel = false;
  selectVehicleType(VehicleType? vehicleType) async {
    selectedVehicleMake = null;
    selectedVehicleModel = null;
    selectedYear = '';
    vehiclesMakesByVehicleType = [];
    selectedSubModel = null;
    isCustomModel = false;
    selectedVehicleType = vehicleType;
    notifyListeners();
    jwtToken = await getJwtToken();

    vehiclesMakesByVehicleType =
        await getVehicleMake(vehicleType!.title, jwtToken);
    notifyListeners();
  }

  Future<void> callGetAndSaveDataToFirestore() async {
    try {
      // The URL for the region where your Cloud Function is deployed.
      final url = Uri.parse(
          'https://us-central1-vehype-386313.cloudfunctions.net/getAndSaveDataToFirestore');

      // Since this is an onCall function, we need to send a POST request
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {}), // Sending an empty payload, as no data is required for this function
      );

      // Check the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
        } else {}
      } else {}
    } catch (e) {}
  }

  selectModel(VehicleModel newBodyStyle, bool isCustom) async {
    selectedVehicleModel = newBodyStyle;
    selectedSubModel = null;
    isCustomModel = isCustom;
    notifyListeners();
    if (!isCustom) {
      vehicleSubModels = await getTrims(
          selectedVehicleMake!.title,
          selectedYear,
          selectedVehicleType!.title,
          newBodyStyle.title,
          jwtToken);
      notifyListeners();
    }

    // selectedVehicleMake = null;
    // selectedYear = '';
  }

  selectSubModel(VehicleModel newBodyStyle) async {
    selectedSubModel = newBodyStyle;
    notifyListeners();
  }

  bool isCustomMake = false;
  Future selectMake(VehicleMake newBodyStyle, bool isCustom) async {
    selectedVehicleMake = newBodyStyle;
    isCustomMake = isCustom;

    selectedYear = '';
    selectedVehicleModel = null;
    vehicleYearsByMake = [];
    selectedSubModel = null;

    notifyListeners();

    vehicleYearsByMake =
        await getVehicleYear(newBodyStyle.title, jwtToken, isCustom);

    notifyListeners();
  }

  bool loadingModel = false;
  selectYear(String newBodyStyle) async {
    selectedYear = newBodyStyle;
    selectedVehicleModel = null;
    vehiclesModelsByYear = [];
    selectedSubModel = null;

    // notifyListeners();
    loadingModel = true;
    notifyListeners();
    vehiclesModelsByYear = await getSubModels(selectedVehicleMake!.title,
        newBodyStyle, selectedVehicleType!.title, jwtToken);
    loadingModel = false;

    notifyListeners();
  }

  bool imageOneLoading = false;
  bool imageTwoLoading = false;

  List<RequestImageModel> requestImages = [];
  removeRequestImage(int index) {
    requestImages.removeAt(index);
    notifyListeners();
  }

  final ImagePicker picker = ImagePicker();
  bool isRequestImageLoading = false;
  selectRequestImageUpdateSingleImage(
      ImageSource imageSource, String userId, int index) async {
    final XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      // requestImages.removeAt(index);
      requestImages.insert(
          index,
          RequestImageModel(
              imageUrl: '',
              isLoading: true,
              progress: 0.4,
              imageFile: File(image.path)));
      isRequestImageLoading = true;
      notifyListeners();
      uploadRequestImage(requestImages[index], userId);
    }
  }

  Future<File> writeToFile(ByteData data, String name) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        '$tempPath/$name.jpeg'; // file_01.tmp is dump file, can be anything
    return File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  // selectRequestImage(ImageSource imageSource, String userId) async {
  //   if (imageSource == ImageSource.camera) {
  //     final XFile? image = await picker.pickImage(source: imageSource);
  //     if (image != null) {
  //       requestImages.add(RequestImageModel(
  //           imageUrl: '',
  //           isLoading: true,
  //           progress: 0.4,
  //           imageFile: File(image.path)));
  //       isRequestImageLoading = true;

  //       notifyListeners();
  //       for (var element in requestImages) {
  //         if (element.imageUrl == '') {
  //           uploadRequestImage(element, userId);
  //         }
  //       }
  //     }
  //   } else {
  //     // List<Asset> pickImages = await MultiImagePicker.pickImages(
  //     //     androidOptions: AndroidOptions(
  //     //       maxImages: 3 - requestImages.length,
  //     //     ),
  //     //     iosOptions: IOSOptions(
  //     //         settings: CupertinoSettings(
  //     //             selection: SelectionSetting(
  //     //       max: 3 - requestImages.length,
  //     //     ))));

  //     // images.first.getByteData();
  //     // final List<XFile> images = await picker.pickMultiImage();
  //     List<File> images = [];
  //     Get.dialog(LoadingDialog(),
  //         useSafeArea: false, barrierDismissible: false);
  //     for (Asset asset in pickImages) {
  //       ByteData getFile = await asset.getByteData();
  //       File file = await writeToFile(getFile, asset.name);

  //       images.add(file);
  //     }

  //     List<RequestImageModel> selectedImage = [];

  //     for (var i = 0; i < images.length; i++) {
  //       selectedImage.add(RequestImageModel(
  //           imageUrl: '',
  //           isLoading: true,
  //           progress: 0.5,
  //           imageFile: File(images[i].path)));
  //     }
  //     Get.close(1);

  //     requestImages.addAll(selectedImage);
  //     if (selectedImage.isNotEmpty) {
  //       isRequestImageLoading = true;
  //     }

  //     // if (selectedImage.length + requestImages.length >= 3) {
  //     //   if (selectedImage.length + requestImages.length == 3) {
  //     //     requestImages.addAll(selectedImage);
  //     //   } else {}
  //     // } else {
  //     //   requestImages.addAll(selectedImage);
  //     // }
  //     notifyListeners();
  //     print(requestImages.length);

  //     for (RequestImageModel requestImageModel in requestImages) {
  //       if (requestImageModel.imageUrl == '') {
  //         uploadRequestImage(requestImageModel, userId);
  //       }
  //     }
  //   }
  // }

  uploadRequestImage(RequestImageModel requestImageModel, String userId) async {
    // File compressed
    final storageRef = FirebaseStorage.instance.ref();

    final ref = storageRef
        .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.jpg");
    UploadTask uploadTask = ref.putFile(requestImageModel.imageFile!);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      requestImageModel.progress = progress; // Update progress in your model
      notifyListeners(); // Notify listeners to update UI
    });
    try {
      await uploadTask;
      uploadTask.whenComplete(() async {
        requestImageModel.imageUrl = await ref.getDownloadURL();
        requestImageModel.isLoading = false;
        notifyListeners(); // Notify listeners to update UI
      });
    } catch (e) {}
  }

  selectImage(BuildContext context, UserModel userModel, int index,
      ImageSource imageSource) async {
    XFile? xFile = await ImagePicker().pickImage(source: imageSource);

    if (xFile != null) {
      File selectedFile = File(xFile.path);
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      // File file = await FlutterNativeImage.compressImage(
      //   selectedFile.absolute.path,
      //   quality: 100,
      //   percentage: 50,
      //   // targetHeight: 720,
      //   // targetWidth: 720,
      // );
      Get.close(1);
      if (index == 0) {
        selectedImageOne = selectedFile;
        imageOneUrl = '';
        imageOneLoading = true;
        notifyListeners();

        String secondImageUrl =
            await uploadImage(selectedFile, userModel.userId);
        imageOneUrl = secondImageUrl;
        imageOneLoading = false;

        notifyListeners();
      } else {
        selectedImageTwo = selectedFile;
        imageTwoUrl = '';
        imageTwoLoading = true;

        notifyListeners();

        String secondImageUrl =
            await uploadImage(selectedFile, userModel.userId);
        imageTwoUrl = secondImageUrl;
        imageTwoLoading = false;

        notifyListeners();
      }

      notifyListeners();
    }
  }

  bool saveButtonValidation() {
    if (selectedVehicleType == null ||
        selectedVehicleMake == null ||
        selectedVehicleModel == null ||
        imageOneLoading) {
      return false;
    }

    if (selectedVehicleType!.title == 'Passenger vehicle' &&
        !isCustomModel &&
        !isCustomMake) {
      return selectedSubModel != null;
    }

    return true;
  }

  GarageModel? editGarage;

  saveVehicle(UserModel userModel, String vin, bool isCreateRequest) async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      if (editGarage != null) {
        String id = editGarage!.garageId;
        await FirebaseFirestore.instance.collection('garages').doc(id).update({
          'ownerId': userModel.userId,
          'bodyStyle': selectedVehicleType!.title,
          'make': selectedVehicleMake!.title,
          'year': selectedYear,
          'model': selectedVehicleModel!.title,
          'subModel': selectedSubModel == null ? '' : selectedSubModel!.title,
          'vin': vin,
          'imageOne': imageOneUrl,
          'isCustomModel': isCustomModel,
          'isCustomMake': isCustomMake,
          'imageTwo': imageTwoUrl,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } else {
        if (imageOneUrl == '') {
          await generateImages(
              'Vehicle type: ${selectedVehicleType!.title} Vehicle Make: ${selectedVehicleMake!.title} Vehicle Model Year: $selectedYear Vehicle Model: ${selectedVehicleModel!.title} Vehicle Trims: ${selectedSubModel == null ? '' : selectedSubModel!.title}',
              userModel.userId);
        }
        await FirebaseFirestore.instance.collection('garages').add({
          'ownerId': userModel.userId,
          'bodyStyle': selectedVehicleType!.title,
          'make': selectedVehicleMake!.title,
          'year': selectedYear,
          'model': selectedVehicleModel!.title,
          'subModel': selectedSubModel == null ? '' : selectedSubModel!.title,
          'vin': vin,
          'imageOne': imageOneUrl,
          'isCustomModel': isCustomModel,
          'isCustomMake': isCustomMake,
          'imageTwo': imageTwoUrl,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      }

      //     String url = await generateVehicleImage(
      //         '${selectedVehicleType!.title} ${selectedVehicleMake!.title} $selectedYear ${selectedVehicleModel!.title} ${selectedSubModel == null ? '' : selectedSubModel!.title}');
      Get.close(2);
      // imageOneUrl = url;
      notifyListeners();
      // print(url);
      disposeController();
    } catch (e) {
      // print(e);
      Get.close(1);
    }
  }

  Future<void> uploadImageFromUrl(String imageUrl, String userId) async {
    try {
      // Fetch the image data from the URL
      final response = await http.get(Uri.parse(imageUrl));
      final storageRef = FirebaseStorage.instance.ref();

      final poiImageRef = storageRef
          .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.jpg");
      if (response.statusCode == 200) {
        // Convert the response body to Uint8List
        Uint8List imageData = response.bodyBytes;

        // Upload the data to Firebase Storage
        // final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        final uploadTask = poiImageRef.putData(imageData);

        // Wait for the upload to complete
        await uploadTask.whenComplete(() => print("Upload completed"));

        // Get the download URL
        String downloadUrl = await poiImageRef.getDownloadURL();
        imageOneUrl = downloadUrl;
        print("Download URL: $downloadUrl");
      } else {
        print("Failed to fetch the image. HTTP status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  generateImages(String datas, String userId) async {
    const url = "https://api.together.xyz/v1/images/generations";
    String apiKey = togetherAIKey; // Replace with your API key.

    final headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "model": "black-forest-labs/FLUX.1-dev",
      "prompt": datas,
      "steps": 10,
      "n": 1,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        // Parse the response if needed:
        final data = jsonDecode(response.body);
        String imageUrl = data['data'][0]['url'];
        await uploadImageFromUrl(imageUrl, userId);
        notifyListeners();
        log(data['data'][0]['url']
            .toString()); // Process or save the image data here.
      } else {
        print("Failed to generate images. Status Code: ${response.statusCode}");
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  // TaskSnapshot? uploadTaskOne;

  Future<String> uploadImage(File file, String userId) async {
    final storageRef = FirebaseStorage.instance.ref();

    final poiImageRef = storageRef
        .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.jpg");
    await poiImageRef.putData(file.readAsBytesSync());
    // uploadTaskOne!.
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  initVehicle(GarageModel garageModel) async {
    await selectVehicleType(
        VehicleType(id: 0, title: garageModel.bodyStyle, icon: ''));
    // await sele(VehicleType(id: 0, title: garageModel.bodyStyle, icon: ''));

    await selectMake(
        VehicleMake(
            id: 1, title: garageModel.make, icon: 'icon', vehicleTypeId: 0),
        garageModel.isCustomMake);
    await selectYear(garageModel.year);

    await selectModel(
        VehicleModel(
            id: 1,
            title: garageModel.model,
            icon: 'icon',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        garageModel.isCustomModel);
    if (garageModel.bodyStyle == 'Passenger vehicle') {
      if (!garageModel.isCustomMake && !garageModel.isCustomModel) {
        await selectSubModel(
          VehicleModel(
            id: 1,
            title: garageModel.submodel,
            icon: 'icon',
            vehicleMakeId: 0,
            vehicleTypeId: 0,
          ),
        );
      }
    }

    imageOneUrl = garageModel.imageUrl;
    // selectedYear = ;
    editGarage = garageModel;
    notifyListeners();
  }

  disposeController() {
    selectedVehicleType = null;
    selectedVehicleMake = null;
    selectedVehicleModel = null;
    selectedSubModel = null;
    endDate = null;
    startDate = null;
    imageOneUrl = '';
    isCustomMake = false;
    isCustomModel = false;
    imageTwoUrl = '';
    selectedYear = '';
    editGarage = null;
    requestImages = [];
    // selectedIssue = '';
    selectedVehicle = '';
    additionalService = '';
    notifyListeners();
  }

  Stream<List<OffersModel>> getRepairOffersPosted(String userId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  Stream<List<OffersModel>> getRepairOffersPostedByVehicle(
      String userId, String vehicleId) {
    return FirebaseFirestore.instance
        .collection('offers')
        // .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .where('garageId', isEqualTo: vehicleId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  Stream<List<OffersModel>> getRepairOffersPostedInactive(String userId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'inactive')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  Stream<List<OffersModel>> getRepairOffersPostedInactiveByVehicle(
      String userId, String garageId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('garageId', isEqualTo: garageId)
        .where('status', isEqualTo: 'inactive')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  Stream<List<OffersModel>> getRepairOffersPostedInProgress(String userId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'inProgress')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  Stream<List<OffersModel>> getRepairOffersPostedInProgressByVehicle(
      String vehicleId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('garageId', isEqualTo: vehicleId)
        .where('status', isEqualTo: 'inProgress')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  List<GarageModel> vehciles = [];
  getVehciles(String userId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('garages')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    List<GarageModel> garage = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      garage.add(GarageModel.fromJson(element));
    }
    vehciles = garage;
    notifyListeners();
  }

  String selectedVehicle = '';
  String garageId = '';
  String vehicleType = '';

  selectVehicle(
      String vehicle, String imageUrl, String garageIds, String type) {
    selectedVehicle = vehicle;
    vehicleType = type;
    garageId = garageIds;
    imageOneUrl = imageUrl;

    notifyListeners();
  }

  // List selectedIssues = [];

  String selectedIssue = '';
  selectIssue(String vehicle) {
    if (selectedIssue == vehicle) {
      selectedIssue = '';
    } else {
      selectedIssue = vehicle;
    }
    notifyListeners();
  }

  String additionalService = '';
  selectAdditionalService(String service) {
    additionalService = service;
    notifyListeners();
  }

  bool saveButtonValidation2() {
    if (selectedVehicle != '' &&
        selectedIssue.isNotEmpty &&
        !requestImages.every((vv) => vv.isLoading == true)) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> saveRequest(String desc, LatLng latLng, String userId,
      String? offerId, String garageId) async {
    try {
      String requestId = '';
      String address =
          await getAddressFromLatLng(latLng.latitude, latLng.longitude);
      List images = [];
      for (var element in requestImages) {
        images.add(element.imageUrl);
      }
      final GeoFirePoint geoFirePoint =
          GeoFirePoint(GeoPoint(latLng.latitude, latLng.longitude));

      if (offerId != null) {
        requestId = offerId;
        await FirebaseFirestore.instance
            .collection('offers')
            .doc(offerId)
            .update({
          'ownerId': userId,
          'vehicleName': selectedVehicle,
          'vehicleType': vehicleType,
          'address': address,
          'geo': geoFirePoint.data,
          'issue': selectedIssue,
          'garageId': garageId,
          'status': 'active',
          'lat': latLng.latitude,
          'long': latLng.longitude,
          'description': desc,
          'imageOne': imageOneUrl,
          'images': images,
          'additionalService': additionalService,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      } else {
        DocumentReference<Map<String, dynamic>> reference =
            await FirebaseFirestore.instance.collection('offers').add({
          'ownerId': userId,
          'vehicleName': selectedVehicle,
          'issue': selectedIssue,
          'vehicleType': vehicleType,
          'lat': latLng.latitude,
          'garageId': garageId,
          'long': latLng.longitude,
          'description': desc,
          'geo': geoFirePoint.data,
          'address': address,
          'imageOne': imageOneUrl,
          'status': 'active',
          'images': images,
          'additionalService': additionalService,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
        requestId = reference.id;
      }

      disposeController();
      return requestId;
    } catch (e) {
      // Get.close(1);
      return '';
    }
  }

  DateTime? startDate;
  DateTime? endDate;
  double price = 0.0;
  bool agreement = false;
  changeAgree() {
    agreement = !agreement;
    notifyListeners();
  }

  selectPrcie(double pric) {
    price = pric;
    notifyListeners();
  }

  selectStartDate(DateTime? startDat) {
    startDate = startDat;
    notifyListeners();
  }

  selectEndDate(DateTime? endDat) {
    endDate = endDat;
    notifyListeners();
  }

  init(OffersReceivedModel offersReceivedModel) {
    endDate = DateTime.parse(offersReceivedModel.endDate).toLocal();
    startDate = DateTime.parse(offersReceivedModel.endDate).toLocal();
    price = offersReceivedModel.price;
    notifyListeners();
  }

  closeOfferSubmit() {
    endDate = null;
    startDate = null;
    price = 0.0;
    agreement = false;
    notifyListeners();
  }
}

class RequestImageModel {
  String imageUrl;
  bool isLoading;
  double progress;
  File? imageFile;

  RequestImageModel(
      {required this.imageUrl,
      required this.isLoading,
      required this.progress,
      required this.imageFile});
}
