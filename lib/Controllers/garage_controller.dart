// ignore_for_file: prefer_const_constructors

import 'dart:io';
// import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:image_select/image_selector.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Models/vehicle_model.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';

class GarageController with ChangeNotifier {
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

  selectVehicleType(VehicleType? vehicleType) {
    selectedVehicleMake = null;
    selectedVehicleModel = null;
    selectedYear = '';

    selectedVehicleType = vehicleType;
    notifyListeners();
  }

  selectModel(VehicleModel newBodyStyle) {
    selectedVehicleModel = newBodyStyle;
    // selectedVehicleMake = null;
    // selectedYear = '';

    notifyListeners();
  }

  selectMake(VehicleMake newBodyStyle) {
    selectedVehicleMake = newBodyStyle;
    selectedYear = '';
    selectedVehicleModel = null;

    notifyListeners();
  }

  selectYear(String newBodyStyle) {
    selectedYear = newBodyStyle;
    selectedVehicleModel = null;

    notifyListeners();
  }

  bool imageOneLoading = false;
  bool imageTwoLoading = false;
  ImageSelect imageSelector = ImageSelect(
    compressImage: false,
  );
  List<RequestImageModel> requestImages = [];
  removeRequestImage(int index) {
    requestImages.removeAt(index);
    notifyListeners();
  }

