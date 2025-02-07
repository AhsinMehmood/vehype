// ignore_for_file: sort_child_properties_last

import 'dart:io';
/**
 * 
 * 
 * کبھی کبھی تمہاری اس قدر ضرورت محسوس ہوتی ہے ، کہ
دل چاہتا ہے 
دنیا کی ہر عیش و عشرت ٹھکڑا دوں ، 
اور صرف تمہاری پہلو میں آ کے خود کو فنا کر لوں ! 
 */
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Pages/vehicle_based_request_history.dart';
import '../Controllers/chat_controller.dart';
import '../Controllers/offers_provider.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';
import '../Pages/chat_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/my_garage.dart';
import '../Pages/orders_history_provider.dart';
import '../Pages/profile_page.dart';
import '../Pages/repair_page.dart';
import '../Pages/second_user_profile.dart';
import '../const.dart';

import '../Controllers/garage_controller.dart';
import '../Controllers/mix_panel_controller.dart';
import '../Controllers/notification_controller.dart';
import '../Models/offers_model.dart';
import '../Widgets/loading_dialog.dart';
import '../google_maps_place_picker.dart';
import 'setup_business_provider.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final List<Widget> _body = [
    RepairPage(),
    MyGarage(),
    ExplorePage(),
    ChatPage(),
    ProfilePage(),
  ];
  final List<Widget> _body2 = [
    OrdersHistoryProvider(),
    // VehicleBasedRequestHistory(),
    ChatPage(),
    ProfilePage(),
  ];
  PackageInfo _packageInfo = PackageInfo();

  @override
  void initState() {
    super.initState();

    OneSignal.Notifications.addForegroundWillDisplayListener(
        (OSNotificationWillDisplayEvent message) {
      if (message.notification.additionalData != null) {
        if (message.notification.additionalData!['type'] == 'chat') {
          // FlutterAppBadger.updateBadgeCount(1);
          // print(event.notification.additionalData);
          mixPanelController
              .trackEvent(eventName: 'Message Delivered', data: {});

          ChatController().updateMessage(
              message.notification.additionalData!['chatId'],
              message.notification.additionalData!['messageId'],
              1);
        } else {}
      }
    });

    OneSignal.Notifications.addClickListener(
        (OSNotificationClickEvent listener) {
      if (listener.notification.additionalData != null) {
        if (listener.notification.additionalData!['type'] == 'chat') {
          // FlutterAppBadger.updateBadgeCount(1);
          // print(event.notification.additionalData);
          ChatController().updateMessage(
              listener.notification.additionalData!['chatId'],
              listener.notification.additionalData!['messageId'],
              1);
          mixPanelController.trackEvent(
              eventName: 'Tapped on Message Notification', data: {});

          NotificationController()
              .navigateChat(listener.notification.additionalData!);
        } else if (listener.notification.additionalData!['type'] ==
            'new_provider') {
          mixPanelController.trackEvent(
              eventName: 'Tapped on New Provider announcement notification',
              data: {});

          Get.to(() => SecondUserProfile(
              userId: listener.notification.additionalData!['providerId']));
        } else {
          mixPanelController.trackEvent(
              eventName: 'Tapped on service notification', data: {});

          NotificationController()
              .navigateOwner(listener.notification.additionalData!);
        }
      }
    });

    Future.delayed(const Duration(seconds: 0)).then((s) {
      getNotificationSetting();
    });
  }

  getNotificationSetting() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    _packageInfo = await PackageManager.getPackageInfo();

    // VersionInfo? _versionInfo = await UpgradeVersion.getiOSStoreVersion(
    //     packageInfo: _packageInfo, regionCode: "US");
    DocumentSnapshot<Map<String, dynamic>> updateInfo = await FirebaseFirestore
        .instance
        .collection('versionInfo')
        .doc('appVersion')
        .get();
    print(_packageInfo.buildNumber);
    mixPanelController.trackEvent(eventName: 'Checked for update', data: {});

    if (int.parse(_packageInfo.buildNumber) < updateInfo['buildNumber']) {
      showModalBottomSheet(
          context: context,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          // enableDrag: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          isDismissible: false,
          enableDrag: false,
          builder: (context) {
            return UpdateSheet(
              userController: userController,
              manager: null,
            );
          });
    }
    // if (Platform.isAndroid) {
    //   InAppUpdateManager manager = InAppUpdateManager();
    //   AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
    //   if (appUpdateInfo == null) return;
    //   if (appUpdateInfo.updateAvailability ==
    //       UpdateAvailability.developerTriggeredUpdateInProgress) {
    //     //If an in-app update is already running, resume the update.
    //     String? message =
    //         await manager.startAnUpdate(type: AppUpdateType.immediate);
    //   } else if (appUpdateInfo.updateAvailability ==
    //       UpdateAvailability.updateAvailable) {
    //     showModalBottomSheet(
    //         context: context,
    //         backgroundColor:
    //             userController.isDark ? primaryColor : Colors.white,
    //         // enableDrag: false,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(6),
    //             topRight: Radius.circular(6),
    //           ),
    //         ),
    //         isDismissible: false,
    //         enableDrag: false,
    //         builder: (context) {
    //           return UpdateSheet(
    //             userController: userController,
    //             manager: manager,
    //           );
    //         });
    //   }
    // } else {
    //   _packageInfo = await PackageManager.getPackageInfo();

    //   VersionInfo? _versionInfo = await UpgradeVersion.getiOSStoreVersion(
    //       packageInfo: _packageInfo, regionCode: "US");

    //   if (double.tryParse(_versionInfo.localVersion)! <
    //       double.tryParse(_versionInfo.storeVersion)!) {
    // showModalBottomSheet(
    //     context: context,
    //     backgroundColor:
    //         userController.isDark ? primaryColor : Colors.white,
    //     // enableDrag: false,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(
    //         topLeft: Radius.circular(6),
    //         topRight: Radius.circular(6),
    //       ),
    //     ),
    //     isDismissible: false,
    //     enableDrag: false,
    //     builder: (context) {
    //       return UpdateSheet(
    //         userController: userController,
    //         manager: null,
    //       );
    //     });
    // }
    // }

    // else {
    userController.pushTokenUpdate(userController.userModel!.userId);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    if (userController.userModel == null) {
      return Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final UserModel userModel = userController.userModel!;
    // print(userModel.pushToken);
    // AppController controller = Get.put(AppController());
    return Scaffold(
        body: IndexedStack(
          index: userModel.accountType == 'seeker'
              ? userController.tabIndex
              : userController.tabIndex,
          children: userModel.accountType == 'seeker' ? _body : _body2,
        ),
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        bottomNavigationBar: userModel.accountType == 'seeker'
            ? bottomNavigationBarSeeker()
            : bottomNavigationBarProvider());
  }

  BottomNavigationBar bottomNavigationBarProvider() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    return BottomNavigationBar(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      selectedItemColor: userController.isDark ? Colors.white : Colors.black,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      // unselectedItemColor: C,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) async {
        userController.changeTabIndex(index);
        mixPanelController
            .trackEvent(eventName: 'Tapped on Tab ${index + 1}', data: {});
      },
      items: providerTabs(),

      type: BottomNavigationBarType.fixed,
    );
  }

  BottomNavigationBar bottomNavigationBarSeeker() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    return BottomNavigationBar(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      selectedItemColor: userController.isDark ? Colors.white : Colors.black,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) async {
        userController.changeTabIndex(index);
        mixPanelController
            .trackEvent(eventName: 'Tapped on Tab ${index + 1}', data: {});
      },
      items: seekerTabs(),
      type: BottomNavigationBarType.fixed,
    );
  }

  List<BottomNavigationBarItem> providerTabs() {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    List<OffersModel> filteredOffers = offersProvider.offers
        .where((offer) => !offer.offersReceived.contains(userModel.userId))
        .where((offer) => !offer.ignoredBy.contains(userModel.userId))
        .where((offer) => !userModel.blockedUsers.contains(offer.ownerId))
        .where((offer) => userModel.services.contains(offer.issue))
        .where((offer) => userModel.vehicleTypes.contains(offer.vehicleType))
        .toList();

    List<OffersModel> newOffers = userModel.lat == 0.0
        ? filteredOffers
        : userController.filterOffers(
            filteredOffers, userModel.lat, userModel.long, 50);
    List<OffersModel> notificationToCheckOffersNewOffers = newOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    // print(
    //     '${offersProvider.offers.where((offer) => offer.checkByList.any((check) => check.checkById == userModel.userId)).toList().first.status} ');
    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(
                Icons.online_prediction_rounded,
                size: 24,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(0),
              ),

              // if (offersProvider.offers.every(
              //         (offer) => offer.checkBy.contains(userModel.userId)) ||
              //     offersProvider.offersReceived.every(
              //         (offer) => offer.checkBy.contains(userModel.userId)))
              Positioned(
                top: 0,
                right: 0,
                child: Visibility(
                  visible: notificationToCheckOffersNewOffers.isNotEmpty ||
                      offersProvider.offersReceived
                          .where((offer) => offer.checkByList.any(
                              (check) => check.checkById == userModel.userId))
                          .toList()
                          .isNotEmpty,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        (notificationToCheckOffersNewOffers.length +
                                offersProvider.offersReceived
                                    .where((offer) => offer.checkByList.any(
                                        (check) =>
                                            check.checkById ==
                                            userModel.userId))
                                    .toList()
                                    .length)
                            .toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          label: 'Requests'),

      // if (userModel.accountType != 'seeker')
      // BottomNavigationBarItem(
      //     icon: Icon(
      //       Icons.business_sharp,
      //       size: 24,
      //       // ignore: deprecated_member_use
      //       color: labelAndIconColorDark(1),
      //     ),
      //     label: 'Sales'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/messages.svg',
                height: 24,
                width: 24,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(1),
              ),
              StreamBuilder<List<ChatModel>>(
                  stream:
                      ChatController().chatsStream(userModel.userId, context),
                  builder: (context, AsyncSnapshot<List<ChatModel>> snapshot) {
                    if (snapshot.hasData) {
                      List<ChatModel> chats = snapshot.data ?? [];

                      List<ChatModel> unreadMessages =
                          getUnread(userModel, chats);
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Visibility(
                          visible: unreadMessages.isNotEmpty,
                          child: Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: unreadMessages.isNotEmpty
                                  ? Colors.red
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                unreadMessages.length >= 100
                                    ? '99+'
                                    : unreadMessages.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
            ],
          ),
          label: 'Messages'),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/profile.png',
          height: 24,
          width: 24,
          // ignore: deprecated_member_use
          color: labelAndIconColorDark(2),
        ),
        label: 'Profile',
      ),
    ];
  }

  List<ChatModel> getUnread(UserModel userModel, List<ChatModel> chats) {
    return chats
        .where((element) =>
            DateTime.parse(element.lastMessageAt)
                .toLocal()
                .difference(DateTime.parse(element.lastOpen[userModel.userId])
                    .toLocal())
                .inSeconds >
            0)
        .toList();
  }

  List<BottomNavigationBarItem> seekerTabs() {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    UserModel userModel = userController.userModel!;

    final List<OffersModel> ownerOffersNeedsToCheck = offersProvider.ownerOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();

    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
        icon: Stack(
          children: [
            Image.asset(
              'assets/repair.png',
              height: 24,
              width: 24,
              // ignore: deprecated_member_use
              color: labelAndIconColorDark(0),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Visibility(
                visible: ownerOffersNeedsToCheck.isNotEmpty,
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      ownerOffersNeedsToCheck.length >= 100
                          ? '99+'
                          : ownerOffersNeedsToCheck.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        label: 'Repair',
      ),

      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/garage.png',
            height: 24,
            width: 24,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(1),
          ),
          label: 'My Garage'),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.location_on_outlined,
            size: 24,
            // width: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(2),
          ),
          label: 'Explore'),
      // if (userModel.accountType != 'seeker')
      //   BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.notifications_none,
      //         size: 28,
      //         // ignore: deprecated_member_use
      //         color: labelAndIconColorDark(1),
      //       ),
      //       label: 'Notifications'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/messages.svg',
                height: 24,
                width: 24,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(3),
              ),
              StreamBuilder<List<ChatModel>>(
                  stream:
                      ChatController().chatsStream(userModel.userId, context),
                  builder: (context, AsyncSnapshot<List<ChatModel>> snapshot) {
                    if (snapshot.hasData) {
                      List<ChatModel> chats = snapshot.data ?? [];

                      List<ChatModel> unreadMessages =
                          getUnread(userModel, chats);
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Visibility(
                          visible: unreadMessages.isNotEmpty,
                          child: Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: unreadMessages.isNotEmpty
                                  ? Colors.red
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                unreadMessages.length >= 100
                                    ? '99+'
                                    : unreadMessages.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
            ],
          ),
          label: 'Messages'),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/profile.png',
          height: 24,
          width: 24,
          // ignore: deprecated_member_use
          color: labelAndIconColorDark(4),
        ),
        label: 'Profile',
      ),
    ];
  }

  Color labelAndIconColorDark(int index) {
    final UserController userController = Provider.of<UserController>(context);

    int tabIndex = userController.tabIndex;
    if (userController.isDark) {
      Color color = tabIndex == index ? Colors.white : Colors.white54;
      return color;
    } else {
      Color color = tabIndex == index ? Colors.black : Colors.black54;
      return color;
    }
  }
  // : const SizedBox.shrink();
}

