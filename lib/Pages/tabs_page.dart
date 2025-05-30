// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_chat_button/floating_chat_button.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Pages/Provider%20Verification/become_a_provider.dart';
import 'package:vehype/Widgets/notification_permission_sheet.dart';
import 'package:vehype/providers/in_app_purchases_provider.dart';
import '../Controllers/chat_controller.dart';
import '../Controllers/offers_provider.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';
import '../Pages/chat_page.dart';
import '../Pages/explore_page.dart';
import 'Add Manage Vehicle/my_garage.dart';
import '../Pages/orders_history_provider.dart';
import '../Pages/profile_page.dart';
import '../Pages/repair_page.dart';
import '../Pages/second_user_profile.dart';
import '../const.dart';

import '../Controllers/mix_panel_controller.dart';
import '../Controllers/notification_controller.dart';
import '../Models/offers_model.dart';
import 'Personal Assistance /assitance_chat_ui.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with WidgetsBindingObserver {
  final List<Widget> _body = [
    RepairPage(),
    MyGarage(),
    ExplorePage(),
    // Container(),p
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
  bool isAiTitle = true;
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
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(seconds: 0)).then((s) {
      getNotificationSetting();
      userController.initTheme();
      notificationPermission();
      showPermotionalDialoge();
    });
  }

  showPermotionalDialoge() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    await InAppPurchaseProvider.checkSubscriptionStatus(
        userController.userModel!);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isAiTitle = sharedPreferences.getBool('isAiTitle') ?? true;
    bool isLater = sharedPreferences.getBool('isLater') ?? false;
    setState(() {});
    if (userController.userModel!.accountType == 'seeker' &&
        userController.isHaveProvider == false &&
        !isLater) {
      await Future.delayed(Duration(seconds: 3));

      Get.dialog(Dialog(
        insetPadding: EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0.0,
        child: BecomeAProvider(
          isDialog: true,
        ),
      ));
      sharedPreferences.setBool('isLater', true);
    }
  }

  notificationPermission() async {
    bool havePermission = OneSignal.Notifications.permission;
    if (!havePermission) {
      Get.bottomSheet(NotificationSheet());
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) {
      WidgetsBinding.instance.addObserver(this);

      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      userController.initTheme();
    }
  }

  getNotificationSetting() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    _packageInfo = await PackageManager.getPackageInfo();

    // VersionInfo? _versionInfo = await UpgradeVersion.getiOSStoreVersion(
    //     packageInfo: _packageInfo, regionCode: "US");
    // DocumentSnapshot<Map<String, dynamic>> updateInfo = await FirebaseFirestore
    //     .instance
    //     .collection('versionInfo')
    //     .doc('appVersion')
    //     .get();
    // // print(_packageInfo.buildNumber);
    // mixPanelController.trackEvent(eventName: 'Checked for update', data: {});

    // if (int.parse(_packageInfo.buildNumber) < updateInfo['buildNumber']) {
    //   showModalBottomSheet(
    //       context: context,
    //       backgroundColor: userController.isDark ? primaryColor : Colors.white,
    //       // enableDrag: false,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(6),
    //           topRight: Radius.circular(6),
    //         ),
    //       ),
    //       isDismissible: false,
    //       enableDrag: false,
    //       constraints: BoxConstraints(
    //         minWidth: Get.width,
    //         maxWidth: Get.width,
    //       ),
    //       builder: (context) {
    //         return UpdateSheet(
    //           userController: userController,
    //           manager: null,
    //         );
    //       });
    // }
    if (Platform.isAndroid) {
      InAppUpdateManager manager = InAppUpdateManager();
      AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) return;
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        //If an in-app update is already running, resume the update.
      } else if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        showModalBottomSheet(
            context: context,
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
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
                manager: manager,
              );
            });
      }
    } else {
      _packageInfo = await PackageManager.getPackageInfo();

      VersionInfo? versionInfo = await UpgradeVersion.getiOSStoreVersion(
          packageInfo: _packageInfo, regionCode: "US");

      if (double.tryParse(versionInfo.localVersion)! <
          double.tryParse(versionInfo.storeVersion)!) {
        showModalBottomSheet(
            context: context,
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
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
    }
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
    return userModel.accountType != 'seeker'
        ? Scaffold(
            body: IndexedStack(
              index: userModel.accountType == 'seeker'
                  ? userController.tabIndex
                  : userController.tabIndex,
              children: userModel.accountType == 'seeker' ? _body : _body2,
            ),
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
            bottomNavigationBar: userModel.accountType == 'seeker'
                ? bottomNavigationBarSeeker()
                : bottomNavigationBarProvider())
        : userModel.isGuest
            ? Scaffold(
                body: IndexedStack(
                  index: userModel.accountType == 'seeker'
                      ? userController.tabIndex
                      : userController.tabIndex,
                  children: userModel.accountType == 'seeker' ? _body : _body2,
                ),
                backgroundColor:
                    userController.isDark ? primaryColor : Colors.white,
                bottomNavigationBar: userModel.accountType == 'seeker'
                    ? bottomNavigationBarSeeker()
                    : bottomNavigationBarProvider())
            : FloatingChatButton(
                onTap: (s) async {
                  // // ziZhu5-riwpoq

                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();

                  sharedPreferences.setBool('isAiTitle', false);
                  Get.to(() => AssistanceChatUI());
                },
                chatIconHorizontalOffset: 10,
                // showMessageParameters: ShowMessageParameters(),
                chatIconVerticalOffset: Platform.isIOS ? 160 : 140,
                messageText: isAiTitle ? "AI Assistant" : null,
                shouldPutWidgetInCircle: true,
                chatIconSize: 24,
                chatIconWidgetHeight: 55,
                chatIconBorderWidth: 55,

                chatIconBackgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                chatIconColor:
                    userController.isDark ? primaryColor : Colors.white,
                messageTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: userController.isDark ? primaryColor : Colors.white,
                ),
                messageBackgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                background: Scaffold(
                  body: IndexedStack(
                    index: userModel.accountType == 'seeker'
                        ? userController.tabIndex
                        : userController.tabIndex,
                    children:
                        userModel.accountType == 'seeker' ? _body : _body2,
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  bottomNavigationBar: userModel.accountType == 'seeker'
                      ? bottomNavigationBarSeeker()
                      : bottomNavigationBarProvider(),
                ),
              );
  }

  BottomNavigationBar bottomNavigationBarProvider() {
    final UserController userController = Provider.of<UserController>(context);

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
          label: 'Chats'),
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
          label: 'Chats'),
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

                  VersionInfo? versionInfo =
                      await UpgradeVersion.getiOSStoreVersion(
                          packageInfo: _packageInfo, regionCode: "US");
                  debugPrint(versionInfo.toJson().toString());
                  launchUrl(Uri.parse(versionInfo.appStoreLink));
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
