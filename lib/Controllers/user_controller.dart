// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:math';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_select/image_selector.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/splash_page.dart';
import 'package:http/http.dart' as http;
import 'package:vehype/bad_words.dart';
import '../Widgets/loading_dialog.dart';

enum AccountType {
  seeker,
  provider,
}

class UserController with ChangeNotifier {
  UserModel? _userModel;
  int tabIndex = 0;
  changeTabIndex(int index) {
    tabIndex = index;
    notifyListeners();
  }

  bool isDark = false;
  initTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool theme = sharedPreferences.getBool('isDark') ?? false;
    isDark = theme;
    notifyListeners();
  }

  changeTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isDark', value);
    isDark = value;
    notifyListeners();
  }

  UserModel? get userModel => _userModel;

  void setUserModel(UserModel userModel) {
    _userModel = userModel;

    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      streamSubscription;
  void getUserStream(String userId) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    streamSubscription = stream.listen((event) {
      UserModel newUserModel = UserModel.fromJson(event);
      _userModel = newUserModel;
      notifyListeners();
    });
    notifyListeners();
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> uploadImage(File file, String userId) async {
    final poiImageRef = storageRef
        .child("users/$userId/${DateTime.now().microsecondsSinceEpoch}.jpg");
    await poiImageRef.putData(file.readAsBytesSync());
    // uploadTaskOne!.
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  selectAndUploadImage(
      BuildContext context, UserModel userModel, int index) async {
    ImageSelect imageSelector = ImageSelect(
      compressImage: false,
    );
    File? selectedFile = await imageSelector.pickImage(
        context: context, source: ImageFrom.gallery);
    if (selectedFile != null) {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      File file = await FlutterNativeImage.compressImage(
        selectedFile.absolute.path,
        quality: 100,
        percentage: 50,
        targetHeight: 125,
        targetWidth: 125,
      );

      String imageUrl = await uploadImage(file, userModel.userId);
      Get.close(1);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.userId)
          .update({'profileUrl': imageUrl});

      // notifyListeners();
    }
  }

  logout(UserModel userModel) async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.userId)
        .update({
      'pushToken': '',
    });
    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    GoogleSignIn().disconnect();

    Mixpanel mixpanel = await Mixpanel.init('c40aeb8e3a8f1030b811314d56973f5a',
        trackAutomaticEvents: true);
    mixpanel.reset();
    await FirebaseAuth.instance.signOut();
    OneSignal.logout();
    Get.close(1);

    Get.offAll(() => const ChooseAccountTypePage());
  }

  updateTexts(UserModel userModel, String fieldName, String value) async {
    if (value.isNotEmpty) {
      // if (badWords.contains(value.trim().toLowerCase())) {
      //   Get.showSnackbar(GetSnackBar(
      //     message:
      //         'Vulgar language detected in your input. Please refrain from using inappropriate language.',
      //     duration: const Duration(seconds: 3),
      //     snackPosition: SnackPosition.TOP,
      //   ));
      //   return;
      // }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.userId)
          .update({
        fieldName: value,
      });
    }
  }

  double lat = 0.0;
  double long = 0.0;
  Future<LatLng> getLocations() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(0.0, 0.0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LatLng(0.0, 0.0);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return const LatLng(0.0, 0.0);
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  List selectedServices = [];
  selectServices(String name) {
    if (selectedServices.contains(name)) {
      selectedServices.remove(name);
    } else {
      selectedServices.add(name);
    }
    notifyListeners();
  }

  Stream<List<OffersModel>> getOffersProvider(UserModel userModel) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (event) => event.docs.map((e) => OffersModel.fromJson(e)).toList());
  }

  List<OffersModel> historyOffers = [];
  List<OffersReceivedModel> offersReceivedList = [];
  bool historyLoading = true;
  getRequestsHistorySeeker() async {
    historyLoading = true;
    QuerySnapshot<Map<String, dynamic>> offersReceivedSnapshot =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .where('ownerId', isEqualTo: _userModel!.userId)
            // .orderBy('createdAt', descending: true)
            .get();
    List<OffersReceivedModel> offers = [];
    List<OffersModel> offersList = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> element
        in offersReceivedSnapshot.docs) {
      offers.add(OffersReceivedModel.fromJson(element));
    }

    for (OffersReceivedModel element in offers) {
      DocumentSnapshot<Map<String, dynamic>> offerSnap = await FirebaseFirestore
          .instance
          .collection('offers')
          .doc(element.offerId)
          .get();
      offersList.add(OffersModel.fromJson(offerSnap));
    }
    offersReceivedList = offers;
    historyOffers = offersList;
    historyLoading = false;
    notifyListeners();
  }