String notificationsCount = '0';
final mixPanelController = Get.find<MixPanelController>();

class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({
    super.key,
    required this.userController,
    this.isProvider = false,
  });

  final UserController userController;
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: 280,
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Your location allows VEHYPE to provide accurate maps and find services near you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Text(
            //   userController.userModel!.accountType == 'Provider'
            //       ? 'Grant access to connect with nearby customers.'
            //       : 'Grant access to find service providers near you.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: userController.isDark ? Colors.white : primaryColor,
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                bool serviceEnabled;
                LocationPermission permission =
                    await Geolocator.requestPermission();

                serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  Get.showSnackbar(GetSnackBar(
                    message: 'Location is disabled. Tap to open Settings.',
                    onTap: (d) {
                      Geolocator.openLocationSettings();
                    },
                    duration: Duration(seconds: 3),
                  ));
                  mixPanelController
                      .trackEvent(eventName: 'Location is disabled', data: {});
                } else {
                  // permission = await Geolocator.checkPermission();
                  // permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever ||
                      permission == LocationPermission.unableToDetermine) {
                    Get.showSnackbar(GetSnackBar(
                      message: 'Location is disabled. Tap to open Settings.',
                      onTap: (d) {
                        Geolocator.openAppSettings();
                      },
                      duration: Duration(seconds: 3),
                    ));
                    mixPanelController
                        .trackEvent(eventName: 'Location is denied', data: {});
                  } else {
                    Get.dialog(const LoadingDialog(),
                        barrierDismissible: false);
                    mixPanelController
                        .trackEvent(eventName: 'Asked for location', data: {});
                    Position position = await Geolocator.getCurrentPosition();
                    if (isProvider) {
                      Get.close(1);
                      Get.offAll(
                        () => PlacePicker(
                          apiKey: 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                          selectText: 'Pick This Place',
                          onTapBack: null,
                          onPlacePicked: (result) async {
                            Get.dialog(LoadingDialog(),
                                barrierDismissible: false);
                            LatLng latLng = LatLng(
                                result.geometry!.location.lat,
                                result.geometry!.location.lng);
                            // if(userController.userModel != null && userController.userModel!)

                            sendNotification(latLng);

                            // userController.changeLocation(latLng);
                            // setState(() {});

                            final GeoFirePoint geoFirePoint = GeoFirePoint(
                                GeoPoint(latLng.latitude, latLng.longitude));

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userController.userModel!.userId)
                                .update({
                              'lat': latLng.latitude,
                              'geo': geoFirePoint.data,
                              'long': latLng.longitude,
                            });

                            Get.close(1);
                            if (userController.userModel!.isBusinessSetup) {
                              Get.offAll(() => TabsPage());
                            } else {
                              Get.offAll(() => SetupBusinessProvider());
                            }
                          },
                          initialPosition:
                              LatLng(position.latitude, position.longitude),
                          // useCurrentLocation: true,
                          selectInitialPosition: true,
                          resizeToAvoidBottomInset: false,
                        ),
                      );
                    } else {
                      final GeoFirePoint geoFirePoint = GeoFirePoint(
                          GeoPoint(position.latitude, position.longitude));

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userController.userModel!.userId)
                          .update({
                        'lat': position.latitude,
                        'long': position.longitude,
                        'geo': geoFirePoint.data,
                      });
                      mixPanelController.trackEvent(
                          eventName: 'Location is updated', data: {});
                      // userController.changeLocation(
                      //     LatLng(position.latitude, position.longitude));
                      // userController
                      //     .pushTokenUpdate(userController.userModel!.userId);
                      await Future.delayed(Duration(seconds: 1));
                      Get.close(2);
                      mixPanelController
                          .trackEvent(eventName: 'Opended tabs page', data: {});
                      Get.offAll(() => const TabsPage());
                    }

                    // Get.close(1);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  sendNotification(LatLng latLng) async {
    List<UserModel> providers = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('accountType', isEqualTo: 'seeker')
            // .where('services', arrayContains: issue)
            // .where('status', isEqualTo: 'active')
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      providers.add(UserModel.fromJson(element));
    }
    List<UserModel> filterProviders = userController.filterProviders(providers,
        latLng.latitude, latLng.longitude, userController.radiusMiles);
    List<String> userIds = [];
    for (var element in filterProviders) {
      userIds.add(element.userId);
    }

    NotificationController().sendNotificationNewProvider(
        userIds: userIds,
        providerId: userController.userModel!.userId,
        requestId: '',
        title: 'New Service 👨🏻‍🔧',
        subtitle:
            'Hi, new service just registered in your area. Check it out!!!');
  }
}

