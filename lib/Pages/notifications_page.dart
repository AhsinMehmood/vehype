import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/notifications_model.dart';
import '../Models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'inactive_offers_seeker.dart';
import 'offers_received_details.dart';
import 'received_offers_seeker.dart';
import 'requests_received_provider_details.dart';

class NotificationsPage extends StatefulWidget {
  final List<NotificationsModel> notifications;
  const NotificationsPage({super.key, required this.notifications});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isAll = true;
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
            fontSize: 17,
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
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  if (isAll) {
                  } else {
                    setState(() {
                      isAll = true;
                    });
                  }
                },
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isAll ? Colors.green : Colors.blueGrey,
                  ),
                  // padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  if (isAll) {
                    setState(() {
                      isAll = false;
                    });
                  } else {}
                },
                child: Container(
                  height: 30,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isAll ? Colors.blueGrey : Colors.green,
                  ),
                  // padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                  child: Center(
                    child: Text(
                      'Unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder<List<NotificationsModel>>(
              initialData: widget.notifications,
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userModel.userId)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  .map((m) => m.docs
                      .map((s) => NotificationsModel.fromJson(s))
                      .toList()),
              builder:
                  (context, AsyncSnapshot<List<NotificationsModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: Text('Nothing Here!'),
                    ),
                  );
                }
                List<NotificationsModel> notificationsStream =
                    snapshot.data ?? [];
                List<NotificationsModel> filterNotifications = isAll
                    ? notificationsStream
                    : notificationsStream
                        .where((dd) => dd.isRead == false)
                        .toList();
                notificationsStream = filterNotifications;
                if (notificationsStream.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text('Nothing Here!'),
                    ),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: notificationsStream.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              NotificationsModel notificationsModel =
                                  notificationsStream[index];
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
                                        left: 6,
                                        right: 6,
                                        top: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          SwipeableTile(
                                            color: notificationsModel.isRead ==
                                                    false
                                                ? Colors.red
                                                : userController.isDark
                                                    ? Colors.blueGrey.shade400
                                                    : Colors.white60,
                                            swipeThreshold: 0.2,
                                            direction:
                                                SwipeDirection.horizontal,
                                            onSwiped: (direction) {
                                              // Here call setState to update state
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userModel.userId)
                                                  .collection('notifications')
                                                  .doc(notificationsModel.id)
                                                  .delete();
                                            },
                                            backgroundBuilder:
                                                (context, direction, progress) {
                                              if (direction ==
                                                  SwipeDirection.endToStart) {
                                                // return your widget
                                              } else if (direction ==
                                                  SwipeDirection.startToEnd) {
                                                // return your widget
                                              }
                                              return Container();
                                            },
                                            key: UniqueKey(),
                                            child: ListTile(
                                              onTap: () async {
                                                if (!notificationsModel
                                                    .isRead) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(userModel.userId)
                                                      .collection(
                                                          'notifications')
                                                      .doc(
                                                          notificationsModel.id)
                                                      .update({
                                                    'isRead': true,
                                                  });
                                                }
                                                print(notificationsModel.type);
                                                if (notificationsModel.type ==
                                                    'request') {
                                                  Get.dialog(LoadingDialog(),
                                                      barrierDismissible:
                                                          false);
                                                  DocumentSnapshot<
                                                          Map<String, dynamic>>
                                                      requestSnap =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('offers')
                                                          .doc(
                                                              notificationsModel
                                                                  .objectId)
                                                          .get();
                                                  OffersModel offersModel =
                                                      OffersModel.fromJson(
                                                          requestSnap);
                                                  Get.close(1);
                                                  UserController()
                                                      .changeNotiOffers(
                                                          0,
                                                          false,
                                                          userModel.userId,
                                                          offersModel.offerId,
                                                          userModel
                                                              .accountType);
                                                  if (offersModel.status ==
                                                          'active' &&
                                                      !offersModel.ignoredBy
                                                          .contains(userModel
                                                              .userId) &&
                                                      !offersModel
                                                          .offersReceived
                                                          .contains(userModel
                                                              .userId)) {
                                                    Get.to(() =>
                                                        OfferReceivedDetails(
                                                          offersModel:
                                                              offersModel,
                                                        ));
                                                  } else {
                                                    toastification.show(
                                                      title: Text(
                                                          'The request has been moved to another page'),
                                                      style: ToastificationStyle
                                                          .minimal,
                                                      autoCloseDuration:
                                                          Duration(
                                                        seconds: 3,
                                                      ),
                                                      context: context,
                                                    );
                                                  }
                                                } else if (notificationsModel
                                                        .type ==
                                                    'offer') {
                                                  Get.dialog(LoadingDialog(),
                                                      barrierDismissible:
                                                          false);
                                                  DocumentSnapshot<
                                                          Map<String, dynamic>>
                                                      offersReceivedSnap =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'offersReceived')
                                                          .doc(
                                                              notificationsModel
                                                                  .objectId)
                                                          .get();
                                                  OffersReceivedModel
                                                      offersReceivedModel =
                                                      OffersReceivedModel
                                                          .fromJson(
                                                              offersReceivedSnap);

                                                  DocumentSnapshot<
                                                          Map<String, dynamic>>
                                                      requestSnap =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('offers')
                                                          .doc(
                                                              offersReceivedModel
                                                                  .offerId)
                                                          .get();
                                                  OffersModel offersModel =
                                                      OffersModel.fromJson(
                                                          requestSnap);

                                                  int id = offersReceivedModel
                                                              .status ==
                                                          'Pending'
                                                      ? 1
                                                      : offersReceivedModel
                                                                  .status ==
                                                              'inProgress'
                                                          ? 2
                                                          : offersReceivedModel
                                                                      .status ==
                                                                  'Completed'
                                                              ? 3
                                                              : 4;
                                                  UserController()
                                                      .changeNotiOffers(
                                                          id,
                                                          false,
                                                          userModel.userId,
                                                          offersModel.offerId,
                                                          userModel
                                                              .accountType);
                                                  Get.close(1);
                                                  Get.to(() =>
                                                      RequestsReceivedProviderDetails(
                                                        offersModel:
                                                            offersModel,
                                                        offersReceivedModel:
                                                            offersReceivedModel,
                                                      ));
                                                }
                                              },
                                              // selected: notificationsModel.isRead,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              tileColor: notificationsModel
                                                          .isRead ==
                                                      false
                                                  ? Colors.red
                                                  : userController.isDark
                                                      ? Colors.blueGrey.shade400
                                                      : Colors.white60,
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                child: ExtendedImage.network(
                                                  senderModel.profileUrl,
                                                  height: 45,
                                                  width: 45,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(
                                                notificationsModel.title,
                                                style: TextStyle(
                                                  color: notificationsModel
                                                              .isRead ==
                                                          false
                                                      ? Colors.white
                                                      : userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                notificationsModel.subTitle,
                                                style: TextStyle(
                                                    color: notificationsModel
                                                                .isRead ==
                                                            false
                                                        ? Colors.white
                                                        : userController.isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              trailing: Text(
                                                timeago.format(createdAt),
                                                style: TextStyle(
                                                  color: notificationsModel
                                                              .isRead ==
                                                          false
                                                      ? Colors.white
                                                      : userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            height: 1,
                                            width: Get.width,
                                            color: changeColor(color: 'D9D9D9'),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            }),
                      ),
                      if (notificationsStream.isNotEmpty)
                        Container(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
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
                                  for (var element in notificationsStream) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userModel.userId)
                                        .collection('notifications')
                                        .doc(element.id)
                                        .delete();
                                  }
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
              }),
        ],
      ),
    );
  }
}

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    super.key,
    required this.notificationsModel,
    required this.senderModel,
    required this.userController,
  });

  final NotificationsModel notificationsModel;
  final UserModel senderModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: notificationsModel.isRead == false
          ? Colors.green.withOpacity(0.4)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        // color: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: ExtendedImage.network(
                    senderModel.profileUrl,
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          notificationsModel.title,
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '1 hour ago',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      notificationsModel.subTitle,
                      style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
