// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/create_request_page.dart';

import 'package:vehype/Widgets/owner_active_offers.dart';
import 'package:vehype/Widgets/owner_inactive_offers_page_widget.dart';
import 'package:vehype/Widgets/owner_inprogress_page_widget.dart';
import 'package:vehype/const.dart';

import '../Controllers/mix_panel_controller.dart';
import '../Widgets/short_prefs_widget.dart';
// import 'choose_account_type.dart';

import 'Personal Assistance /assitance_chat_ui.dart';
import 'owner_notifications_page.dart';

final mixPanelController = Get.find<MixPanelController>();

class RepairPage extends StatefulWidget {
  const RepairPage({super.key});

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  OverlayEntry? _overlayEntry;

  void _showPopup() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Detect taps outside the popup to close it
          GestureDetector(
            onTap: _hidePopup,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent, // Transparent background
            ),
          ),
          Positioned(
            top: kToolbarHeight + 35,
            right: 60.0,
            child: ShortPrefsWidget(onPressed: _hidePopup),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  @override
  void dispose() {
    // _hidePopup(); // Ensure the popup is removed when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    UserModel userModel = userController.userModel!;

    final List<OffersModel> ownerOffersNeedsToCheck = offersProvider.ownerOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersModel> offersPosted = offersProvider.ownerOffers
        .where((offer) => offer.status == 'active')
        .toList();
    offersPosted.sort((a, b) {
      // Primary sort by createdAt
      final dateA = DateTime.parse(a.createdAt).toLocal();
      final dateB = DateTime.parse(b.createdAt).toLocal();

      int timeComparison = userController.sortByTime == 1
          ? dateA.compareTo(dateB) // Ascending order by time
          : dateB.compareTo(dateA); // Descending order by time

      if (timeComparison != 1) {
        return timeComparison;
      }

      // Secondary sort by distance (only if dates are equal)
      double distanceA =
          calculateDistance(userModel.lat, userModel.long, a.lat, a.long);
      double distanceB =
          calculateDistance(userModel.lat, userModel.long, b.lat, b.long);

      return userController.sortByDistance == 0
          ? distanceA.compareTo(distanceB) // Ascending order by distance
          : distanceB.compareTo(distanceA); // Descending order by distance
    });
    final List<OffersModel> inProgressOffers = offersProvider.ownerOffers
        .where((offer) => offer.status == 'inProgress')
        .toList();
    inProgressOffers.sort((a, b) {
      // Primary sort by createdAt
      final dateA = DateTime.parse(a.createdAt).toLocal();
      final dateB = DateTime.parse(b.createdAt).toLocal();

      int timeComparison = userController.sortByTime == 1
          ? dateA.compareTo(dateB) // Ascending order by time
          : dateB.compareTo(dateA); // Descending order by time

      if (timeComparison != 1) {
        return timeComparison;
      }

      // Secondary sort by distance (only if dates are equal)
      double distanceA =
          calculateDistance(userModel.lat, userModel.long, a.lat, a.long);
      double distanceB =
          calculateDistance(userModel.lat, userModel.long, b.lat, b.long);

      return userController.sortByDistance == 0
          ? distanceA.compareTo(distanceB) // Ascending order by distance
          : distanceB.compareTo(distanceA); // Descending order by distance
    });
    final List<OffersModel> inActiveOffers = offersProvider.ownerOffers
        .where((offer) => offer.status == 'inactive')
        .toList();
    inActiveOffers.sort((a, b) {
      // Primary sort by createdAt
      final dateA = DateTime.parse(a.createdAt).toLocal();
      final dateB = DateTime.parse(b.createdAt).toLocal();

      int timeComparison = userController.sortByTime == 1
          ? dateA.compareTo(dateB) // Ascending order by time
          : dateB.compareTo(dateA); // Descending order by time

      if (timeComparison != 1) {
        return timeComparison;
      }

      // Secondary sort by distance (only if dates are equal)
      double distanceA =
          calculateDistance(userModel.lat, userModel.long, a.lat, a.long);
      double distanceB =
          calculateDistance(userModel.lat, userModel.long, b.lat, b.long);

      return userController.sortByDistance == 0
          ? distanceA.compareTo(distanceB) // Ascending order by distance
          : distanceB.compareTo(distanceA); // Descending order by distance
    });
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        floatingActionButton: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: userController.isDark ? Colors.white : primaryColor,
          ),
          child: InkWell(
            onTap: () async {
              // bool dd = await OneSignal.Notifications.requestPermission(true);
              // OneSignal.login(userModel.userId);
              // await sendNotification(userModel.userId, userModel.name);
              // print(dd);
              mixPanelController.trackEvent(
                  eventName: 'Opened Create New Request Page', data: {});
              Get.to(() => CreateRequestPage(
                    offersModel: null,
                  ));
            },
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/repair.png',
                    height: 24,
                    width: 24,
                    color: userController.isDark ? primaryColor : Colors.white,
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 10,
                  child: Icon(
                    Icons.add_box,
                    size: 16, // Slightly smaller for badge effect
                    color: userController.isDark ? primaryColor : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Requests',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // NotificationController().sendNotification(
                    //     offerId: 'offers',
                    //     requestId: 'requestId',
                    //     title: 'title',
                    //     subtitle: 'subtitle',
                    //     userTokens: [userModel.pushToken]);
                    // log(userModel.pushToken);
                    mixPanelController.trackEvent(
                        eventName: 'Opened Owner Notifications Page', data: {});
                    Get.to(() => OwnerNotificationsPage(
                          offers: ownerOffersNeedsToCheck,
                        ));
                  },
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        size: 28,
                      ),
                      if (ownerOffersNeedsToCheck.isNotEmpty)
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.red,
                          ),
                          // padding: const EdgeInsets.all(1),
                          child: Center(
                            child: Text(
                              ownerOffersNeedsToCheck.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                )),
          ],
          bottom: TabBar(
            // isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Active'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'active'))
                      const SizedBox(
                        width: 5,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'active'))
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('In Progress'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inProgress'))
                      const SizedBox(
                        width: 3,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inProgress'))
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('History'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inactive'))
                      const SizedBox(
                        width: 3,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inactive'))
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OwnerActiveOffers(
              postedOffers: offersPosted,
            ),
            OwnerInprogressPageWidget(
              inProgressOffers: inProgressOffers,
            ),
            OwnerInactiveOffersPageWidget(
              inActiveOffers: inActiveOffers,
            ),
          ],
        ),
      ),
    );
  }
}