class UpdateSheet extends StatelessWidget {
  const UpdateSheet({
    super.key,
    required this.userController,
    required this.manager,
  });

  final UserController userController;
  final InAppUpdateManager? manager;

  @override
  Widget build(BuildContext context) {
    mixPanelController.trackEvent(eventName: 'Asked to update', data: {});
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          color: userController.isDark ? primaryColor : Colors.white,
        ),
        height: 280,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Update Alert!',
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'A new update is available on ${Platform.isAndroid ? 'Playstore' : 'Appstore'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                PackageInfo _packageInfo = PackageInfo();
                mixPanelController
                    .trackEvent(eventName: 'Tapped on update button', data: {});

                // Get.close(1);
                if (Platform.isAndroid) {
                  InAppUpdateManager manager = InAppUpdateManager();
                  AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
                  if (appUpdateInfo == null) return;
                  if (appUpdateInfo.updateAvailability ==
                      UpdateAvailability.developerTriggeredUpdateInProgress) {
                    //If an in-app update is already running, resume the update.
                    String? message = await manager.startAnUpdate(
                        type: AppUpdateType.immediate);
                    debugPrint(message ?? '');
                  } else if (appUpdateInfo.updateAvailability ==
                      UpdateAvailability.updateAvailable) {
                    ///Update available
                    if (appUpdateInfo.immediateAllowed) {
                      String? message = await manager.startAnUpdate(
                          type: AppUpdateType.immediate);
                      debugPrint(message ?? '');
                    } else if (appUpdateInfo.flexibleAllowed) {
                      String? message = await manager.startAnUpdate(
                          type: AppUpdateType.flexible);
                      debugPrint(message ?? '');
                    } else {
                      launchUrl(Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.nomadllc.vehype'));
                    }
                  }
                } else {
                  _packageInfo = await PackageManager.getPackageInfo();

                  VersionInfo? _versionInfo =
                      await UpgradeVersion.getiOSStoreVersion(
                          packageInfo: _packageInfo, regionCode: "US");
                  debugPrint(_versionInfo.toJson().toString());
                  launchUrl(Uri.parse(_versionInfo.appStoreLink));
                  // Get.close(1);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.8, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Update Now',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    mixPanelController
        .trackEvent(eventName: 'Asked for notification permission', data: {});

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: 300,
      width: Get.width,
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Get Important Updates',
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'We will notify you about updates to Requests, new Offers, and Messages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                await OneSignal.Notifications.requestPermission(true);
                // await OneSignal.Notifications.
                mixPanelController
                    .trackEvent(eventName: 'Notification Allowed', data: {});

                OneSignal.login(userController.userModel!.userId);
                Get.close(1);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.8, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Yes, notify me',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                mixPanelController
                    .trackEvent(eventName: 'Maybe later', data: {});

                Get.close(1);
              },
              child: Text(
                'Maybe later',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: userController.isDark
                      ? Colors.white.withOpacity(0.7)
                      : primaryColor,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
