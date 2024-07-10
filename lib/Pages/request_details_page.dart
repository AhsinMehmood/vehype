import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';

import '../Controllers/user_controller.dart';
import '../const.dart';

class RequestDetailsPage extends StatelessWidget {
  final OffersModel offersModel;

  const RequestDetailsPage({super.key, required this.offersModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
                onPressed: () {
                  Get.to(() => CreateRequestPage(offersModel: offersModel));
                },
                icon: Icon(
                  Icons.edit,
                  color: userController.isDark ? Colors.white : primaryColor,
                )),
          )
        ],
        leading: IconButton(
            onPressed: () {
              // garageController.disposeController();

              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Request Details',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: VehicleDetailsRequest(
              userController: userController,
              vehicleType: vehicleType,
              vehicleMake: vehicleMake,
              vehicleYear: vehicleYear,
              vehicleModle: vehicleModle,
              offersModel: offersModel),
        ),
      ),
    );
  }
}
