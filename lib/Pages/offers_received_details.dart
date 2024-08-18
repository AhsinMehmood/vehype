// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';
import 'package:vehype/Models/chat_model.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/garage_controller.dart';
import '../Controllers/user_controller.dart';

import '../Models/user_model.dart';
import 'comments_page.dart';

import 'message_page.dart';

class OfferReceivedDetails extends StatefulWidget {
  final OffersModel offersModel;
  final bool isChat;
  const OfferReceivedDetails(
      {super.key, required this.offersModel, this.isChat = false});

  @override
  State<OfferReceivedDetails> createState() => _OfferReceivedDetailsState();
}

class _OfferReceivedDetailsState extends State<OfferReceivedDetails> {
  PageController pageController = PageController();
  int currentInde = 0;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    List<String> vehicleInfo = widget.offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: widget.isChat
          ? null
          : AppBar(
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              elevation: 0.0,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: StreamBuilder<UserModel>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.offersModel.ownerId)
                .snapshots()
                .map((event) => UserModel.fromJson(event)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      height: Get.height * 0.4,
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                );
              }
              final UserModel ownerDetails = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: ExtendedImage.network(
                            ownerDetails.profileUrl,
                            width: 75,
                            height: 75,
                            fit: BoxFit.fill,
                            cache: true,
                            // border: Border.all(color: Colors.red, width: 1.0),
                            shape: BoxShape.circle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(200.0)),
                            //cancelToken: cancellationToken,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ownerDetails.name,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => CommentsPage(data: ownerDetails));
                              },
                              child: Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: ownerDetails.rating,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 25.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    ownerDetails.ratings.length.toString(),
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: VehicleDetailsRequest(
                          userController: userController,
                          vehicleType: vehicleType,
                          vehicleMake: vehicleMake,
                          vehicleYear: vehicleYear,
                          vehicleModle: vehicleModle,
                          offersModel: widget.offersModel),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isChat == false)
                          InkWell(
                            onTap: () async {},
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SvgPicture.asset(
                                  'assets/messages.svg',
                                  height: 34,
                                  width: 34,
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // applyToJob(userModel);
                            Get.to(
                              () => SelectDateAndPrice(
                                offersModel: widget.offersModel,
                                ownerModel: ownerDetails,
                                offersReceivedModel: null,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0.0,
                              fixedSize: Size(Get.width * 0.6, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              )),
                          child: Text(
                            'Create Offer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  // applyToJob(UserModel userModel) async {
  //   Get.dialog(LoadingDialog(), barrierDismissible: false);
  //   await FirebaseFirestore.instance
  //       .collection('offers')
  //       .doc(widget.offersModel.offerId)
  //       .update({
  //     'offersReceived': FieldValue.arrayUnion([userModel.userId]),
  //   });
  //   await FirebaseFirestore.instance
  //       .collection('offers')
  //       .doc(widget.offersModel.offerId)
  //       .collection('offersReceived')
  //       .add({
  //     'offerBy': userModel.userId,
  //     'offerAt': DateTime.now().toUtc().toIso8601String(),
  //     'status': 'pending',
  //   });
  //   Get.close(2);
  //   Get.showSnackbar(
  //     GetSnackBar(
  //       message: 'Submitted successfully.',
  //       duration: Duration(seconds: 3),
  //     ),
  //   );
  // }
}
