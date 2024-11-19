// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/audio_page.dart';
import 'package:vehype/Widgets/short_prefs_widget.dart';

import 'package:vehype/const.dart';

import '../Widgets/ignored_offers_widget.dart';
import '../Widgets/service_request_widget.dart';
import 'notifications_page.dart';

import 'new_offers_page.dart';

class OrdersHistoryProvider extends StatefulWidget {
  const OrdersHistoryProvider({super.key});

  @override
  State<OrdersHistoryProvider> createState() => _OrdersHistoryProviderState();
}

class _OrdersHistoryProviderState extends State<OrdersHistoryProvider> {
  OverlayEntry? _overlayEntry;

  void _togglePopup() {
    if (_overlayEntry == null) {
      _showPopup();
    } else {
      _hidePopup();
    }
  }

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
    // List>
    List<OffersModel> rawOffers = offersProvider.offers;
    rawOffers.sort((a, b) {
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
// Filter offers based on user criteria
    List<OffersModel> ignoredOffers = rawOffers
        .where((offer) => offer.ignoredBy.contains(userModel.userId))
        .toList();
    // List<OffersModel> ignoredOffers = filterIgnoredOffers;
    List<OffersModel> filteredOffers = rawOffers
        .where((offer) => !offer.offersReceived.contains(userModel.userId))
        .where((offer) => !offer.ignoredBy.contains(userModel.userId))
        .where((offer) => !userModel.blockedUsers.contains(offer.ownerId))
        .where((offer) => userModel.services.contains(offer.issue))
        .where((offer) => userModel.vehicleTypes.contains(offer.vehicleType))
        .toList();

    for (var element in filteredOffers) {
      log(element.vehicleType);
    }

    List<OffersModel> newOffers = userModel.lat == 0.0
        ? filteredOffers
        : userController.filterOffers(filteredOffers, userModel.lat,
            userModel.long, userModel.radius.toDouble());
    List<OffersModel> notificationToCheckOffersNewOffers = newOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> offersReceivedList =
        offersProvider.offersReceived;
    // List<OffersReceivedModel> ignoredOffers = offersReceivedList
    //     .where((element) => element.status == 'ignore')
    //     .toList();
    List<OffersReceivedModel> rejectedOffers = offersReceivedList
        .where((element) => element.status == 'ignore')
        .toList();
    List<OffersReceivedModel> offersPending = offersReceivedList
        .where((element) => element.status == 'Pending')
        .toList();

    List<OffersReceivedModel> offersCompleted = offersReceivedList
        .where((element) => element.status == 'Completed')
        .toList();
    List<OffersReceivedModel> offersCencelled = offersReceivedList
        .where((element) => element.status == 'Cancelled')
        .toList();
    List<OffersReceivedModel> upcomingOffers = offersReceivedList
        .where((element) => element.status == 'Upcoming')
        .toList();
    List<OffersReceivedModel> pendingOffersNotifications = offersPending
        .where((element) => element.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> completedOffersNotifications = offersCompleted
        .where((element) => element.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();

    List<OffersReceivedModel> upcomingOffersNotifications = upcomingOffers
        .where((element) => element.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> cencelledOffersNotifications = offersCencelled
        .where((element) => element.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> rejectedOffersNotifications = rejectedOffers
        .where((element) => element.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> notificationsOffersReceived =
        pendingOffersNotifications +
            completedOffersNotifications +
            upcomingOffersNotifications +
            cencelledOffersNotifications +
            rejectedOffersNotifications;
    if (userModel.services.isEmpty) {
      return SelectYourServices();
    }
    return DefaultTabController(
      length: 7,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          centerTitle: true,
          title: Text(
            'Requests',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () {
                    _showPopup();
                    // Get.to(AudioPage());
                  },
                  child: Icon(
                    _overlayEntry == null
                        ? CupertinoIcons.slider_horizontal_3
                        : Icons.close,
                    size: 26,
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // print(notificationToCheckOffersNewOffers.length);
                    // print(notificationsOffersReceived.length);

                    Get.to(() => NotificationsPage(
                          offers: notificationToCheckOffersNewOffers,
                          offersReceivedModelList: notificationsOffersReceived,
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
                      if ((notificationToCheckOffersNewOffers.length +
                              notificationsOffersReceived.length) !=
                          0)
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Center(
                            child: Text(
                              (notificationToCheckOffersNewOffers.length +
                                      notificationsOffersReceived.length)
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ))
          ],
          bottom: TabBar(
            enableFeedback: true,
            isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Text('New'),
                    if (notificationToCheckOffersNewOffers.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (notificationToCheckOffersNewOffers.isNotEmpty)
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
                  children: [
                    Text('Pending'),
                    if (pendingOffersNotifications.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (pendingOffersNotifications.isNotEmpty)
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
                  children: [
                    Text('In Progress'),
                    if (upcomingOffersNotifications.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (upcomingOffersNotifications.isNotEmpty)
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
                  children: [
                    Text('Completed'),
                    if (completedOffersNotifications.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (completedOffersNotifications.isNotEmpty)
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
                  children: [
                    Text('Cancelled'),
                    if (cencelledOffersNotifications.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (cencelledOffersNotifications.isNotEmpty)
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
                  children: [
                    Text('Ignored'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Text('Rejected'),
                    if (rejectedOffersNotifications.isNotEmpty)
                      const SizedBox(
                        width: 2,
                      ),
                    if (rejectedOffersNotifications.isNotEmpty)
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NewOffers(
              userController: userController,
              userModel: userModel,
              newOffers: newOffers,
            ),
            Offers(
                userController: userController,
                emptyText: 'No Pending Offers Yet!',
                id: 1,
                offersPending: offersPending),
            Offers(
                userController: userController,
                emptyText: 'No Accepted Offers Yet!',
                id: 2,
                offersPending: upcomingOffers),
            Offers(
                userController: userController,
                id: 3,
                emptyText: 'No Completed Offers Yet!',
                offersPending: offersCompleted),
            Offers(
                userController: userController,
                id: 4,
                emptyText: 'No Cancelled Offers Yet!',
                offersPending: offersCencelled),
            IgnoredOffers(
              userController: userController,
              userModel: userModel,
              ignoredOffers: ignoredOffers,
            ),
            Offers(
                userController: userController,
                id: 5,
                emptyText: 'No Rejected Offers Yet!',
                offersPending: rejectedOffers),
          ],
        ),
      ),
    );
  }
}

class Offers extends StatelessWidget {
  final int id;
  const Offers({
    super.key,
    required this.userController,
    required this.offersPending,
    required this.emptyText,
    required this.id,
  });

  final String emptyText;

  final UserController userController;
  final List<OffersReceivedModel> offersPending;

  @override
  Widget build(BuildContext context) {
    offersPending.sort((a, b) => b.offerAt.compareTo(a.offerAt));
    return offersPending.isEmpty
        ? Center(
            child: Text(
              emptyText,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            itemCount: offersPending.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding:
                const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
            itemBuilder: (context, index) {
              OffersReceivedModel offersReceivedModel = offersPending[index];
              // OffersModel offersModel = userController.historyOffers
              //     .firstWhere((element) =>
              //         element.offerId == offersReceivedModel.offerId);
              // print(offersReceivedModel.id);

              return StreamBuilder<OffersModel>(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .doc(offersReceivedModel.offerId)
                      .snapshots()
                      .map((convert) => OffersModel.fromJson(convert)),
                  builder: (context, AsyncSnapshot<OffersModel> offerSnap) {
                    if (!offerSnap.hasData && offerSnap.data == null) {
                      return SizedBox(
                        height: 350,
                        width: Get.width,
                      );
                    }
                    if (offerSnap.hasError) {
                      return Text(offerSnap.stackTrace.toString());
                    }
                    OffersModel offersModel = offerSnap.data!;

                    return ServiceRequestWidget(
                      offersModel: offersModel,
                      offersReceivedModel: offersReceivedModel,
                    );
                  });
            });
  }
}
