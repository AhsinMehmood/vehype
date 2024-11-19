// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:image_select/image_selector.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/crop_image_page.dart';
import 'package:vehype/Pages/splash_page.dart';
// import 'package:vehype/Pages/tabs_page.dart';
import '../Models/chat_model.dart';
import '../Pages/tabs_page.dart';
import 'package:http/http.dart' as http;
import '../Widgets/loading_dialog.dart';
import 'offers_controller.dart';
import 'offers_provider.dart';
import 'owner_offers_controller.dart';
// import 'package:event_bus/event_bus.dart';

enum AccountType {
  seeker,
  provider,
}

class UserController with ChangeNotifier {
  // EventBus eventBus = EventBus();
  AudioPlayer? currentPlayer;
  setCurrentPlayer(AudioPlayer? event) {
    currentPlayer = event;
    notifyListeners();
  }

  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  int sortByTime = 0;
  int sortByDistance = 0;
  resetSort() {
    sortByTime = 0;
    sortByDistance = 0;
    notifyListeners();
  }

  changeTimeSort() {
    if (sortByTime == 0) {
      sortByTime = 1;
    } else {
      sortByTime = 0;
    }
    notifyListeners();
  }

  changeDistanceSort() {
    if (sortByDistance == 0) {
      sortByDistance = 1;
    } else {
      sortByDistance = 0;
    }
    notifyListeners();
  }

  pushTokenUpdate(String userId) async {
    // NotificationSettings settings = await messaging.getNotificationSettings();

    bool permission = OneSignal.Notifications.permission;
    if (permission) {
      // OneSignal.login(userId);
      await OneSignal.Notifications.requestPermission(true);
      // await OneSignal.Notifications.
      print('object');
      OneSignal.login(userModel!.userId);
    } else {
      Future.delayed(const Duration(seconds: 3)).then((s) {
        Get.bottomSheet(
          NotificationSheet(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        );
      });
    }
  }

  // updateToken(String userId, String pushToken) async {
  //   await FirebaseFirestore.instance.collection('users').doc(userId).update({
  //     'pushToken': pushToken,
  //   });
  // }
  List selectedVehicleTypesFilter = [];

  UserModel? _userModel;
  List selectedServicesFilter = [];
  clearSelectedVehicleeTypes() {
    selectedVehicleTypesFilter = [];
    notifyListeners();
  }

  selectVehicleTypesFilter(String name) {
    if (selectedVehicleTypesFilter.contains(name)) {
      selectedVehicleTypesFilter.remove(name);
    } else {
      selectedVehicleTypesFilter.add(name);
    }
    notifyListeners();
  }

  clearServie() {
    selectedServicesFilter = [];
    notifyListeners();
  }

  selectService(String name) {
    if (selectedServicesFilter.contains(name)) {
      selectedServicesFilter.remove(name);
    } else {
      selectedServicesFilter.add(name);
    }
    notifyListeners();
  }

  int tabIndex = 0;
  bool isShow = false;
  changeIsShow(bool value) {
    isShow = value;
    notifyListeners();
  }

  changeTabIndex(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void updateStatusBarColor(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes status bar transparent
      statusBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark, // Sets the icon brightness
    ));
    notifyListeners();
  }

  bool isDark = false;
  bool sameAsSystem = false;

  initTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool? theme = sharedPreferences.getBool('isDark');
    // If the theme preference is not set, default to system theme
    if (theme == null) {
      // Check the system theme mode and set `isDark` accordingly
      isDark =
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

      sameAsSystem = true;
    } else {
      // Use the saved preference
      isDark = theme;
      sameAsSystem = false;
    }
    updateStatusBarColor(isDark); // Update status bar color

