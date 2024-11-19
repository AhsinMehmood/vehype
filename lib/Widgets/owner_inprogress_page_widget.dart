import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';

import 'package:vehype/Widgets/owner_request_widget.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_provider.dart';
import '../Models/garage_model.dart';

class OwnerInprogressPageWidget extends StatelessWidget {
  const OwnerInprogressPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    final UserController userController = Provider.of<UserController>(context);

    final List<OffersModel> inProgressOffers = offersProvider.ownerOffers
        .where((offer) => offer.status == 'inProgress')
        .toList();
    inProgressOffers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (inProgressOffers.isEmpty) {
      return Center(
        child: Text(
          'No In Progress Offers Yet!',
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
        itemCount: inProgressOffers.length,
        padding: const EdgeInsets.only(top: 15, bottom: 80),
        itemBuilder: (context, index) {
          return StreamBuilder<OffersReceivedModel>(
              stream: FirebaseFirestore.instance
                  .collection('offersReceived')
                  .doc(inProgressOffers[index].offerReceivedIdJob)
                  .snapshots()
                  .map((convert) => OffersReceivedModel.fromJson(convert)),
              builder: (context, AsyncSnapshot<OffersReceivedModel> snapshot) {
                OffersReceivedModel? offersReceivedModel = snapshot.data;
                return StreamBuilder<GarageModel>(
                    stream: FirebaseFirestore.instance
                        .collection('garages')
                        .doc(inProgressOffers[index].garageId)
                        .snapshots()
                        .map((cc) => GarageModel.fromJson(cc)),
                    builder: (context, garasnap) {
                      if (garasnap.hasData && garasnap.data != null) {
                        GarageModel garageModel = garasnap.data!;
                        return OwnerRequestWidget(
                          offersModel: inProgressOffers[index],
                          garageModel: garageModel,
                          offersReceivedModel: offersReceivedModel,
                        );
                      } else {
                        return OwnerRequestWidget(
                          offersModel: inProgressOffers[index],
                          garageModel: GarageModel(
                              ownerId: 'ownerId',
                              submodel: 'submodel',
                              title: 'title',
                              isCustomMake: false,
                              isCustomModel: false,
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
              });
        });
  }
}
