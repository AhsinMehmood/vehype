// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/notifications_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_provider_short_widget.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import 'full_image_view_page.dart';
import 'inactive_offers_seeker.dart';
import 'notifications_page.dart';
import 'offers_received_details.dart';
import 'offers_tab_page.dart';
import 'received_offers_seeker.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersHistoryProvider extends StatefulWidget {
  const OrdersHistoryProvider({super.key});

  @override
  State<OrdersHistoryProvider> createState() => _OrdersHistoryProviderState();
}

class _OrdersHistoryProviderState extends State<OrdersHistoryProvider> {
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  getHistory() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    await userController.getRequestsHistoryProvider();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

    return DefaultTabController(
      length: 5,
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userModel.userId)
                      .collection('notifications')
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          notificationSnap) {
                    List<NotificationsModel> notifications = [];
                    if (!notificationSnap.hasData) {
                      return IconButton(
                        onPressed: () {
                          Get.to(() => NotificationsPage(
                                notifications: [],
                              ));
                        },
                        icon: Icon(
                          Icons.notifications,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          size: 30,
                        ),
                      );
                    }
                    for (var notificationData in notificationSnap.data!.docs) {
                      notifications
                          .add(NotificationsModel.fromJson(notificationData));
                    }
                    if (notifications.isEmpty) {
                      return IconButton(
                        onPressed: () {
                          Get.to(() => NotificationsPage(
                                notifications: [],
                              ));
                        },
                        icon: Icon(
                          Icons.notifications,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          size: 30,
                        ),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        Get.to(() => NotificationsPage(
                              notifications: notifications,
                            ));
                      },
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            size: 30,
                          ),
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Colors.red,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                notifications.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Text('New'),
                    if (userModel.isActiveNew)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveNew)
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
                    if (userModel.isActivePending)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActivePending)
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
                    if (userModel.isActiveInProgress)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveInProgress)
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
                    if (userModel.isActiveCompleted)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveCompleted)
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
                    if (userModel.isActiveCancelled)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveCancelled)
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
        body: StreamBuilder<List<OffersReceivedModel>>(
            stream: FirebaseFirestore.instance
                .collection('offersReceived')
                .where('offerBy', isEqualTo: userModel.userId)
                .orderBy('createdAt', descending: true)
                .snapshots()
                .map((event) => event.docs
                    .map((e) => OffersReceivedModel.fromJson(e))
                    .toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              List<OffersReceivedModel> offersReceivedList =
                  snapshot.data ?? [];
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

              return TabBarView(
                children: [
                  NewOffers(
                      userController: userController, userModel: userModel),
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
              );
            }),
      ),
    );
  }
}

class Offers extends StatefulWidget {
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
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = widget.userController.userModel!;

    return widget.offersPending.isEmpty
        ? Center(
            child: Text(
              widget.emptyText,
              style: TextStyle(
                color:
                    widget.userController.isDark ? Colors.white : primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            itemCount: widget.offersPending.length,
            shrinkWrap: true,
            padding:
                const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
            itemBuilder: (context, index) {
              OffersReceivedModel offersReceivedModel =
                  widget.offersPending[index];
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
                    Future.delayed(const Duration(seconds: 4)).then((e) {
                      if (widget.id == 1) {
                        // if (userModel.isActivePending) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                      }
                      // }
                      if (widget.id == 2) {
                        // if (userModel.isActiveInProgress) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                      if (widget.id == 3) {
                        // if (userModel.isActiveCompleted) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                      if (widget.id == 4) {
                        // if (userModel.isActiveCancelled) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                    });

                    return OffersHistoryWidget(
                        userController: widget.userController,
                        offersModel: offersModel,
                        id: widget.id,
                        offersReceivedModel: offersReceivedModel);
                  });
            });
  }
}

class OffersHistoryWidget extends StatelessWidget {
  const OffersHistoryWidget({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.offersReceivedModel,
    required this.id,
  });

  final UserController userController;

  final OffersModel offersModel;
  final int id;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RequestsProviderShortWidgetActive(
                  offersModel: offersModel,
                  title: '',
                  offersReceivedModel: offersReceivedModel,
                ),
              ],
            ),
          ),

          // OfferReceivedDetails(offersModel: offersModel),
        ],
      ),
    );
  }
}
