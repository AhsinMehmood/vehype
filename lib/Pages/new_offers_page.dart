// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/notification_controller.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/login_sheet.dart';
import 'package:vehype/Widgets/select_additional_services.dart';
import 'package:vehype/Widgets/select_services_widget.dart';
import 'package:vehype/Widgets/service_radius_widget.dart';

import 'package:vehype/Widgets/service_request_widget.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';
import '../Widgets/select_vehicle_type.dart';
import 'choose_account_type.dart';

class NewOffers extends StatelessWidget {
  const NewOffers({
    super.key,
    required this.userController,
    required this.userModel,
    required this.newOffers,
  });

  final UserController userController;
  final UserModel userModel;
  final List<OffersModel> newOffers;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;

    if (newOffers.isEmpty) {
      return Center(
        child: Text(
          'No Requests Yet',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
        itemCount: newOffers.length,
        // shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
        itemBuilder: (context, index) {
          OffersModel offersModel = newOffers[index];
          print(offersModel.vehicleType);
          return ServiceRequestWidget(
            offersModel: offersModel,
          );
        });
  }
}

class SelectYourServices extends StatefulWidget {
  final bool isPage;
  const SelectYourServices({super.key, this.isPage = false});

  @override
  State<SelectYourServices> createState() => _SelectYourServicesState();
}

class _SelectYourServicesState extends State<SelectYourServices> {
  @override
  void initState() {
    super.initState();
    final UserModel userModel =
        Provider.of<UserController>(context, listen: false).userModel!;
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    userController.selectedAdditionalServices = userModel.additionalServices;
    userController.selectedServices = userModel.services;
    userController.selectedVehicleTypesFilter = [];
    userController.selectedVehicleTypesFilter = userModel.vehicleTypes;
    userController.radiusMiles = userModel.radius.toDouble();
    setState(() {});
    // for (var element in userModel.vehicleTypes) {
    //   userController.selectVehicleTypesFilter(element);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Container(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    // height: Get.height * 0.06,
                    ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                      // left: 10,
                      top: 20,
                      bottom: 20,
                      // right: 10,
                    ),
                    child: Text(
                      'Set your Prefrences',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // fontFamily: 'Avenir',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    SelectServicesWidget(),
                    const SizedBox(
                      height: 10,
                    ),
                    SelectVehicleType(),
                    const SizedBox(
                      height: 10,
                    ),
                    SelectAdditionalServices(),
                    ServiceRadiusWidget(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
          onPressed: userController.selectedServices.isEmpty
              ? null
              : () async {
                  // if (userModel.email == 'No email set') {
                  //   Get.bottomSheet(LoginSheet());
                  //   return;
                  // }

                  Get.dialog(const LoadingDialog(), barrierDismissible: false);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userModel.userId)
                      .update({
                    'additionalServices':
                        userController.selectedAdditionalServices,
                    'services': userController.selectedServices,
                    'radius': userController.radiusMiles.toInt(),
                    'vehicleTypes': userController.selectedVehicleTypesFilter,
                  });
                  userController.selectedServices = [];
                  userController.selectedAdditionalServices = [];
                  if (widget.isPage) {
                    Get.close(1);
                  } else {
                    // await FirebaseFirestore.instance.collection('users')
                    List<UserModel> providers = [];

                    QuerySnapshot<Map<String, dynamic>> snapshot =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('accountType', isEqualTo: 'seeker')
                            // .where('services', arrayContains: issue)
                            // .where('status', isEqualTo: 'active')
                            .get();

                    for (QueryDocumentSnapshot<Map<String, dynamic>> element
                        in snapshot.docs) {
                      providers.add(UserModel.fromJson(element));
                    }
                    List<UserModel> filterProviders =
                        userController.filterProviders(providers, userModel.lat,
                            userModel.long, userController.radiusMiles);
                    List<String> userIds = [];
                    for (var element in filterProviders) {
                      userIds.add(element.userId);
                    }
                    NotificationController().sendNotificationNewProvider(
                        userIds: userIds,
                        providerId: userModel.userId,
                        requestId: '',
                        title: 'New Service 👨🏻‍🔧',
                        subtitle:
                            'Hi, new service just registered in your area. Check it out!!!');
                  }

                  Get.close(1);
                },
          style: ElevatedButton.styleFrom(
              backgroundColor:
                  userController.isDark ? Colors.white : primaryColor,
              maximumSize: Size(Get.width * 0.8, 50),
              minimumSize: Size(Get.width * 0.8, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              )),
          child: Text(
            'Save',
            style: TextStyle(
              color: userController.isDark ? primaryColor : Colors.white,
              fontSize: 17,
              // fontFamily: 'Avenir',
              fontWeight: FontWeight.w700,
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
