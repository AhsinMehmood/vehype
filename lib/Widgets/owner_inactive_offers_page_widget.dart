import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/owner_request_widget.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_provider.dart';
import '../Models/garage_model.dart';

class OwnerInactiveOffersPageWidget extends StatelessWidget {
  final List<OffersModel> inActiveOffers;
  const OwnerInactiveOffersPageWidget(
      {super.key, required this.inActiveOffers});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    if (inActiveOffers.isEmpty) {
      return Center(
        child: Text(
          'No History Yet!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
        itemCount: inActiveOffers.length,
        padding: const EdgeInsets.only(top: 15, bottom: 80),
        // shrinkWrap: true,
        itemBuilder: (context, index) {
          // print( + ' Job id');/
          return inActiveOffers[index].offerReceivedIdJob != 'nothing'
              ? StreamBuilder<OffersReceivedModel>(
                  stream: FirebaseFirestore.instance
                      .collection('offersReceived')
                      .doc(inActiveOffers[index].offerReceivedIdJob)
                      .snapshots()
                      .map((convert) => OffersReceivedModel.fromJson(convert)),
                  builder:
                      (context, AsyncSnapshot<OffersReceivedModel> snapshot) {
                    OffersReceivedModel? offersReceivedModel = snapshot.data;

                    return StreamBuilder<GarageModel>(
                        stream: FirebaseFirestore.instance
                            .collection('garages')
                            .doc(inActiveOffers[index].garageId)
                            .snapshots()
                            .map((cc) => GarageModel.fromJson(cc)),
                        builder: (context, garasnap) {
                          if (garasnap.hasData && garasnap.data != null) {
                            GarageModel garageModel = garasnap.data!;
                            return OwnerRequestWidget(
                              offersModel: inActiveOffers[index],
                              garageModel: garageModel,
                              offersReceivedModel: offersReceivedModel,
                            );
                          } else {
                            return OwnerRequestWidget(
                              offersModel: inActiveOffers[index],
                              garageModel: GarageModel(
                                  createdAt: DateTime.now().toIso8601String(),
                                  ownerId: 'ownerId',
                                  submodel: 'submodel',
                                  isCustomModel: false,
                                  isCustomMake: false,
                                  title: 'title',
                                  imageUrl: defaultImage,
                                  bodyStyle: 'Truck',
                                  make: 'make',
                                  year: 'year',
                                  model: 'model',
                                  vin: 'vin',
                                  garageId: 'garageId'),
                              offersReceivedModel: offersReceivedModel,
                            );
                          }
                        });
                  })
              : StreamBuilder<GarageModel>(
                  stream: FirebaseFirestore.instance
                      .collection('garages')
                      .doc(inActiveOffers[index].garageId)
                      .snapshots()
                      .map((cc) => GarageModel.fromJson(cc)),
                  builder: (context, garasnap) {
                    if (garasnap.hasData && garasnap.data != null) {
                      GarageModel garageModel = garasnap.data!;
                      return OwnerRequestWidget(
                        offersModel: inActiveOffers[index],
                        garageModel: garageModel,
                        offersReceivedModel: null,
                      );
                    } else {
                      return OwnerRequestWidget(
                        offersModel: inActiveOffers[index],
                        garageModel: GarageModel(
                            createdAt: DateTime.now().toIso8601String(),
                            isCustomMake: false,
                            ownerId: 'ownerId',
                            submodel: 'submodel',
                            isCustomModel: false,
                            title: 'title',
                            imageUrl: defaultImage,
                            bodyStyle: 'Truck',
                            make: 'make',
                            year: 'year',
                            model: 'model',
                            vin: 'vin',
                            garageId: 'garageId'),
                        offersReceivedModel: null,
                      );
                    }
                  });
        });
    //  SafeArea(
    //           child: StreamBuilder<List<OffersModel>>(
    //               stream: GarageController()
    //                   .getRepairOffersPostedInactive(userModel.userId),
    //               builder: (context, AsyncSnapshot<List<OffersModel>> snap) {

    //                 List<OffersModel> offersPosted = snap.data ?? [];
    //                 List<OffersModel> filterOffers = [];

    //               }),
    //         ),
  }
}
