import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/garage_model.dart';
import '../Models/offers_model.dart';
import 'loading_dialog.dart';

class OwnerAcceptOfferConfirmation extends StatelessWidget {
  const OwnerAcceptOfferConfirmation({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.userModel,
    required this.chatId,
    required this.garageModel,
    required this.userController,
  });

  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;
  final UserModel userModel;
  final String? chatId;
  final GarageModel garageModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        builder: (s) {
          return Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Are You Sure You Want to Accept This Offer?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersReceivedModel.offerBy)
                              .get();
                      if (DateTime.parse(offersReceivedModel.startDate)
                          .isBefore(DateTime.now().toUtc())) {
                        toastification.show(
                            context: context,
                            title: Text(
                                'Offer Time Expired: You can ask ${UserModel.fromJson(offerByQuery).name} to update the offer.'));
                        return;
                      }
                      Get.close(1);

                      Get.dialog(LoadingDialog(), barrierDismissible: false);

                      OffersController().acceptOffer(
                          offersReceivedModel,
                          offersModel,
                          userModel,
                          UserModel.fromJson(offerByQuery),
                          chatId,
                          garageModel);

                      NotificationController().sendNotification(
                          userTokens: [
                            UserModel.fromJson(offerByQuery).pushToken
                          ],
                          offerId: offersModel.offerId,
                          requestId: offersReceivedModel.id,
                          title: 'Good News: Offer Accepted',
                          subtitle:
                              '${userController.userModel!.name} has accepted your offer. Tap here to review.');

                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: UserModel.fromJson(offerByQuery).userId,
                          senderId: userController.userModel!.userId,
                          isAdd: true,
                          offersReceived: offersReceivedModel.id,
                          checkByList: offersModel.checkByList,
                          notificationTitle:
                              '${userController.userModel!.name} has accepted your offer',
                          notificationSubtitle:
                              '${userController.userModel!.name} has accepted your offer. Tap here to review.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      maximumSize: Size(Get.width * 0.6, 50),
                      minimumSize: Size(Get.width * 0.6, 50),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        fontWeight: FontWeight.w700,
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
                    child: Container(
                      height: 50,
                      width: Get.width * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
