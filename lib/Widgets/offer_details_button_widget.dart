// ignore_for_file: prefer_const_constructors

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';
import '../Pages/inactive_offers_seeker.dart';
import '../Pages/message_page.dart';
import '../Pages/repair_page.dart';
import 'loading_dialog.dart';

class OfferDetailsButtonWidget extends StatelessWidget {
  final OffersReceivedModel offersReceivedModel;
  final UserModel userModel;
  final OffersModel offersModel;

  final UserModel postedByDetails;
  const OfferDetailsButtonWidget(
      {super.key,
      required this.offersReceivedModel,
      required this.postedByDetails,
      required this.userModel,
      required this.offersModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (offersReceivedModel.status == 'Cancelled' &&
                offersReceivedModel.cancelBy == 'provider' &&
                offersReceivedModel.ratingTwo == 0.0)
              _getButton(Colors.white, () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.8,
                      minHeight: Get.height * 0.8,
                      minWidth: Get.width,
                    ),
                    isScrollControlled: true,
                    builder: (contex) {
                      return RatingSheet2(
                          offersReceivedModel: offersReceivedModel,
                          offersModel: offersModel,
                          isDark: userController.isDark);
                    });
              }, 'Give Rating', context),
            if (offersReceivedModel.status == 'Completed' &&
                offersReceivedModel.ratingOne == 0.0)
              _getButtonFull(Colors.white, () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.8,
                      minHeight: Get.height * 0.8,
                      minWidth: Get.width,
                    ),
                    isScrollControlled: true,
                    builder: (contex) {
                      return RatingSheet2(
                          offersReceivedModel: offersReceivedModel,
                          offersModel: offersModel,
                          isDark: userController.isDark);
                    });
              }, 'Give Rating', context),
            if (offersReceivedModel.status == 'Completed' &&
                offersReceivedModel.ratingOne != 0.0)
              RatingBarIndicator(
                rating: offersReceivedModel.ratingOne,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            // else
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        if (offersReceivedModel.status == 'Upcoming')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  OffersController().chatWithOffer(userModel, postedByDetails,
                      offersModel, offersReceivedModel);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    'assets/messages.svg',
                    height: 34,
                    width: 34,
                    color: userController.isDark ? primaryColor : Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  DocumentSnapshot<Map<String, dynamic>> snap =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(offersReceivedModel.ownerId)
                          .get();
                  UserModel userModel = UserModel.fromJson(snap);
                  Event event = Event(
                    title: userModel.name,
                    description: offersModel.vehicleId,
                    // location: 'Event location',
                    startDate:
                        DateTime.parse(offersReceivedModel.startDate).toLocal(),
                    endDate:
                        DateTime.parse(offersReceivedModel.endDate).toLocal(),
                  );
                  Add2Calendar.addEvent2Cal(event);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.blueGrey,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.dialog(LoadingDialog(), barrierDismissible: false);

                  await FirebaseFirestore.instance
                      .collection('offersReceived')
                      .doc(offersReceivedModel.id)
                      .update({
                    'status': 'Completed',
                    // 'cancelBy': 'owner',
                  });
                  await FirebaseFirestore.instance
                      .collection('offers')
                      .doc(offersReceivedModel.offerId)
                      .update({
                    'status': 'inactive',
                  });
                  UserController().changeNotiOffers(3, true,
                      offersReceivedModel.offerBy, offersModel.offerId);

                  Get.close(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 1.0,
                  maximumSize: Size(Get.width * 0.4, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  minimumSize: Size(Get.width * 0.4, 55),
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Avenir',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(
          height: 15,
        ),
        if (offersReceivedModel.status == 'Upcoming')
          Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              _getButton(Colors.white, () async {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    context: context,
                    backgroundColor:
                        userController.isDark ? primaryColor : Colors.white,
                    builder: (context) {
                      return BottomSheet(
                          onClosing: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          builder: (s) {
                            return Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: userController.isDark
                                    ? primaryColor
                                    : Colors.white,
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
                                      'Are you sure? You won\'t be able to revert this action.',
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
                                        if (offersReceivedModel.ownerId ==
                                            userModel.userId) {
                                          OffersController().cancelOfferByOwner(
                                              offersReceivedModel, userModel);
                                          UserController().changeNotiOffers(
                                              4,
                                              true,
                                              offersReceivedModel.offerBy,
                                              offersModel.offerId);
                                        } else {
                                          OffersController()
                                              .cancelOfferByProvider(
                                                  offersReceivedModel,
                                                  userModel);
                                          UserController().changeNotiOffers(
                                              6,
                                              true,
                                              offersReceivedModel.ownerId,
                                              offersModel.offerId);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 1.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        maximumSize: Size(Get.width * 0.8, 50),
                                        minimumSize: Size(Get.width * 0.8, 50),
                                      ),
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Avenir',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
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
                                          fontSize: 16,
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
                    });
              }, 'Cancel', context),
            ],
          ),
      ],
    );
  }

  ElevatedButton _getButton(
      Color textColor, Function? onTap, String text, BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return ElevatedButton(
      onPressed: onTap == null ? null : () => onTap(),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          elevation: 0.0,
          fixedSize: Size(Get.width * 0.8, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  ElevatedButton _getButtonFull(
      Color textColor, Function? onTap, String text, BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return ElevatedButton(
      onPressed: onTap == null ? null : () => onTap(),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          fixedSize: Size(Get.width * 0.85, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
