// ignore_for_file: prefer_const_constructors

import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Pages/add_vehicle.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Pages/vehicle_request_page.dart';
import 'package:vehype/const.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Models/user_model.dart';
import 'choose_account_type.dart';
import 'full_image_view_page.dart';
import 'select_service_crv.dart';

class MyGarage extends StatelessWidget {
  const MyGarage({super.key});
  // final PageController imagePageController = PageController();

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        centerTitle: true,
        title: Text(
          'My Garage',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
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
                    color: userController.isDark ? primaryColor : Colors.white,
                  ),
                ),
              ),
            ));
          } else {
            Get.to(() => AddVehicle(
                  garageModel: null,
                ));
          }
        },
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: userController.isDark ? Colors.white : primaryColor,
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: userController.isDark ? primaryColor : Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<GarageModel>>(
                stream: GarageController().myVehicles(userModel.userId),
                builder: (context, AsyncSnapshot<List<GarageModel>> snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(
                          height: Get.height * 0.4,
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                  List<GarageModel> vehicles = snapshot.data ?? [];
                  if (vehicles.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: Get.height * 0.4,
                        ),
                        Center(
                          child: Text(
                            'No Vehicle Added',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                      itemCount: vehicles.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        GarageModel garageModel = vehicles[index];
                        final PageController imagePageController =
                            PageController();

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                  () => AddVehicle(garageModel: garageModel));
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
                                  if (garageModel.imageOne != '')
                                    SizedBox(
                                      width: Get.width,
                                      height: Get.width * 0.35,
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(() => FullImagePageView(
                                                urls: [garageModel.imageOne],
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: ExtendedImage.network(
                                            garageModel.imageOne,
                                            width: Get.width * 0.8,
                                            height: Get.width * 0.8,
                                            fit: BoxFit.cover,
                                            cache: true,
                                            // border: Border.all(color: Colors.red, width: 1.0),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            //cancelToken: cancellationToken,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              garageModel.bodyStyle,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.make,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.year,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.model,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              fixedSize:
                                                  Size(Get.width * 0.7, 45),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0.0,
                                              backgroundColor:
                                                  userController.isDark
                                                      ? Colors.white
                                                      : primaryColor,
                                            ),
                                            onPressed: () {
                                              Get.to(() => VehicleRequestsPage(
                                                  garageModel: garageModel));
                                            },
                                            child: Text(
                                              'View Requests',
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? primaryColor
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(Get.width * 0.7, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0.0,
                                      backgroundColor: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => CreateRequestPage(
                                          offersModel: null,
                                          garageModel: garageModel,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Create Request',
                                      style: TextStyle(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
