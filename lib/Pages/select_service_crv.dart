// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/garage_model.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import 'select_vehicle_crv.dart';

class SelectServiceCreateVehicle extends StatelessWidget {
  final OffersModel? offersModel;
  final GarageModel? garageModel;
  const SelectServiceCreateVehicle(
      {super.key, required this.offersModel, this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return WillPopScope(
      onWillPop: () async {
        garageController.disposeController();
        return true;
      },
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                garageController.disposeController();

                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          title: Text(
            'Select Service',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                                      garageController
                                          .selectIssue(service.name);
                                      // appProvider.selectPrefs(pref);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              value: garageController
                                                      .selectedIssue ==
                                                  service.name,
                                              onChanged: (s) {
                                                // appProvider.selectPrefs(pref);
                                                garageController
                                                    .selectIssue(service.name);
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
                                            fontSize: 17,
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
        floatingActionButton: garageController.selectedIssue == ''
            ? null
            : ElevatedButton(
                onPressed: () async {
                  if (garageModel == null) {
                    Get.to(() => SelectVehicleCreateRequest(
                          offersModel: offersModel,
                        ));
                  } else {
                    garageController.selectVehicle(
                        '${garageModel!.bodyStyle}, ${garageModel!.make}, ${garageModel!.year}, ${garageModel!.model}',
                        garageModel!.imageOne,
                        garageModel!.garageId);
                    Get.to(() => CreateRequestPage(
                          offersModel: offersModel,
                        ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                    maximumSize: Size(Get.width * 0.8, 60),
                    minimumSize: Size(Get.width * 0.8, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    )),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 20,
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w800,
                  ),
                )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
