// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/app_controller.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/chat_page.dart';
import 'package:vehype/Pages/explore_page.dart';
import 'package:vehype/Pages/my_garage.dart';
import 'package:vehype/Pages/orders_history_provider.dart';
import 'package:vehype/Pages/profile_page.dart';
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/const.dart';

import '../Models/offers_model.dart';
import '../Widgets/loading_dialog.dart';
import 'inactive_offers_seeker.dart';
import 'offers_received_details.dart';
import 'offers_tab_page.dart';
import 'received_offers_seeker.dart';
import 'requests_received_provider_details.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  List<Widget> _body = [
    RepairPage(),
    MyGarage(),
    ExplorePage(),
    ChatPage(),
    ProfilePage(),
  ];
  List<Widget> _body2 = [
    OrdersHistoryProvider(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    getNotificationSetting();
    OneSignal.Notifications.addClickListener(
        (OSNotificationClickEvent onClick) {
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      final UserModel userModel = userController.userModel!;
      Map<String, dynamic>? notficationData =
          onClick.notification.additionalData;
      if (notficationData != null) {
        if (userModel.accountType.toLowerCase() == 'seeker') {
          if (notficationData['type'] == 'request') {
            ownerNotificationOnTapRequest(notficationData);
          } else if (notficationData['type'] == 'offer') {
            ownerNotificationOnTapOffer(notficationData);
          }
        } else {
          if (notficationData['type'] == 'request') {
            providerNotificationOnTapRequest(notficationData);
          } else if (notficationData['type'] == 'offer') {
            providerNotificationOnTapOffer(notficationData);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // OneSignal.Notifications.
  }

  providerNotificationOnTapRequest(Map<String, dynamic> notficationData) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    DocumentSnapshot<Map<String, dynamic>> requestSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(notficationData['objectId'])
        .get();
    OffersModel offersModel = OffersModel.fromJson(requestSnap);
    Get.close(1);
    UserController().changeNotiOffers(
        0, false, userModel.userId, offersModel.offerId, userModel.accountType);
    if (offersModel.status == 'active' &&
        !offersModel.ignoredBy.contains(userModel.userId) &&
        !offersModel.offersReceived.contains(userModel.userId)) {
      Get.to(() => OfferReceivedDetails(
            offersModel: offersModel,
          ));
    } else {
      toastification.show(
        title: Text('The request has been moved to another page'),
        style: ToastificationStyle.minimal,
        autoCloseDuration: Duration(
          seconds: 3,
        ),
        context: context,
      );
    }
  }

  providerNotificationOnTapOffer(Map<String, dynamic> notficationData) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    DocumentSnapshot<Map<String, dynamic>> offersReceivedSnap =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(notficationData['objectId'])
            .get();
    OffersReceivedModel offersReceivedModel =
        OffersReceivedModel.fromJson(offersReceivedSnap);

    DocumentSnapshot<Map<String, dynamic>> requestSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .get();
    OffersModel offersModel = OffersModel.fromJson(requestSnap);

    int id = offersReceivedModel.status == 'Pending'
        ? 1
        : offersReceivedModel.status == 'inProgress'
            ? 2
            : offersReceivedModel.status == 'Completed'
                ? 3
                : 4;
    UserController().changeNotiOffers(id, false, userModel.userId,
        offersModel.offerId, userModel.accountType);
    Get.close(1);
    Get.to(() => RequestsReceivedProviderDetails(
          offersModel: offersModel,
          offersReceivedModel: offersReceivedModel,
        ));
  }

  ownerNotificationOnTapOffer(Map<String, dynamic> notficationData) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    Get.dialog(LoadingDialog(), barrierDismissible: false);

    DocumentSnapshot<Map<String, dynamic>> offersReceivedSnap =
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(notficationData['objectId'])
            .get();
    OffersReceivedModel offersReceivedModel =
        OffersReceivedModel.fromJson(offersReceivedSnap);

    DocumentSnapshot<Map<String, dynamic>> requestSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .get();
    OffersModel offersModel = OffersModel.fromJson(requestSnap);

    UserController().changeNotiOffers(
        6,
        false,
        userController.userModel!.userId,
        offersModel.offerId,
        userController.userModel!.accountType);
    Get.close(1);
    if (offersReceivedModel.status == 'Pending') {
      UserController().changeNotiOffers(
          5,
          false,
          userController.userModel!.userId,
          offersModel.offerId,
          userController.userModel!.accountType);
      Get.to(() => ReceivedOffersSeeker(
            offersModel: offersModel,
            offersReceivedModel: offersReceivedModel,
          ));
    } else {
      Get.to(() => InActiveOffersSeeker(
            offersModel: offersModel,
            isFromNoti: true,
            offersReceivedModel: offersReceivedModel,
            tittle: offersReceivedModel.status == 'ignore'
                ? 'Ignored'
                : offersReceivedModel.status,
          ));
    }
  }

  ownerNotificationOnTapRequest(Map<String, dynamic> notficationData) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    DocumentSnapshot<Map<String, dynamic>> requestSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(notficationData['objectId'])
        .get();
    OffersModel offersModel = OffersModel.fromJson(requestSnap);
    Get.close(1);

    if (offersModel.status == 'active') {
      UserController().changeNotiOffers(
          5,
          false,
          userController.userModel!.userId,
          offersModel.offerId,
          userController.userModel!.accountType);
      Get.to(() => ReceivedOffersSeeker(
            offersModel: offersModel,
          ));
    } else {
      toastification.show(
        title: Text('The request has been moved to another page'),
        style: ToastificationStyle.minimal,
        autoCloseDuration: Duration(
          seconds: 3,
        ),
        context: context,
      );
    }
  }

  getNotificationSetting() async {
    bool isNotAllowed = OneSignal.Notifications.permission;
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    bool serviceEnabled;
    LocationPermission permission;
    DocumentSnapshot<Map<String, dynamic>> updateSnap = await FirebaseFirestore
        .instance
        .collection('updates')
        .doc('update')
        .get();
    if (updateSnap.exists) {
      if (updateSnap.data()!['newVersion'] != currentVersion) {
        await Future.delayed(const Duration(seconds: 1));
        showModalBottomSheet(
            context: context,
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
            // enableDrag: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            isDismissible: false,
            builder: (context) {
              return UpdateSheet(
                userController: userController,
              );
            });
        return;
      } else {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        permission = await Geolocator.checkPermission();
        if (isNotAllowed == false) {
          Future.delayed(const Duration(seconds: 3)).then((s) {
            Get.bottomSheet(
              NotificationSheet(userController: userController),
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            );
          });
        } else if (serviceEnabled == false ||
            permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          Future.delayed(const Duration(seconds: 1)).then((s) {
            Get.bottomSheet(
              LocationPermissionSheet(userController: userController),
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              isDismissible: false,
              // enableDrag: false,
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;

    // AppController controller = Get.put(AppController());
    return Scaffold(
        body: IndexedStack(
          index: userModel.accountType == 'seeker'
              ? userController.tabIndex
              : userController.tabIndex,
          children: userModel.accountType == 'seeker' ? _body : _body2,
        ),
        backgroundColor: Colors.white,
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
      selectedFontSize: 13,
      unselectedFontSize: 13,
      // unselectedItemColor: C,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 13,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) async {
        // print(userModel.userId);
        userController.changeTabIndex(index);

        // QuerySnapshot<Map<String, dynamic>> snapshot =
        //     await FirebaseFirestore.instance.collection('users').get();
        // List<UserModel> users = [];
        // for (var element in snapshot.docs) {
        //   users.add(UserModel.fromJson(element));
        // }

        // for (var element in users) {
        //   if (element.offerIdsToCheck.isNotEmpty) {
        //     await FirebaseFirestore.instance
        //         .collection('users')
        //         .doc(element.userId)
        //         .update({
        //       'offerIdsToCheck': [],
        //       'isActiveNew': false,
        //       'isActivePending': false,
        //       'isActiveInProgress': false,
        //       'isActiveCompleted': false,
        //       'isActiveCancelled': false,
        //       'isActive': false,
        //       'isHistoryActive': false,
        //     });
        //   }
        // }
        // print(userModel.userId);

        // FlutterAppBadger.updateBadgeCount(10);
        // OneSignal.login(userModel.userId);
        // sendNotification(userModel.userId, 'Ahsinnn', 'Has', 'contents',
        //     'chatId', 'type', 'messageId');
        // userController.checkIsAdmin(userModel.email);
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
      selectedFontSize: 13,
      unselectedFontSize: 13,
      // unselectedItemColor: C,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 13,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) async {
        print(userModel.userId);
        print(userModel.offerIdsToCheck);

        // userController.checkIsAdmin(userModel.email);
        userController.changeTabIndex(index);
        // FlutterAppBadger.updateBadgeCount(10);
        // OneSignal.login(userModel.userId);
        // sendNotification(userModel.userId, 'Ahsinnn', 'Has', 'contents',
        //     'chatId', 'type', 'messageId');
        print(userModel.userId);
      },
      items: seekerTabs(),

      type: BottomNavigationBarType.fixed,
    );
  }

  List<BottomNavigationBarItem> providerTabs() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(
                Icons.online_prediction_rounded,
                size: 28,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(0),
              ),
              userModel.offerIdsToCheck.isNotEmpty
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Visibility(
                        visible: userModel.offerIdsToCheck.isNotEmpty,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            color: userModel.offerIdsToCheck.isNotEmpty
                                ? Colors.red
                                : Colors.white,
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              userModel.offerIdsToCheck.length >= 100
                                  ? '99+'
                                  : userModel.offerIdsToCheck.length.toString(),
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
                  : const SizedBox.shrink(),
            ],
          ),
          label: 'Requests'),

      // if (userModel.accountType != 'seeker')
      // BottomNavigationBarItem(
      //     icon: Icon(
      //       Icons.notifications_none,
      //       size: 28,
      //       // ignore: deprecated_member_use
      //       color: labelAndIconColorDark(1),
      //     ),
      //     label: 'Notifications'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/messages.svg',
                height: 28,
                width: 28,
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
                            height: 18,
                            width: 18,
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
          height: 28,
          width: 28,
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
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    bool haveUnread = false;

    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              Image.asset(
                'assets/repair.png',
                height: 28,
                width: 28,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(0),
              ),
              userModel.offerIdsToCheck.isNotEmpty
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Visibility(
                        visible: userModel.offerIdsToCheck.isNotEmpty,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            color: userModel.offerIdsToCheck.isNotEmpty
                                ? Colors.red
                                : Colors.white,
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              userModel.offerIdsToCheck.length >= 100
                                  ? '99+'
                                  : userModel.offerIdsToCheck.length.toString(),
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
                  : const SizedBox.shrink(),
            ],
          ),
          label: 'Repair'),

      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/garage.png',
            height: 28,
            width: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(1),
          ),
          label: 'My Garage'),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.location_on_outlined,
            size: 28,
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
                height: 28,
                width: 28,
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
                            height: 18,
                            width: 18,
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
          height: 28,
          width: 28,
          // ignore: deprecated_member_use
          color: labelAndIconColorDark(4),
        ),
        label: 'Profile',
      ),
    ];
  }

  Color labelAndIconColor(int index) {
    final UserController userController = Provider.of<UserController>(context);

    int tabIndex = userController.tabIndex;
    bool isDark = userController.isDark;
    Color color = tabIndex == index && isDark ? Colors.white : primaryColor;
    return Color(tabIndex);
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

class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({
    super.key,
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
              userController.userModel!.accountType == 'Provider'
                  ? 'Enable Location for Service\nAvailability'
                  : 'Enable Location for Nearby\nService Providers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 20,
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
                ;
                serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  Geolocator.openLocationSettings();
                } else {
                  // permission = await Geolocator.checkPermission();
                  // permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever ||
                      permission == LocationPermission.unableToDetermine) {
                    Geolocator.openAppSettings();
                  } else {
                    Get.dialog(const LoadingDialog(),
                        barrierDismissible: false);
                    Position position = await Geolocator.getCurrentPosition();
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
                    Get.close(2);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(Get.width * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  )),
              child: Text(
                'Allow Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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

class UpdateSheet extends StatelessWidget {
  const UpdateSheet({
    super.key,
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
                // Get.close(1);
                if (Platform.isAndroid) {
                  launchUrl(Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.nomadllc.vehype'));
                } else {
                  toastification.show(
                    context: context,
                    title: Text('Please update the app from TestFlight'),
                    style: ToastificationStyle.minimal,
                    type: ToastificationType.info,
                    autoCloseDuration: Duration(seconds: 3),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(Get.width * 0.8, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  )),
              child: Text(
                'Update Now',
                style: TextStyle(
                  color: Colors.white,
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
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
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
              OneSignal.login(userController.userModel!.userId);
              Get.close(1);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(Get.width * 0.8, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                )),
            child: Text(
              'Yes, notify me',
              style: TextStyle(
                color: Colors.white,
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
    );
  }
}
