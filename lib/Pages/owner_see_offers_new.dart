import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/owner_offer_received_new_widget.dart';

import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/garage_model.dart';
import 'full_image_view_page.dart';

class OwnerSeeOffersNew extends StatelessWidget {
  final List<OffersReceivedModel> offersReceived;
  final OffersModel offersModel;
  final GarageModel garageModel;
  const OwnerSeeOffersNew(
      {super.key,
      required this.offersReceived,
      required this.offersModel,
      required this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    String vehicleId = offersModel.vehicleId;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Received Offers',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                InkWell(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: const EdgeInsets.all(0),
                    color: userController.isDark ? primaryColor : Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (offersModel.imageOne != '')
                                InkWell(
                                  onTap: () {
                                    Get.to(() => FullImagePageView(
                                          urls: [offersModel.imageOne],
                                          currentIndex: 0,
                                        ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: offersModel.imageOne,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicleId.trim(),
                                      maxLines: 2,
                                      style: TextStyle(
                                        // color: Colors.black,
                                        fontFamily: 'Avenir',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                            getServices()
                                                .firstWhere((element) =>
                                                    element.name ==
                                                    offersModel.issue)
                                                .image,
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                            height: 25,
                                            width: 25),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            // color: Colors.black,
                                            fontFamily: 'Avenir',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          offersModel.issue,
                                          style: TextStyle(
                                            // color: Colors.black,
                                            fontFamily: 'Avenir',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
                child: StreamBuilder<List<OffersReceivedModel>>(
                    initialData: offersReceived,
                    stream: FirebaseFirestore.instance
                        .collection('offersReceived')
                        .where('offerId', isEqualTo: offersModel.offerId)
                        .where('status', isNotEqualTo: 'ignore')
                        // .orderBy('createdAt', descending: true)
                        .snapshots()
                        .map((QuerySnapshot<Map<String, dynamic>> convert) =>
                            convert.docs
                                .map((DocumentSnapshot<Map<String, dynamic>>
                                        doc) =>
                                    OffersReceivedModel.fromJson(doc))
                                .toList()),
                    builder: (context,
                        AsyncSnapshot<List<OffersReceivedModel>> snapshot) {
                      List<OffersReceivedModel> offersReceived =
                          snapshot.data ?? [];

                      return offersReceived.isEmpty
                          ? Center(
                              child: Text(
                                'No Offers to See',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: offersReceived.length,
                              itemBuilder: (context, index) {
                                OffersReceivedModel offersReceivedModel =
                                    offersReceived[index];
                                return OwnerOfferReceivedNewWidget(
                                    offersModel: offersModel,
                                    garageModel: garageModel,
                                    offersReceivedModel: offersReceivedModel);
                              });
                    }))
          ],
        ),
      ),
    );
  }
}