  final ImagePicker picker = ImagePicker();
  selectRequestImageUpdateSingleImage(
      ImageSource imageSource, String userId, int index) async {
    final XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      requestImages.removeAt(index);
      requestImages.insert(
          index,
          RequestImageModel(
              imageUrl: '',
              isLoading: true,
              progress: 0.4,
              imageFile: File(image.path)));
      notifyListeners();
      uploadRequestImage(requestImages[index], userId);
    }
  }

  selectRequestImage(ImageSource imageSource, String userId) async {
    if (imageSource == ImageSource.camera) {
      final XFile? image = await picker.pickImage(source: imageSource);
      if (image != null) {
        requestImages.add(RequestImageModel(
            imageUrl: '',
            isLoading: true,
            progress: 0.4,
            imageFile: File(image.path)));
        for (var element in requestImages) {
          if (element.imageUrl != '') {
            uploadRequestImage(element, userId);
          }
        }
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage();
      List<RequestImageModel> selectedImage = [];

      for (var i = 0; i < images.length; i++) {
        selectedImage.add(RequestImageModel(
            imageUrl: '',
            isLoading: true,
            progress: 0.4,
            imageFile: File(images[i].path)));
      }
      if (selectedImage.length + requestImages.length >= 3) {
        // requestImages.addAll(selectedImage.sublist(0, 3));
      } else {
        requestImages.addAll(selectedImage);
      }
      notifyListeners();
      for (RequestImageModel requestImageModel in requestImages) {
        if (requestImageModel.imageUrl == '') {
          uploadRequestImage(requestImageModel, userId);
        }
      }
    }
  }

  uploadRequestImage(RequestImageModel requestImageModel, String userId) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      requestImageModel.imageFile!.absolute.path,
      quality: 100,
      percentage: 50,
    );
    final storageRef = FirebaseStorage.instance.ref();

    final ref = storageRef
        .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.jpg");
    UploadTask uploadTask = ref.putFile(compressedFile);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      print('Upload progress: $progress');
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
      print('Upload complete');
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  selectImage(BuildContext context, UserModel userModel, int index) async {
    File? selectedFile = await imageSelector.pickImage(
        context: context, source: ImageFrom.gallery);
    if (selectedFile != null) {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      File file = await FlutterNativeImage.compressImage(
        selectedFile.absolute.path,
        quality: 100,
        percentage: 50,
        // targetHeight: 720,
        // targetWidth: 720,
      );
      Get.close(1);
      if (index == 0) {
        selectedImageOne = file;
        imageOneUrl = '';
        imageOneLoading = true;
        notifyListeners();

        String secondImageUrl = await uploadImage(file, userModel.userId);
        imageOneUrl = secondImageUrl;
        imageOneLoading = false;

        notifyListeners();
      } else {
        selectedImageTwo = file;
        imageTwoUrl = '';
        imageTwoLoading = true;

        notifyListeners();

        String secondImageUrl = await uploadImage(file, userModel.userId);
        imageTwoUrl = secondImageUrl;
        imageTwoLoading = false;

        notifyListeners();
      }

      notifyListeners();
    }
  }

  bool saveButtonValidation() {
    if (selectedVehicleType != null &&
        selectedVehicleMake != null &&
        selectedVehicleModel != null) {
      return true;
    } else {
      return false;
    }
  }

  GarageModel? editGarage;

  saveVehicle(UserModel userModel, String vin, String descp,
      bool isCreateRequest) async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    if (editGarage != null) {
      String id = editGarage!.garageId;
      await FirebaseFirestore.instance.collection('garages').doc(id).update({
        'ownerId': userModel.userId,
        'bodyStyle': selectedVehicleType!.title,
        'make': selectedVehicleMake!.title,
        'year': selectedYear,
        'model': selectedVehicleModel!.title,
        'vin': vin,
        'description': descp,
        'imageOne': imageOneUrl,
        'imageTwo': imageTwoUrl,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } else {
      await FirebaseFirestore.instance.collection('garages').add({
        'ownerId': userModel.userId,
        'bodyStyle': selectedVehicleType!.title,
        'make': selectedVehicleMake!.title,
        'year': selectedYear,
        'model': selectedVehicleModel!.title,
        'vin': vin,
        'description': descp,
        'imageOne': imageOneUrl,
        'imageTwo': imageTwoUrl,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    }
    if (isCreateRequest) {
      // selectVehicle(vehicle);
    }

    Get.close(2);
    // selectedImages.clear();

    disposeController();
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
    selectedVehicleType = getVehicleType()
        .where((element) => element.title == garageModel.bodyStyle)
        .first;
    selectedVehicleMake = VehicleMake(
        id: 1, title: garageModel.make, icon: 'icon', vehicleTypeId: 0);
    selectedVehicleModel = VehicleModel(
        id: 1,
        title: garageModel.model,
        icon: 'icon',
        vehicleMakeId: 0,
        vehicleTypeId: 0);
    imageOneUrl = garageModel.imageOne;
    imageTwoUrl = garageModel.imageTwo;
    selectedYear = garageModel.year;
    editGarage = garageModel;
    notifyListeners();
  }

  disposeController() {
    selectedVehicleType = null;
    selectedVehicleMake = null;
    selectedVehicleModel = null;
    imageOneUrl = '';
    imageTwoUrl = '';
    selectedYear = '';
    editGarage = null;
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
        .orderBy('createdAt', descending: true)
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

  selectVehicle(String vehicle, String imageUrl, String garageIds) {
    selectedVehicle = vehicle;
    garageId = garageIds;
    imageOneUrl = imageUrl;
    notifyListeners();
  }

  String selectedIssue = '';
  selectIssue(String vehicle) {
    if (vehicle == selectedIssue) {
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
    if (selectedVehicle != '' && selectedIssue != '' && !imageTwoLoading) {
      return true;
    } else {
      return false;
    }
  }

  saveRequest(String desc, LatLng latLng, String userId, String? offerId,
      String garageId) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      print(userId);
      List images = [];
      for (var element in requestImages) {
        images.add(element.imageUrl);
      }

      if (offerId != null) {
        await FirebaseFirestore.instance
            .collection('offers')
            .doc(offerId)
            .update({
          'ownerId': userId,
          'vehicleName': selectedVehicle,
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
        await FirebaseFirestore.instance.collection('offers').add({
          'ownerId': userId,
          'vehicleName': selectedVehicle,
          'issue': selectedIssue,
          'lat': latLng.latitude,
          'garageId': garageId,
          'long': latLng.longitude,
          'description': desc,
          'imageOne': imageOneUrl,
          'status': 'active',
          'images': images,
          'additionalService': additionalService,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      }

      disposeController();
      Get.offAll(() => TabsPage());
    } catch (e) {
      print(e);
      Get.close(1);
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
