import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';

import '../Models/offers_model.dart';
import '../const.dart';
import 'owner_request_widget.dart';

class OwnerActiveOffers extends StatelessWidget {
  const OwnerActiveOffers({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    UserModel userModel = userController.userModel!;
    List<OffersModel> offersPosted = offersProvider.ownerOffers
        .where((offer) => offer.status == 'active')
        .toList();
    offersPosted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offersPosted.isEmpty) {
      return Center(
        child: Text(
          'Create a Request to Hire a Proffesional',
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
        itemCount: offersPosted.length,
        shrinkWrap: true,
        // shrinkWrap: true,
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 80, top: 15),
        itemBuilder: (context, index) {
          return StreamBuilder<GarageModel>(
              stream: FirebaseFirestore.instance
                  .collection('garages')
                  .doc(offersPosted[index].garageId)
                  .snapshots()
                  .map((cc) => GarageModel.fromJson(cc)),
              builder: (context, garasnap) {
                if (garasnap.hasData && garasnap.data != null) {
                  GarageModel garageModel = garasnap.data!;
                  return OwnerRequestWidget(
                    offersModel: offersPosted[index],
                    garageModel: garageModel,
                    // offersReceivedModel: null,
                  );
                } else {
                  return OwnerRequestWidget(
                    offersModel: offersPosted[index],
                    garageModel: GarageModel(
                        ownerId: 'ownerId',
                        createdAt: DateTime.now().toIso8601String(),
                        isCustomMake: false,
                        submodel: 'submodel',
                        title: 'title',
                        isCustomModel: false,
                        imageUrl: defaultImage,
                        bodyStyle: 'Truck',
                        make: 'make',
                        year: 'year',
                        model: 'model',
                        vin: 'vin',
                        garageId: 'garageId'),
                    // offersReceivedModel: offersReceivedModel,
                  );
                }
              });
        });
  }
}