    notifyListeners();
    return theme;
  }

  changeTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isDark', value);
    isDark = value;
    sameAsSystem = false;
    updateStatusBarColor(isDark); // Update status bar color

    notifyListeners();
  }

  sameAsSystemChange() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('isDark');
    isDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    updateStatusBarColor(isDark);
    sameAsSystem = true;
    notifyListeners();
  }

  UserModel? get userModel => _userModel;

  void setUserModel(UserModel userModel) {
    _userModel = userModel;

    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      streamSubscription;
  void getUserStream(String userId, {Function(UserModel)? onDataReceived}) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();

    streamSubscription = stream.listen((event) {
      UserModel newUserModel = UserModel.fromJson(event);
      _userModel = newUserModel;
      notifyListeners();
    });
    notifyListeners();
  }

  void closeStream() {
    streamSubscription?.cancel();
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
    XFile? selectedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (selectedFile != null) {
      File file = File(selectedFile.path);
      Get.to(() => CropImagePage(imageData: file, imageField: ''));
    }

    // notifyListeners();
  }

  logout(UserModel userModel, BuildContext buildContext) async {
    // Get.dialog(const LoadingDialog(), barrierDismissible: false);
    // await updateToken(userModel.userId, '');
    await OneSignal.logout();

    streamSubscription?.cancel();
    OffersProvider offersProvider =
        Provider.of<OffersProvider>(buildContext, listen: false);
    closeStream();
    offersProvider.stopListening();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print(e);
    }
    // Mixpanel mixpanel = await Mixpanel.init('c40aeb8e3a8f1030b811314d56973f5a',
    //     trackAutomaticEvents: true);
    // mixpanel.reset();
    await FirebaseAuth.instance.signOut();

    changeTabIndex(0);

    // Get.close(1);

    // Get.offAll(() => const SplashPage());
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

  List selectedAdditionalServices = [];
  selectAdditionalServices(String name) {
    if (selectedAdditionalServices.contains(name)) {
      selectedAdditionalServices.remove(name);
    } else {
      selectedAdditionalServices.add(name);
    }
    notifyListeners();
  }

  selectAllAdditionalServices(List services) {
    selectedAdditionalServices = services;
    notifyListeners();
  }

  clearAdditionalServices() {
    selectedAdditionalServices = [];
    notifyListeners();
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

  selectAllServices(List services) {
    selectedServices = services;
    notifyListeners();
  }

  clearServices() {
    selectedServices = [];
    notifyListeners();
  }

  double radiusMiles = 100;
  changeRadius(double newRadius) {
    radiusMiles = newRadius;
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

  List<UserModel> filterProviders(List<UserModel> providers, double userLat,
      double userLong, double radiusKm) {
    return providers
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

  final String cloudFunctionUrl =
      'https://us-central1-vehype-386313.cloudfunctions.net/deleteUserAccount';

  deleteUserAccount(String uid) async {
    try {
      // Construct the URL with the UID as a query parameter
      final uri = Uri.parse('$cloudFunctionUrl?uid=$uid');

      // Make the GET request to your Cloud Function
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('User account deleted successfully: ${response.body}');
      } else {
        print('Failed to delete user account: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while deleting user account: $e');
    }
  }

  bool isAdmin = false;

  Future<void> handleUserAccountActions(
      UserModel userModel, UserController userController) async {
    // Determine if the user is a 'seeker' or 'provider'
    bool isSeeker = userModel.accountType == 'seeker';

    // Fetch the relevant offers
    QuerySnapshot<Map<String, dynamic>> offersSnap = await FirebaseFirestore
        .instance
        .collection(isSeeker ? 'offers' : 'offersReceived')
        .where(isSeeker ? 'ownerId' : 'offerBy', isEqualTo: userModel.userId)
        .get();

    for (var element in offersSnap.docs) {
      if (isSeeker) {
        await _handleSeekerOffers(
            userModel, OffersModel.fromJson(element), userController);
      } else {
        await _handleProviderOffers(
            userModel, OffersReceivedModel.fromJson(element));
      }
    }
  }

  Future<void> _handleSeekerOffers(UserModel userModel, OffersModel offersModel,
      UserController userController) async {
    if (offersModel.status == 'active') {
      await _rejectAllOffers(offersModel, userController);
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offersModel.offerId)
          .update({
        'status': 'inactive',
        'offersReceived': [],
        'checkByList': [],
      });
    } else {
      await _cancelSeekerOffer(userModel, offersModel);
    }
  }

  Future<void> _handleProviderOffers(
      UserModel userModel, OffersReceivedModel offersReceivedModel) async {
    DocumentSnapshot<Map<String, dynamic>> requestSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .get();
    OffersModel offersModel = OffersModel.fromJson(requestSnap);
    if (offersModel.status == 'inProgress') {
      OffersController().cancelOfferByService(offersReceivedModel, offersModel,
          'The request was automatically canceled.');
      OffersController().updateNotificationForOffers(
          offerId: offersModel.offerId,
          senderId: userModel.userId,
          userId: offersModel.ownerId,
          isAdd: true,
          offersReceived: offersReceivedModel.id,
          checkByList: offersModel.checkByList,
          notificationTitle: '${userModel.name} has canceled their offer.',
          notificationSubtitle:
              '${userModel.name} has canceled their offer. Rate and review their service.');
      DocumentSnapshot<Map<String, dynamic>> ownerSnap = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(offersReceivedModel.ownerId)
          .get();

      NotificationController().sendNotification(
          userIds: [UserModel.fromJson(ownerSnap).userId],
          offerId: offersModel.offerId,
          requestId: offersReceivedModel.id,
          title: 'Offer Cancellation Alert',
          subtitle:
              '${userModel.name} has canceled their offer. Rate and review their service.');

      ChatModel? chatModel = await ChatController()
          .getChat(userModel.userId, offersModel.ownerId, offersModel.offerId);
      if (chatModel != null) {
        ChatController().updateChatToClose(
            chatModel.id, '${userModel.name} has canceled their offer.');
      }
    } else if (offersModel.status == 'active') {
      await FirebaseFirestore.instance
          .collection('offersReceived')
          .doc(offersReceivedModel.id)
          .update({
        'status': 'Cancelled',
        'cancelBy': 'provider',
        'checkByList': [],
      });
      ChatModel? chatModel = await ChatController()
          .getChat(userModel.userId, offersModel.ownerId, offersModel.offerId);
      if (chatModel != null) {
        ChatController().updateChatToClose(
            chatModel.id, '${userModel.name} has withdrawn their offer.');
      }
      // OffersController().updateNotificationForOffers(
      //     offerId: offersModel.offerId,
      //     senderId: userModel.userId,
      //     userId: offersModel.ownerId,
      //     isAdd: true,
      //     offersReceived: offersReceivedModel.id,
      //     checkByList: offersModel.checkByList,
      //     notificationTitle: '${userModel.name} has canceled their offer.',
      //     notificationSubtitle:
      //         '${userModel.name} has canceled their offer. Rate and review their service.');
      // DocumentSnapshot<Map<String, dynamic>> ownerSnap = await FirebaseFirestore
      //     .instance
      //     .collection('users')
      //     .doc(offersReceivedModel.ownerId)
      //     .get();

      // NotificationController().sendNotification(
      //     userIds: [UserModel.fromJson(ownerSnap).userId],
      //     offerId: offersModel.offerId,
      //     requestId: offersReceivedModel.id,
      //     title: 'Offer Cancellation Alert',
      //     subtitle:
      //         '${userModel.name} has canceled their offer. Rate and review their service.');
    }
  }

  Future<void> _rejectAllOffers(
      OffersModel offersModel, UserController userController) async {
    QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .where('offerId', isEqualTo: offersModel.offerId)
            .get();

    for (var element in offersReceivedSnap.docs) {
      OffersReceivedModel offersReceivedModel =
          OffersReceivedModel.fromJson(element);
      if (offersReceivedModel.status == 'Pending') {
        await OwnerOffersController()
            .ignoreOffer(offersModel, offersReceivedModel);
        OffersController().updateNotificationForOffers(
            offerId: offersModel.offerId,
            userId: offersReceivedModel.offerBy,
            senderId: userController.userModel!.userId,
            checkByList: offersModel.checkByList,
            isAdd: true,
            offersReceived: offersReceivedModel.id,
            notificationTitle:
                'The offer was declined by ${userController.userModel!.name}',
            notificationSubtitle:
                'The offer was declined by ${userController.userModel!.name}');
        DocumentSnapshot<Map<String, dynamic>> ownerSnap =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(offersReceivedModel.ownerId)
                .get();
        NotificationController().sendNotification(
            userIds: [UserModel.fromJson(ownerSnap).userId],
            offerId: offersModel.offerId,
            requestId: offersReceivedModel.id,
            title:
                'The offer was declined by ${userController.userModel!.name}',
            subtitle: '');

        ChatModel? chatModel = await ChatController().getChat(
            userController.userModel!.userId,
            offersModel.ownerId,
            offersModel.offerId);
        if (chatModel != null) {
          ChatController().updateChatToClose(chatModel.id,
              'The offer was declined by ${userController.userModel!.name}.');
        }
      }
    }
  }

  Future<void> _cancelSeekerOffer(
      UserModel userModel, OffersModel offersModel) async {
    QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .where('offerId', isEqualTo: offersModel.offerId)
            .get();

    for (var element in offersReceivedSnap.docs) {
      OffersReceivedModel offersReceivedModel =
          OffersReceivedModel.fromJson(element);

      OffersController().cancelOfferByOwner(
          offersReceivedModel, 'The request was automatically canceled.');
      DocumentSnapshot<Map<String, dynamic>> ownerSnap = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(offersReceivedModel.ownerId)
          .get();

      NotificationController().sendNotification(
          userIds: [UserModel.fromJson(ownerSnap).userId],
          offerId: offersModel.offerId,
          requestId: offersReceivedModel.id,
          title: 'Offer Cancelled',
          subtitle:
              '${userModel.name} has cancelled the request. Click here to review.');

      QuerySnapshot<Map<String, dynamic>> chatsSnap = await FirebaseFirestore
          .instance
          .collection('chats')
          .where('offerId', isEqualTo: offersModel.offerId)
          .get();

      for (var chat in chatsSnap.docs) {
        await ChatController()
            .updateChatToClose(chat.id, 'The request has been deleted.');
      }

      OffersController().updateNotificationForOffers(
          offerId: offersModel.offerId,
          userId: offersReceivedModel.offerBy,
          senderId: userModel.userId,
          isAdd: true,
          offersReceived: offersReceivedModel.id,
          checkByList: offersModel.checkByList,
          notificationTitle: '${userModel.name} has cancelled the request.',
          notificationSubtitle:
              '${userModel.name} has cancelled the request. Tap to review.');
    }
  }

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

    await FirebaseFirestore.instance.collection('reports').add({
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'status': 'Active',
      'reportBy': currentUserId,
      'reportTo': secondUserId,
      'reason': reason,
    });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  }

  unblockUser(String currentUserId, String secondUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(secondUserId)
        .update({
      'blockedBy': FieldValue.arrayRemove([currentUserId])
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayRemove([secondUserId])
    });
  }

  late Uint8List favMarkar;
  late Uint8List userMarker;

  getCustomMarkers() async {
    favMarkar = await getBytesFromAsset('assets/fav.png', 135);
    userMarker = await getBytesFromAsset('assets/user.png', 135);
    notifyListeners();
  }

  Future<Uint8List> getBytesFromAsset(String path, int size) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: size);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

class AppModel {
  final String versionNumber;

  AppModel({required this.versionNumber});
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(versionNumber: json['version'] ?? '3.0.3.67');
  }
}
