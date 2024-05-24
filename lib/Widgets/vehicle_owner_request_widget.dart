// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/received_offers_seeker.dart';
import 'package:vehype/Widgets/offer_request_details.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../const.dart';
import 'request_vehicle_details.dart';

class VehicleOwnerRequestWidget extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel? offersReceivedModel;
  const VehicleOwnerRequestWidget(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Get.to(() => CreateRequestPage(offersModel: offersModel));
        },
        child: Card(
          color:
              userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: VehicleDetailsRequest(
                    userController: userController,
                    vehicleType: vehicleType,
                    vehicleMake: vehicleMake,
                    vehicleYear: vehicleYear,
                    vehicleModle: vehicleModle,
                    offersModel: offersModel),
              ),
              if (offersReceivedModel != null)
                OfferRequestDetails(
                    userController: userController,
                    offersReceivedModel: offersReceivedModel!),
              if (offersReceivedModel == null)
                ActiveOfferDetailsButtonsVehicleOwner(
                    offersModel: offersModel, userController: userController),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveOfferDetailsButtonsVehicleOwner extends StatelessWidget {
  const ActiveOfferDetailsButtonsVehicleOwner({
    super.key,
    required this.offersModel,
    required this.userController,
  });

  final OffersModel offersModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OffersReceivedModel>>(
        stream: FirebaseFirestore.instance
            .collection('offersReceived')
            .where('offerId', isEqualTo: offersModel.offerId)
            // .where('status', isNotEqualTo: 'Cancelled')
            .snapshots()
            .map((event) => event.docs
                .map((e) => OffersReceivedModel.fromJson(e))
                .toList()),
        builder: (context, AsyncSnapshot<List<OffersReceivedModel>> snapshots) {
          List<OffersReceivedModel> offersReceivedModel = snapshots.data ?? [];
          List<OffersReceivedModel> filterReceivedOffers = offersReceivedModel
              .where((element) => element.status != 'Cancelled')
              .toList();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(() => ReceivedOffersSeeker(
                        offersModel: offersModel,
                      ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                    elevation: 0.0,
                    fixedSize: Size(
                        filterReceivedOffers.isNotEmpty
                            ? Get.width * 0.8
                            : Get.width * 0.4,
                        40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    )),
                child: Text(
                  '${filterReceivedOffers.length} Offers',
                  style: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white),
                ),
              ),
              if (filterReceivedOffers.isEmpty)
                const SizedBox(
                  width: 10,
                ),
              if (filterReceivedOffers.isEmpty)
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        context: context,
                        backgroundColor:
                            userController.isDark ? primaryColor : Colors.white,
                        builder: (context) {
                          return CancelRequestWidget(
                              userController: userController,
                              offersModel: offersModel);
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0.0,
                      fixedSize: Size(Get.width * 0.4, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      )),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        });
  }
}

class CancelRequestWidget extends StatelessWidget {
  const CancelRequestWidget({
    super.key,
    required this.userController,
    required this.offersModel,
  });

  final UserController userController;
  final OffersModel offersModel;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        builder: (s) {
          return Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.close(1);
                      await FirebaseFirestore.instance
                          .collection('offers')
                          .doc(offersModel.offerId)
                          .update({
                        'status': 'inactive',
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 1.0,
                      maximumSize: Size(Get.width * 0.6, 50),
                      minimumSize: Size(Get.width * 0.6, 50),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Avenir',
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Get.close(1);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }
}
