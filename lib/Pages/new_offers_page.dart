// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';

import 'package:vehype/Widgets/service_request_widget.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';

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
    if (userModel.services.isEmpty) {
      return SelectYourServices();
    }
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
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
        itemBuilder: (context, index) {
          OffersModel offersModel = newOffers[index];

          return ServiceRequestWidget(
            offersModel: offersModel,
          );
        });
  }
}

class SelectYourServices extends StatelessWidget {
  const SelectYourServices({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    // height: Get.height * 0.06,
                    ),
                // Padding(
                //   padding: EdgeInsets.only(
                //     left: 10,
                //     top: 40,
                //     right: 10,
                //   ),
                //   child: Text(
                //     'Welcome to VEHYPE',
                //     textAlign: TextAlign.start,
                //     style: TextStyle(
                //         fontFamily: 'Avenir',
                //         fontWeight: FontWeight.w800,
                //         fontSize: 18,
                //         color: userController.isDark
                //             ? Colors.white
                //             : primaryColor),
                //   ),
                // ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      top: 10,
                      bottom: 10,
                      right: 10,
                    ),
                    child: Text(
                      'Select your services to receive offers',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 12, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (Service service in getServices())
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    userController.selectServices(service.name);
                                    // appProvider.selectPrefs(pref);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                            activeColor: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                            checkColor: userController.isDark
                                                ? Colors.green
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            value: userController
                                                .selectedServices
                                                .contains(service.name),
                                            onChanged: (s) {
                                              // appProvider.selectPrefs(pref);
                                              userController
                                                  .selectServices(service.name);
                                            }),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      SvgPicture.asset(service.image,
                                          height: 40,
                                          width: 40,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        service.name,
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.1,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: userController.selectedServices.isEmpty
          ? null
          : ElevatedButton(
              onPressed: userController.selectedServices.isEmpty
                  ? null
                  : () async {
                      Get.dialog(const LoadingDialog(),
                          barrierDismissible: false);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userModel.userId)
                          .update({
                        'services': FieldValue.arrayUnion(
                            userController.selectedServices),
                      });
                      userController.selectedServices = [];

                      Get.close(1);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  maximumSize: Size(Get.width * 0.8, 50),
                  minimumSize: Size(Get.width * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              child: Text(
                'Save',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 17,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w700,
                ),
              )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
