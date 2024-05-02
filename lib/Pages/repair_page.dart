// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Pages/inactive_offers_seeker.dart';
import 'package:vehype/Pages/received_offers_seeker.dart';
import 'package:vehype/Pages/select_service_crv.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/vehicle_owner_request_widget.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;
import '../Controllers/vehicle_data.dart';
import 'choose_account_type.dart';
import 'full_image_view_page.dart';

Future<void> sendNotification(String userId, String userName, String heading,
    String contents, String chatId, String type, String messageId) async {
  const appId = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
  const restApiKey = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';

  final message = {
    'app_id': appId,
    'headings': {'en': heading},
    'contents': {'en': contents},
    'include_external_user_ids': [userId],
    'data': {
      'chatId': chatId,
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

class RepairPage extends StatelessWidget {
  const RepairPage({super.key});

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
                  Get.to(() => SelectServiceCreateVehicle(
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
            bottom: TabBar(
              // isScrollable: true,
              indicatorColor:
                  userController.isDark ? Colors.white : primaryColor,
              labelColor: userController.isDark ? Colors.white : primaryColor,
              tabs: [
                Tab(
                  text: 'Active',
                ),
                Tab(
                  text: 'In Progress',
                ),
                Tab(
                  text: 'History',
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
                          'Nothing Yet!',
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
                        userController: userController);
                  }),
            ),
          ])),
    );
  }
}

class InActiveOffers extends StatelessWidget {
  const InActiveOffers({
    super.key,
    required this.offersPosted,
    required this.userController,
  });

  final List<OffersModel> offersPosted;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListView.builder(
              itemCount: offersPosted.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                OffersModel offersModel = offersPosted[index];

                List<String> vehicleInfo = offersModel.vehicleId.split(',');
                final String vehicleType = vehicleInfo[0];
                final String vehicleMake = vehicleInfo[1];
                final String vehicleYear = vehicleInfo[2];
                final String vehicleModle = vehicleInfo[3];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      // Get.to(() => CreateRequestPage(offersModel: offersModel));
                    },
                    child: Card(
                      color: userController.isDark
                          ? Colors.blueGrey.shade700
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VehicleDetailsRequest(
                              userController: userController,
                              vehicleType: vehicleType,
                              vehicleMake: vehicleMake,
                              vehicleYear: vehicleYear,
                              vehicleModle: vehicleModle,
                              offersModel: offersModel),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<List<OffersReceivedModel>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('offersReceived')
                                      .where('offerId',
                                          isEqualTo: offersModel.offerId)
                                      .snapshots()
                                      .map((event) => event.docs
                                          .map((e) =>
                                              OffersReceivedModel.fromJson(e))
                                          .toList()),
                                  builder: (context,
                                      AsyncSnapshot<List<OffersReceivedModel>>
                                          snapshots) {
                                    List<OffersReceivedModel>
                                        offersReceivedModel =
                                        snapshots.data ?? [];
                                    if (offersReceivedModel.isEmpty) {
                                      return Text(
                                        'Deleted',
                                      );
                                    }
                                    return ElevatedButton(
                                      onPressed: () {
                                        Get.to(() => InActiveOffersSeeker(
                                              offersModel: offersModel,
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          elevation: 0.0,
                                          fixedSize: Size(Get.width * 0.8, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          )),
                                      child: Text(
                                        '${offersReceivedModel.length} Offers',
                                        style: TextStyle(
                                            color: userController.isDark
                                                ? primaryColor
                                                : Colors.white),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }
}

class ActiveOffers extends StatelessWidget {
  const ActiveOffers({
    super.key,
    required this.offersPosted,
    required this.userController,
  });

  final List<OffersModel> offersPosted;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListView.builder(
              itemCount: offersPosted.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                OffersModel offersModel = offersPosted[index];

                return VehicleOwnerRequestWidget(
                    offersModel: offersModel, offersReceivedModel: null);
              }),
          const SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }
}