//  Stream<OffersReceivedModel?> getSingleOfferForMessaging(String offerId, String providerId) {
//  Stream<QuerySnapshot<Map<String, dynamic>>> snapshot =   FirebaseFirestore.instance
//         .collection('offersReceived')
//         .where('offerId', isEqualTo: offerId).where('offerBy', isEqualTo: providerId).snapshots();

//   }
  bool haveUnread = false;
  changeRead(bool value) {
    haveUnread = value;

    // notifyListeners();
  }

  getRequestsHistoryProvider() async {
    historyLoading = true;
    QuerySnapshot<Map<String, dynamic>> offersReceivedSnapshot =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .where('offerBy', isEqualTo: _userModel!.userId)
            .orderBy('createdAt', descending: true)
            .get();
    List<OffersReceivedModel> offers = [];
    List<OffersModel> offersList = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> element
        in offersReceivedSnapshot.docs) {
      offers.add(OffersReceivedModel.fromJson(element));
    }

    for (OffersReceivedModel element in offers) {
      DocumentSnapshot<Map<String, dynamic>> offerSnap = await FirebaseFirestore
          .instance
          .collection('offers')
          .doc(element.offerId)
          .get();
      offersList.add(OffersModel.fromJson(offerSnap));
    }
    offersReceivedList = offers;
    historyOffers = offersList;
    historyLoading = false;
    notifyListeners();
  }

  cleanHistory() {
    historyLoading = true;
    historyOffers = [];
    offersReceivedList = [];
    notifyListeners();
  }

  List<OffersModel> filterOffers(List<OffersModel> offers, double userLat,
      double userLong, double radiusKm) {
    return offers
        .where((offer) =>
            haversine(userLat, userLong, offer.lat, offer.long) <= radiusKm)
        .toList();
  }

  double toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  deleteUserAccount(String userId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      Get.dialog(LoadingDialog(), barrierDismissible: false);
      if (streamSubscription != null) {
        streamSubscription!.cancel();
      }
      http.Response response = await http.get(
          Uri.parse(
              'https://us-central1-vehype-386313.cloudfunctions.net/deleteUserAccount?uid=$userId'),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        // MixpanelProvider().deletedAccountEvent(user: userModel, reason: reason);

        sharedPreferences.clear();

        // await FirebaseAuth.instance.currentUser!.delete();

        GoogleSignIn().disconnect();
        FirebaseAuth.instance.signOut();
        Get.back();
        // AwesomeNotifications().cancelAll();
        OneSignal.logout();

        Get.offAll(() => const SplashPage());
        return;
      } else {
        Get.back();
      }

      // await FirebaseAuth.instance.currentUser!.reauthenticateWithPopup(provider)
    } catch (exception, stackTrace) {
      Get.back();
      print(exception.toString());
      // await Sentry.captureException(
      //   exception,
      //   stackTrace: stackTrace,
      // );
      // return {};
    }
  }

  bool isAdmin = false;

  checkIsAdmin(String email) async {
    DocumentSnapshot<Map<String, dynamic>> snap =
        await FirebaseFirestore.instance.collection('admin').doc('app').get();
    if (snap.exists) {
      List admins = snap.data()!['admins'] ?? [];
      if (admins.contains(email)) {
        isAdmin = true;
        notifyListeners();
      } else {
        isAdmin = false;
        notifyListeners();
      }
    }
  }

  String currentVersion = '3.0.3.12';

  Future<bool> checkVersion() async {
    DocumentSnapshot<Map<String, dynamic>> snap =
        await FirebaseFirestore.instance.collection('admin').doc('app').get();
    if (!snap.exists) {
      return false;
    }
    AppModel appModel = AppModel.fromJson(snap.data()!);
    if (appModel.versionNumber != currentVersion) {
      return true;
    } else {
      return false;
    }
  }

  blockAndReport(String chatId, String currentUserId, String secondUserId,
      UserModel secondUserModel, String reason) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(secondUserId)
        .update({
      'blockedBy': FieldValue.arrayUnion([currentUserId])
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayUnion([secondUserId])
    });
    DocumentReference<Map<String, dynamic>> reference =
        await FirebaseFirestore.instance.collection('reports').add({
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'status': 'Active',
      'reportBy': currentUserId,
      'reportTo': secondUserId,
      'reason': reason,
    });

    FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  }
}

class AppModel {
  final String versionNumber;

  AppModel({required this.versionNumber});
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(versionNumber: json['version'] ?? '3.0.3.12');
  }
}
