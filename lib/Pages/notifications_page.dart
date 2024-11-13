import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

// import 'inactive_offers_seeker.dart';
// import 'offers_received_details.dart';
// import 'received_offers_seeker.dart';
import 'service_request_details.dart';

// import 'requests_received_provider_details.dart';

class NotificationsPage extends StatefulWidget {
  final List<OffersModel> offers;
  final List<OffersReceivedModel> offersReceivedModelList;
  const NotificationsPage(
      {super.key, required this.offers, required this.offersReceivedModelList});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isAll = true;
  List<OffersNotification> offersNotifications = [];

  Map<String, List<OffersNotification>> map = {};
  @override
  void initState() {
    super.initState();
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    UserModel userModel = userController.userModel!;
    // print(widget.offers.length);
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
    for (OffersReceivedModel offer in widget.offersReceivedModelList) {
      List<OffersNotification> offersNotifications = offer.checkByList
          .where((noti) => noti.checkById == userModel.userId)
          .toList();

      if (map[offer.id] != null) {
        map[offer.id]!.addAll(offersNotifications);
      } else {
        map[offer.id] = offersNotifications;
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
                      // Get the current offerId based on the map index
                      String offerId = map.keys.elementAt(mapIndex);

                      // Check if the offerId exists in widget.offers
                      OffersModel? offersModel = widget.offers.firstWhereOrNull(
                        (offer) => offer.offerId == offerId,
                      );

                      // If not found in OffersModel, check in OffersReceivedModel
                      OffersReceivedModel? offersReceivedModel =
                          widget.offersReceivedModelList.firstWhereOrNull(
                        (offer) => offer.id == offerId,
                      );

                      // Choose the correct model (either from OffersModel or OffersReceivedModel)
                      var selectedModel = offersModel ?? offersReceivedModel;

                      if (selectedModel == null) {
                        return SizedBox
                            .shrink(); // Return an empty widget if no model is found
                      }

                      // Get the notifications from the map
                      List<OffersNotification> notifications =
                          map[offerId]!.toList();

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

                                  return Container(
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
                                        // print(30030.toString());
                                        if (selectedModel is OffersModel) {
                                          OffersReceivedModel?
                                              offersReceivedModels;

                                          if (notificationsModel
                                                  .offersReceivedId !=
                                              '') {
                                            DocumentSnapshot<
                                                    Map<String, dynamic>>
                                                offerSnap =
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'offersReceived')
                                                    .doc(notificationsModel
                                                        .offersReceivedId)
                                                    .get();

                                            offersReceivedModels =
                                                OffersReceivedModel.fromJson(
                                                    offerSnap);
                                          }
                                          Get.close(1);
                                          OffersController()
                                              .updateNotificationForOffers(
                                                  offerId:
                                                      selectedModel.offerId,
                                                  userId: userModel.userId,
                                                  checkByList:
                                                      selectedModel.checkByList,
                                                  isAdd: false,
                                                  offersReceived:
                                                      offersReceivedModels?.id,
                                                  notificationTitle: '',
                                                  senderId: userModel.userId,
                                                  notificationSubtitle: '');

                                          if (selectedModel
                                              .offersReceived.isNotEmpty) {
                                            Get.to(() => ServiceRequestDetails(
                                                  offersModel: selectedModel,
                                                  // chatId: chatModel.id,
                                                  offersReceivedModel:
                                                      offersReceivedModels,
                                                ));
                                          } else {
                                            if (offersReceivedModels == null) {
                                              Get.to(() =>
                                                  ServiceRequestDetails(
                                                    offersModel: selectedModel,
                                                    // chatId: chatModel.id,
                                                    offersReceivedModel:
                                                        offersReceivedModels,
                                                  ));
                                            } else {
                                              toastification.show(
                                                context: context,
                                                title: Text(
                                                    'This request was deleted.'),
                                                autoCloseDuration:
                                                    const Duration(seconds: 3),
                                              );
                                            }
                                          }
                                        } else if (selectedModel
                                            is OffersReceivedModel) {
                                          DocumentSnapshot<Map<String, dynamic>>
                                              offerSnap =
                                              await FirebaseFirestore.instance
                                                  .collection('offers')
                                                  .doc(selectedModel.offerId)
                                                  .get();

                                          Get.close(1);
                                          OffersController()
                                              .updateNotificationForOffers(
                                                  offerId:
                                                      selectedModel.offerId,
                                                  userId: userModel.userId,
                                                  checkByList:
                                                      selectedModel.checkByList,
                                                  isAdd: false,
                                                  offersReceived:
                                                      selectedModel.id,
                                                  notificationTitle: '',
                                                  senderId: userModel.userId,
                                                  notificationSubtitle: '');

                                          Get.to(() => ServiceRequestDetails(
                                                offersModel:
                                                    OffersModel.fromJson(
                                                        offerSnap),
                                                // chatId: chatModel.id,
                                                offersReceivedModel:
                                                    selectedModel,
                                              ));
                                          // if (offersReceivedModels ==
                                          //     null) {

                                          // } else {
                                          //   toastification.show(
                                          //     context: context,
                                          //     title: Text(
                                          //         'This request was deleted.'),
                                          //     autoCloseDuration:
                                          //         const Duration(
                                          //             seconds: 3),
                                          //   );
                                          // }
                                        }
                                      },
                                      child: Dismissible(
                                        key: Key(notificationsModel.createdAt),
                                        onDismissed: (direction) async {
                                          notificationsModel.isRead = true;
                                          // notifications.removeAt(index);
                                          // map.removeWhere(offerId, )
                                          map.remove(offerId);
                                          setState(() {});

                                          Get.dialog(LoadingDialog(),
                                              barrierDismissible: false);
                                          if (selectedModel is OffersModel) {
                                            OffersReceivedModel?
                                                offersReceivedModels;

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

                                              offersReceivedModels =
                                                  OffersReceivedModel.fromJson(
                                                      offerSnap);
                                            }
                                            Get.close(1);
                                            OffersController()
                                                .updateNotificationForOffers(
                                                    offerId:
                                                        selectedModel.offerId,
                                                    userId: userModel.userId,
                                                    checkByList: selectedModel
                                                        .checkByList,
                                                    isAdd: false,
                                                    offersReceived:
                                                        offersReceivedModels
                                                            ?.id,
                                                    notificationTitle: '',
                                                    senderId: userModel.userId,
                                                    notificationSubtitle: '');
                                          } else if (selectedModel
                                              is OffersReceivedModel) {
                                            Get.close(1);
                                            OffersController()
                                                .updateNotificationForOffers(
                                                    offerId:
                                                        selectedModel.offerId,
                                                    userId: userModel.userId,
                                                    checkByList: selectedModel
                                                        .checkByList,
                                                    isAdd: false,
                                                    offersReceived:
                                                        selectedModel.id,
                                                    notificationTitle: '',
                                                    senderId: userModel.userId,
                                                    notificationSubtitle: '');

                                            // if (offersReceivedModels ==
                                            //     null) {

                                            // } else {
                                            //   toastification.show(
                                            //     context: context,
                                            //     title: Text(
                                            //         'This request was deleted.'),
                                            //     autoCloseDuration:
                                            //         const Duration(
                                            //             seconds: 3),
                                            //   );
                                            // }
                                          }
                                        },
                                        secondaryBackground: Container(
                                          color: Colors.red,
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                        background: Container(
                                          color: Colors.red,
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 12,
                                            bottom: 12,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const SizedBox.shrink(),
                                                  imageUrl:
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      notificationsModel
                                                          .subtitle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                      timeago.format(createdAt),
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
                    onTap: () async {
                      for (String offerId in map.keys) {
                        List<OffersNotification> notifications = map[offerId]!;

                        OffersModel? offersModel =
                            widget.offers.firstWhereOrNull(
                          (offer) => offer.offerId == offerId,
                        );

                        OffersReceivedModel? offersReceivedModel =
                            widget.offersReceivedModelList.firstWhereOrNull(
                          (offer) => offer.id == offerId,
                        );

                        var selectedModel = offersModel ?? offersReceivedModel;

                        // if (selectedModel == null) continue;

                        for (OffersNotification notificationsModel
                            in notifications) {
                          // Get.dialog(LoadingDialog(),
                          //     barrierDismissible: false);
                          if (selectedModel is OffersModel) {
                            OffersReceivedModel? offersReceivedModels;

                            if (notificationsModel.offersReceivedId != '') {
                              DocumentSnapshot<Map<String, dynamic>> offerSnap =
                                  await FirebaseFirestore.instance
                                      .collection('offersReceived')
                                      .doc(notificationsModel.offersReceivedId)
                                      .get();

                              offersReceivedModels =
                                  OffersReceivedModel.fromJson(offerSnap);
                            }
                            // Get.close(1);
                            OffersController().updateNotificationForOffers(
                                offerId: selectedModel.offerId,
                                userId: userModel.userId,
                                checkByList: selectedModel.checkByList,
                                isAdd: false,
                                offersReceived: offersReceivedModels?.id,
                                notificationTitle: '',
                                senderId: userModel.userId,
                                notificationSubtitle: '');
                          } else if (selectedModel is OffersReceivedModel) {
                            // Get.close(1);
                            OffersController().updateNotificationForOffers(
                                offerId: selectedModel.offerId,
                                userId: userModel.userId,
                                checkByList: selectedModel.checkByList,
                                isAdd: false,
                                offersReceived: selectedModel.id,
                                notificationTitle: '',
                                senderId: userModel.userId,
                                notificationSubtitle: '');
                          }
                        }
                      }
                      map.clear();
                      setState(() {});

                      // Clear the map after processing all notifications
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

  Future<void> processNotification(String offerId,
      OffersNotification notification, dynamic selectedModel) async {
    // Get.dialog(LoadingDialog(), barrierDismissible: false);
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    if (selectedModel is OffersModel) {
      OffersReceivedModel? offersReceivedModels;

      if (notification.offersReceivedId != '') {
        DocumentSnapshot<Map<String, dynamic>> offerSnap =
            await FirebaseFirestore.instance
                .collection('offersReceived')
                .doc(notification.offersReceivedId)
                .get();

        offersReceivedModels = OffersReceivedModel.fromJson(offerSnap);
      }
      // Get.close(1);

      OffersController().updateNotificationForOffers(
        offerId: selectedModel.offerId,
        userId: userModel.userId,
        checkByList: selectedModel.checkByList,
        isAdd: false,
        offersReceived: offersReceivedModels?.id,
        notificationTitle: '',
        senderId: userModel.userId,
        notificationSubtitle: '',
      );
    } else if (selectedModel is OffersReceivedModel) {
      // Get.close(1);

      OffersController().updateNotificationForOffers(
          offerId: selectedModel.offerId,
          userId: userModel.userId,
          checkByList: selectedModel.checkByList,
          isAdd: false,
          offersReceived: selectedModel.id,
          notificationTitle: '',
          senderId: userModel.userId,
          notificationSubtitle: '');
    }
  }
}
