// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';

import 'package:vehype/const.dart';

import '../Widgets/ignored_offers_widget.dart';
import '../Widgets/service_request_widget.dart';
import 'notifications_page.dart';

import 'new_offers_page.dart';

class OrdersHistoryProvider extends StatelessWidget {
  const OrdersHistoryProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    UserModel userModel = userController.userModel!;
    List<OffersModel> rawOffers = offersProvider.offers;

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
        .toList();

    List<OffersModel> newOffers = userModel.lat == 0.0
        ? filteredOffers
        : userController.filterOffers(
            filteredOffers, userModel.lat, userModel.long, 50);
    List<OffersModel> notificationToCheckOffersNewOffers = newOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();
    List<OffersReceivedModel> offersReceivedList =
        offersProvider.offersReceived;
    // List<OffersReceivedModel> ignoredOffers = offersReceivedList
    //     .where((element) => element.status == 'ignore')
    //     .toList();
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
    List<OffersReceivedModel> notificationsOffersReceived =
        pendingOffersNotifications +
            completedOffersNotifications +
            upcomingOffersNotifications +
            cencelledOffersNotifications;

    return DefaultTabController(
      length: 6,
      initialIndex: 1,
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
                    Get.to(() => NotificationsPage(
                          notifications: [],
                        ));
                  },
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        size: 26,
                      ),
                      if (notificationsOffersReceived.isNotEmpty)
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
                              notificationsOffersReceived.length.toString(),
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
                    Text('Ignored'),
                  ],
                ),
              ),
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            IgnoredOffers(
              userController: userController,
              userModel: userModel,
              ignoredOffers: ignoredOffers,
            ),
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
            padding:
                const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
            itemBuilder: (context, index) {
              OffersReceivedModel offersReceivedModel = offersPending[index];
              // OffersModel offersModel = userController.historyOffers
              //     .firstWhere((element) =>
              //         element.offerId == offersReceivedModel.offerId);
              // print(offersReceivedModel.id);

              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .doc(offersReceivedModel.offerId)
                      .snapshots(),
                  builder: (context, AsyncSnapshot offerSnap) {
                    if (!offerSnap.hasData) {
                      return SizedBox.shrink();
                    }
                    if (offerSnap.hasError) {
                      return Text(offerSnap.stackTrace.toString());
                    }
                    OffersModel offersModel =
                        OffersModel.fromJson(offerSnap.data);

                    return ServiceRequestWidget(
                      offersModel: offersModel,
                      offersReceivedModel: offersReceivedModel,
                    );
                  });
            });
  }
}
