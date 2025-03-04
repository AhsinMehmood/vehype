// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Pages/Repair%20History/vehicle_based_repair_history_page.dart';
import 'package:vehype/Pages/add_vehicle.dart';
import 'package:vehype/Pages/vehicle_request_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Models/user_model.dart';
import 'choose_account_type.dart';
import 'create_request_page.dart';
// import 'select_service_crv.dart';

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
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Get.to(() => AddVehicle(
                garageModel: null,
              ));
        },
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: () async {
                              final GarageController garageController =
                                  Provider.of<GarageController>(context,
                                      listen: false);
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              await garageController.initVehicle(garageModel);
                              Get.close(1);
                              Get.to(
                                  () => AddVehicle(garageModel: garageModel));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                  border: Border.all(
                                    color: userController.isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : primaryColor.withOpacity(0.3),
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: Get.width,
                                    height: 220,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: garageModel.imageUrl,

                                            fit: BoxFit.cover,
                                            width: Get.width,
                                            height: 220,
                                            //cancelToken: cancellationToken,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                Get.to(() => CreateRequestPage(
                                                      offersModel: null,
                                                      garageModel: garageModel,
                                                    ));
                                              },
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                backgroundColor:
                                                    userController.isDark
                                                        ? Colors.white
                                                        : primaryColor,
                                              ),
                                              child: Text(
                                                'Request a Service',
                                                style: TextStyle(
                                                  color: userController.isDark
                                                      ? primaryColor
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                garageModel.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: userController.isDark
                                                      ? Colors.white
                                                      : primaryColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (garageModel.submodel != '')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  garageModel.submodel,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: userController.isDark
                                                        ? Colors.white
                                                        : primaryColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (garageModel.submodel != '')
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        Row(
                                          children: [
                                            // SvgPicture.asset(
                                            //   getVehicleType()
                                            //       .firstWhere((dd) =>
                                            //           dd.title ==
                                            //           garageModel.bodyStyle)
                                            //       .icon,
                                            //   color: userController.isDark
                                            //       ? Colors.white
                                            //       : primaryColor,
                                            // ),
                                            // const SizedBox(
                                            //   width: 8,
                                            // ),
                                            Text(
                                              garageModel.bodyStyle,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: Size(Get.width * 0.44, 45),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          elevation: 0.0,
                                          backgroundColor: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                        onPressed: () {
                                          Get.to(() => VehicleRequestsPage(
                                              garageModel: garageModel));
                                        },
                                        child: Text(
                                          'My Requests',
                                          style: TextStyle(
                                              color: userController.isDark
                                                  ? primaryColor
                                                  : Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Get.to(() =>
                                              VehicleBasedRepairHistoryPage(
                                                  garageModel: garageModel));
                                        },
                                        child: Container(
                                          height: 45,
                                          width: Get.width * 0.44,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: userController.isDark
                                                  ? primaryColor
                                                  : Colors.white,
                                              border: Border.all(
                                                color: userController.isDark
                                                
                                                    ? Colors.white
                                                    : primaryColor,
                                              )),
                                          child: Center(
                                            child: Text(
                                              'Repair History',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                  // ElevatedButton(
                                  //   style: ElevatedButton.styleFrom(
                                  //     fixedSize: Size(Get.width * 0.7, 45),
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(12),
                                  //     ),
                                  //     elevation: 0.0,
                                  //     backgroundColor: userController.isDark
                                  //         ? Colors.white
                                  //         : primaryColor,
                                  //   ),
                                  //   onPressed: () {
                                  //     Get.to(() =>
                                  //         AddVehicle(garageModel: garageModel));
                                  //   },
                                  //   child: Text(
                                  //     'Edit Vehicle',
                                  //     style: TextStyle(
                                  //       color: userController.isDark
                                  //           ? primaryColor
                                  //           : Colors.white,
                                  //     ),
                                  //   ),
                                  // ),
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
