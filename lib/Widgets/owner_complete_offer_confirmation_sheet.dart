import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/pdf_generator.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/garage_model.dart';
import '../Models/offers_model.dart';
import '../Pages/Invoice/review_share_invoice.dart';
import 'loading_dialog.dart';

class OwnerCompleteOfferConfirmationSheet extends StatelessWidget {
  const OwnerCompleteOfferConfirmationSheet({
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
                    'Are you sure you want to complete this request?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '\n\n\nPs. The service cannot make further changes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.close(1);

                      // Get.dialog(LoadingDialog(), barrierDismissible: false);

                      OffersController().completeOffer(
                        offersReceivedModel,
                      );

                      NotificationController().sendNotification(
                          userIds: [offersReceivedModel.offerBy],
                          offerId: offersModel.offerId,
                          requestId: offersReceivedModel.id,
                          title: 'Request Completed Successfully',
                          subtitle:
                              '${userController.userModel!.name} has marked the request as complete. Tap to review.');
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: offersReceivedModel.offerBy,
                          senderId: userController.userModel!.userId,
                          isAdd: true,
                          offersReceived: offersReceivedModel.id,
                          checkByList: offersModel.checkByList,
                          notificationTitle: 'Request Completed Successfully',
                          notificationSubtitle:
                              '${userController.userModel!.name} has marked the request as complete. Tap to review.');
                      ChatModel? chatModel = await ChatController().getChat(
                          userController.userModel!.userId,
                          offersModel.ownerId,
                          offersModel.offerId);
                      if (chatModel != null) {
                        ChatController().updateChatToClose(chatModel.id,
                            '${userController.userModel!.name} has marked the request as completed.');
                      }
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
