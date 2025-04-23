import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/vehicle_model.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/offers_model.dart';
import '../const.dart';

class VehicleBasedRequestHistory extends StatefulWidget {
  const VehicleBasedRequestHistory({super.key});

  @override
  State<VehicleBasedRequestHistory> createState() =>
      _VehicleBasedRequestHistoryState();
}

class _VehicleBasedRequestHistoryState
    extends State<VehicleBasedRequestHistory> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
   
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Repaired Vehicles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<VehicleOffersDetails>>(
        future: fetchCompletedOffersForVehicles(),
        builder: (context, AsyncSnapshot<List<VehicleOffersDetails>> snap) {
          if (snap.connectionState == ConnectionState.active) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<VehicleOffersDetails> completedOffersAndDetails =
              snap.data ?? [];
          if (completedOffersAndDetails.isEmpty) {
            return Center(
              child: Text('No Vehicle Repaired Yet!!!'),
            );
          }
          return ListView.builder(
              itemCount: completedOffersAndDetails.length,
              itemBuilder: (context, index) {
                GarageModel garageModel =
                    completedOffersAndDetails[index].garage;

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: () async {},
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: garageModel.imageUrl,

                                fit: BoxFit.cover,

                                //cancelToken: cancellationToken,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    //           dd.title == garageModel.bodyStyle)
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(Get.width * 0.9, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0.0,
                                  backgroundColor: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                                onPressed: () {
                                  
                                },
                                child: Text(
                                  'Requests History',
                                  style: TextStyle(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ),
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
              });
        },
      ),
    );
  }

  Future<List<VehicleOffersDetails>> fetchCompletedOffersForVehicles() async {
    final OffersProvider offersProvider =
        Provider.of<OffersProvider>(context, listen: false);

    // Filter completed offers
    List<OffersReceivedModel> completedOffers = offersProvider.offersReceived
        .where((offer) => offer.status == 'Completed')
        .toList();

    List<VehicleOffersDetails> vehicleOffersDetailsList = [];

    // Fetch completed offers from Firestore
    List<OffersModel> completedOfferModels = [];
    for (var completedOffer in completedOffers) {
      DocumentSnapshot<Map<String, dynamic>> offerSnapshot =
          await FirebaseFirestore.instance
              .collection('offers')
              .doc(completedOffer.offerId)
              .get();
      completedOfferModels.add(OffersModel.fromJson(offerSnapshot));
    }

    // Group offers by garage (vehicle)
    List<String> uniqueGarageIds = [];

    // Collect unique garageIds from completed offers
    for (var offer in completedOfferModels) {
      if (!uniqueGarageIds.contains(offer.garageId)) {
        uniqueGarageIds.add(offer.garageId);
      }
    }

    // Retrieve details for each unique garage
    for (var garageId in uniqueGarageIds) {
      // Fetch the garage details
      DocumentSnapshot<Map<String, dynamic>> garageSnapshot =
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .get();
      GarageModel garage = GarageModel.fromJson(garageSnapshot);

      // Get all completed offers associated with this garage
      List<OffersModel> garageCompletedOffers = completedOfferModels
          .where((offer) => offer.garageId == garageId)
          .toList();
      List<OffersReceivedModel> garageCompletedOffersReceived = completedOffers
          .where((offer) => garageCompletedOffers
              .any((test) => test.offerId == offer.offerId))
          .toList();

      // Create the VehicleOffersDetails object for this garage
      vehicleOffersDetailsList.add(
        VehicleOffersDetails(
          garage: garage,
          offerDetails: garageCompletedOffers, // No active offers needed
          offerReceivedDetails: garageCompletedOffersReceived,
        ),
      );
    }

    return vehicleOffersDetailsList;
  }
}

class VehicleOffersDetails {
  final GarageModel garage;
  final List<OffersReceivedModel> offerReceivedDetails;
  final List<OffersModel> offerDetails;

  VehicleOffersDetails({
    required this.garage,
    required this.offerReceivedDetails,
    required this.offerDetails,
  });
}
