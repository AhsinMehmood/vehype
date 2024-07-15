// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Pages/select_service_crv.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;

import '../Models/notifications_model.dart';
import '../Widgets/requests_owner_short_widget.dart';
import 'choose_account_type.dart';
import 'notifications_page.dart';
import 'owner_notifications_page.dart';

Future<void> sendNotification(String userId, String userName, String heading,
    String contents, String objectId, String type, String messageId) async {
  const appId = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
  const restApiKey = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';

  final message = {
    'app_id': appId,
    'headings': {'en': heading},
    'contents': {'en': contents},
    'include_external_user_ids': [userId],
    'data': {
      'objectId': objectId,
      'type': type,
      'messageId': messageId,
    },
  };

  try {
    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      body: jsonEncode(message),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $restApiKey',
      },
    );
    print('Notification sent: ${response.body}');
  } catch (error) {
    print('Error sending notification: $error');
  }
}

class RepairPage extends StatefulWidget {
  const RepairPage({super.key});

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  // bool isShow = false;
  @override
  void initState() {
    super.initState();
    getNotificationSetting();
  }

  getNotificationSetting() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    bool isNotAllowed = await OneSignal.Notifications.canRequest();
    userController.changeIsShow(isNotAllowed);
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          floatingActionButton: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: userController.isDark ? Colors.white : primaryColor,
            ),
            child: InkWell(
              onTap: () async {
                // bool dd = await OneSignal.Notifications.requestPermission(true);
                // OneSignal.login(userModel.userId);
                // await sendNotification(userModel.userId, userModel.name);
                // print(dd);
                if (userModel.email == 'No email set') {
                  Get.showSnackbar(GetSnackBar(
                    message: 'Login to continue',
                    duration: const Duration(
                      seconds: 3,
                    ),
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                    mainButton: TextButton(
                      onPressed: () {
                        Get.to(() => ChooseAccountTypePage());
                        Get.closeCurrentSnackbar();
                      },
                      child: Text(
                        'Login Page',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  ));
                } else {
                  Get.to(() => CreateRequestPage(
                        offersModel: null,
                      ));
                }
              },
              child: Center(
                child: Icon(
                  Icons.add,
                  color: userController.isDark ? primaryColor : Colors.white,
                ),
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
            elevation: 0.0,
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
                      for (var notificationData
                          in notificationSnap.data!.docs) {
                        notifications
                            .add(NotificationsModel.fromJson(notificationData));
                      }
                      if (notifications.isEmpty) {
                        return IconButton(
                          onPressed: () {
                            Get.to(() => OwnerNotificationsPage(
                                  notifications: [],
                                ));
                            // toastification.dismissAll(
                            //     // title: Text('data'),
                            //     // context: context,
                            //     // alignment: Alignment.bottomCenter,
                            //     );
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
                          Get.to(() => OwnerNotificationsPage(
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
              // isScrollable: true,
              indicatorColor:
                  userController.isDark ? Colors.white : primaryColor,
              labelColor: userController.isDark ? Colors.white : primaryColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Active'),
                      if (userModel.isActive)
                        const SizedBox(
                          width: 5,
                        ),
                      if (userModel.isActive)
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('History'),
                      if (userModel.isActiveHistory)
                        const SizedBox(
                          width: 5,
                        ),
                      if (userModel.isActiveHistory)
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
          body: TabBarView(children: [
            SafeArea(
              child: StreamBuilder<List<OffersModel>>(
                  stream: GarageController()
                      .getRepairOffersPosted(userModel.userId),
                  builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                    if (!snap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(snap.error.toString()),
                      );
                    }
                    List<OffersModel> offersPosted = snap.data ?? [];
                    List<OffersModel> filterOffers = [];
                    if (offersPosted.isEmpty) {
                      return Center(
                        child: Text(
                          'Create a Request to Hire a Proffesional',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return ActiveOffers(
                        offersPosted: offersPosted,
                        userController: userController);
                  }),
            ),
            SafeArea(
              child: StreamBuilder<List<OffersModel>>(
                  stream: GarageController()
                      .getRepairOffersPostedInProgress(userModel.userId),
                  builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                    if (!snap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(snap.error.toString()),
                      );
                    }
                    List<OffersModel> offersPosted = snap.data ?? [];
                    List<OffersModel> filterOffers = [];
                    if (offersPosted.isEmpty) {
                      return Center(
                        child: Text(
                          'No In Progress Offers Yet!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return InActiveOffers(
                        title: 'Check Progress',
                        offersPosted: offersPosted,
                        userController: userController);
                  }),
            ),
            SafeArea(
              child: StreamBuilder<List<OffersModel>>(
                  stream: GarageController()
                      .getRepairOffersPostedInactive(userModel.userId),
                  builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                    if (!snap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(snap.error.toString()),
                      );
                    }
                    List<OffersModel> offersPosted = snap.data ?? [];
                    List<OffersModel> filterOffers = [];

                    if (offersPosted.isEmpty) {
                      return Center(
                        child: Text(
                          'No History Yet!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return InActiveOffers(
                        offersPosted: offersPosted,
                        title: 'Job Details',
                        userController: userController);
                  }),
            ),
          ])),
    );
  }
}

class InActiveOffers extends StatefulWidget {
  const InActiveOffers(
      {super.key,
      required this.offersPosted,
      required this.userController,
      required this.title});
  final String title;
  final List<OffersModel> offersPosted;
  final UserController userController;

  @override
  State<InActiveOffers> createState() => _InActiveOffersState();
}

class _InActiveOffersState extends State<InActiveOffers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.offersPosted.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          bottom: 70,
        ),
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          OffersModel offersModel = widget.offersPosted[index];

          List<String> vehicleInfo = offersModel.vehicleId.split(',');
          final String vehicleType = vehicleInfo[0].trim();
          final String vehicleMake = vehicleInfo[1].trim();
          final String vehicleYear = vehicleInfo[2].trim();
          final String vehicleModle = vehicleInfo[3].trim();
          return RequestsOwnerShortWidgetActive(
            offersModel: offersModel,
            title: widget.title,
          );
        });
  }
}

class ActiveOffers extends StatefulWidget {
  const ActiveOffers({
    super.key,
    required this.offersPosted,
    required this.userController,
  });

  final List<OffersModel> offersPosted;
  final UserController userController;

  @override
  State<ActiveOffers> createState() => _ActiveOffersState();
}

class _ActiveOffersState extends State<ActiveOffers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.offersPosted.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 70),
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          OffersModel offersModel = widget.offersPosted[index];

          return Column(
            children: [
              RequestsOwnerShortWidgetActive(
                offersModel: offersModel,
                isActive: true,
                title: '',
              ),
            ],
          );
        });
  }
}
