import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/owner_offers_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/offers_model.dart';
import 'loading_dialog.dart';

class OwnerIgnoreOfferConfirmationWidget extends StatelessWidget {
  const OwnerIgnoreOfferConfirmationWidget({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.offersReceivedModel,
  });

  final UserController userController;
  final OffersReceivedModel offersReceivedModel;
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
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Get.close(1);
                      Get.dialog(LoadingDialog(), barrierDismissible: false);
                      await OwnerOffersController()
                          .ignoreOffer(offersModel, offersReceivedModel);
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: userController.userModel!.userId,
                          senderId: userController.userModel!.userId,

                          checkByList: offersModel.checkByList,
                          isAdd: false,
                          offersReceived: offersReceivedModel.id,
                          notificationTitle: '',
                          notificationSubtitle: '');
                      ChatModel? chatModel = await ChatController().getChat(
                          userController.userModel!.userId,
                          offersModel.ownerId,
                          offersModel.offerId);
                      if (chatModel != null) {
                        ChatController().updateChatToClose(chatModel.id,
                            'The offer was declined by ${userController.userModel!.name}.');
                      }
                      Get.close(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      maximumSize: Size(Get.width * 0.6, 50),
                      minimumSize: Size(Get.width * 0.6, 50),
                    ),
                    child: Text(
                      'Confirm Ignore',
                      style: TextStyle(
                        fontSize: 16,
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
                            fontSize: 16,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
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
