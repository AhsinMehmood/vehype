import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

// import 'inactive_offers_seeker.dart';
// import 'offers_received_details.dart';
// import 'received_offers_seeker.dart';
import 'owner_request_details_inprogress_inactive_page.dart';
// import 'requests_received_provider_details.dart';

class OwnerNotificationsPage extends StatefulWidget {
  final List<OffersModel> offers;
  const OwnerNotificationsPage({super.key, required this.offers});

  @override
  State<OwnerNotificationsPage> createState() => _OwnerNotificationsPageState();
}

class _OwnerNotificationsPageState extends State<OwnerNotificationsPage> {
  bool isAll = true;
  List<OffersNotification> offersNotifications = [];
  Map<String, List<OffersNotification>> map = {};
  @override
  void initState() {
    super.initState();
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    UserModel userModel = userController.userModel!;
    for (OffersModel offer in widget.offers) {
      List<OffersNotification> offersNotifications = offer.checkByList
          .where((noti) => noti.checkById == userModel.userId)
          .toList();

      if (map[offer.offerId] != null) {
        map[offer.offerId]!.addAll(offersNotifications);
      } else {
        map[offer.offerId] = offersNotifications;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Get.close(1);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: map.isEmpty
                ? Center(
                    child: Text('Nothing here!'),
                  )
                : ListView.builder(
                    itemCount: map.length,
                    itemBuilder: (context, mapIndex) {
                      OffersModel offersModel = widget.offers.firstWhere(
                          (offer) =>
                              offer.offerId == map.keys.elementAt(mapIndex));
                      List<OffersNotification> notifications =
                          map[offersModel.offerId]!.toList();
                      return ListView.builder(
                          itemCount: notifications.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            OffersNotification notificationsModel =
                                notifications[index];

                            return StreamBuilder<UserModel>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(notificationsModel.senderId)
                                    .snapshots()
                                    .map((ss) => UserModel.fromJson(ss)),
                                builder: (context,
                                    AsyncSnapshot<UserModel> senderSnap) {
                                  if (!senderSnap.hasData) {
                                    return Center();
                                  }
                                  UserModel senderModel = senderSnap.data!;
                                  final createdAt = DateTime.parse(
                                      notificationsModel.createdAt);

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      // left: 3,
                                      // right: 3,
                                      top: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          color: notificationsModel.isRead
                                              ? userController.isDark
                                                  ? primaryColor
                                                  : Colors.white
                                              : changeColor(color: '#658cf6')
                                                  .withOpacity(0.2),
                                          child: InkWell(
                                            onTap: () async {
                                              notificationsModel.isRead = true;
                                              setState(() {});

                                              Get.dialog(LoadingDialog(),
                                                  barrierDismissible: false);
                                              DocumentSnapshot<
                                                      Map<String, dynamic>>
                                                  garageSnap =
                                                  await FirebaseFirestore
                                        
                                        
                                        
                                                      .instance
                                                      .collection('garages')
                                                      .doc(offersModel.garageId)
                                                      .get();
                                              OffersReceivedModel?
                                                  offersReceivedModel;

                                              if (notificationsModel
                                                      .offersReceivedId !=
                                                  '') {
                                                DocumentSnapshot<
                                                        Map<String, dynamic>>
                                                    offerSnap =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'offersReceived')
                                                        .doc(notificationsModel
                                                            .offersReceivedId)
                                                        .get();

                                                offersReceivedModel =
                                                    OffersReceivedModel
                                                        .fromJson(offerSnap);
                                              }
                                              Get.close(1);
                                              OffersController()
                                                  .updateNotificationForOffers(
                                                      offerId:
                                                          offersModel.offerId,
                                                      userId: userModel.userId,
                                                      checkByList: offersModel
                                                          .checkByList,
                                                      isAdd: false,
                                                      offersReceived:
                                                          offersReceivedModel
                                                              ?.id,
                                                      notificationTitle: '',
                                                      senderId:
                                                          userModel.userId,
                                                      notificationSubtitle: '');

                                              if (offersModel.status ==
                                                  'active') {
                                                Get.to(() =>
                                                    OwnerRequestDetailsInprogressInactivePage(
                                                      offersModel: offersModel,
                                                      garageModel:
                                                          GarageModel.fromJson(
                                                              garageSnap),
                                                      offersReceivedModel:
                                                          offersReceivedModel!,
                                                    ));
                                              } else if (offersModel.status ==
                                                      'inProgress' ||
                                                  offersModel.status ==
                                                      'inactive') {
                                                if (offersModel.offersReceived
                                                    .isNotEmpty) {
                                                  Get.to(() =>
                                                      OwnerRequestDetailsInprogressInactivePage(
                                                        offersModel:
                                                            offersModel,
                                                        garageModel: GarageModel
                                                            .fromJson(
                                                                garageSnap),
                                                        offersReceivedModel:
                                                            offersReceivedModel!,
                                                      ));
                                                } else {
                                                  toastification.show(
                                                    context: context,
                                                    title: Text(
                                                        'This request was deleted.'),
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 3),
                                                  );
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 12,
                                                bottom: 12,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            200),
                                                    child:
                                                        ExtendedImage.network(
                                                      senderModel.profileUrl,
                                                      height: 65,
                                                      width: 65,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          notificationsModel
                                                              .subtitle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                : primaryColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          timeago.format(
                                                              createdAt),
                                                          style: TextStyle(
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                : primaryColor,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Column(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.start,
                                                  //   children: [
                                                  //     Icon(Icons
                                                  //         .more_horiz_outlined),
                                                  //   ],
                                                  // )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          });
                    }),
          ),
          if (map.isNotEmpty)
            Container(
              color: userController.isDark ? primaryColor : Colors.white,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      // for (var element in offers) {
                      //   FirebaseFirestore.instance
                      //       .collection('users')
                      //       .doc(userModel.userId)
                      //       .collection('notifications')
                      //       .doc(element.id)
                      //       .delete();
                      // }
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
