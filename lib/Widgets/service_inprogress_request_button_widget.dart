import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Pages/service_request_details.dart';
import 'package:vehype/Widgets/calenders_list.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/Widgets/service_cancel_request_confirmation_sheet.dart';

import '../Models/chat_model.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../Pages/message_page.dart';
import '../const.dart';
import 'loading_dialog.dart';

class ServiceInprogressRequestPageButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final GarageModel garageModel;
  final OffersReceivedModel offersReceivedModel;

  const ServiceInprogressRequestPageButtonWidget(
      {super.key,
      required this.offersModel,
      required this.garageModel,
      this.chatId,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    // final CalendarPlugin myPlugin = CalendarPlugin();/

    return Container(
      height: 80,
      width: Get.width,
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        border: Border(
            top: BorderSide(
          color: userController.isDark
              ? Colors.white.withOpacity(0.2)
              : primaryColor.withOpacity(0.2),
        )),
      ),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        builder: (s) {
                          return ServiceCancelRequestConfirmationSheet(
                              userController: userController,
                              offersModel: offersModel,
                              offersReceivedModel: offersReceivedModel);
                        });
                  });
            },
            child: Container(
              height: 50,
              width: chatId != null ? Get.width * 0.35 : Get.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cancel',
                    style: TextStyle(
                      // color: userController.isDark ? Colors.white : Colors.white,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (chatId == null)
            InkWell(
              onTap: () async {
                Get.dialog(LoadingDialog(), barrierDismissible: false);
                DocumentSnapshot<Map<String, dynamic>> snap =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(offersReceivedModel.ownerId)
                        .get();
                UserModel ownerDetails = UserModel.fromJson(snap);
                ChatModel? chatModel = await ChatController().getChat(
                    userController.userModel!.userId,
                    ownerDetails.userId,
                    offersModel.offerId);
                if (chatModel == null) {
                  await ChatController().createChat(
                      userController.userModel!,
                      ownerDetails,
                      offersReceivedModel.id,
                      offersModel,
                      'New Message',
                      '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                      'chat');
                  ChatModel? newchat = await ChatController().getChat(
                      userController.userModel!.userId,
                      ownerDetails.userId,
                      offersModel.offerId);
                  Get.close(1);
                  Get.to(() => MessagePage(
                        chatModel: newchat!,
                        offersModel: offersModel,
                        garageModel: garageModel,
                        secondUser: ownerDetails,
                      ));
                } else {
                  await ChatController().updateChatRequestId(
                      chatModel.id, offersReceivedModel.id);
                  Get.close(1);

                  Get.to(() => MessagePage(
                        chatModel: chatModel,
                        secondUser: ownerDetails,
                        garageModel: garageModel,
                        offersModel: offersModel,
                      ));
                }
              },
              child: Container(
                height: 50,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/messenger.png',
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Chat',
                      style: TextStyle(
                        // color: userController.isDark ? Colors.white : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              Get.dialog(LoadingDialog(), barrierDismissible: false);
              DocumentSnapshot<Map<String, dynamic>> snap =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(offersReceivedModel.ownerId)
                      .get();
              UserModel ownerDetails = UserModel.fromJson(snap);
              Get.close(1);
              Get.to(() => SelectDateAndPrice(
                  isUpdateInvoice: true,
                  offersModel: offersModel,
                  garageModel: garageModel,
                  ownerModel: ownerDetails,
                  offersReceivedModel: offersReceivedModel));
            },
            child: Container(
              height: 50,
              width: chatId != null ? Get.width * 0.45 : Get.width * 0.36,
              decoration: BoxDecoration(
                color: userController.isDark ? Colors.white : primaryColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              ),
              child: Center(
                child: Text(
                  'Update Invoice',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceInprogressRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;
  final GarageModel garageModel;
  const ServiceInprogressRequestButtonWidget(
      {super.key,
      required this.offersModel,
      required this.garageModel,
      this.chatId,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      height: 80,
      width: Get.width,
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        border: Border(
            top: BorderSide(
          color: userController.isDark
              ? Colors.white.withOpacity(0.2)
              : primaryColor.withOpacity(0.2),
        )),
      ),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              OffersController().updateNotificationForOffers(
                  offerId: offersModel.offerId,
                  userId: userController.userModel!.userId,
                  offersReceived: offersReceivedModel.id,
                  checkByList: offersModel.checkByList,
                  senderId: userController.userModel!.userId,
                  isAdd: false,
                  notificationTitle: '',
                  notificationSubtitle: '');
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        builder: (s) {
                          return ServiceCancelRequestConfirmationSheet(
                              userController: userController,
                              offersModel: offersModel,
                              offersReceivedModel: offersReceivedModel);
                        });
                  });
            },
            child: Container(
              height: 50,
              width: chatId != null ? Get.width * 0.35 : Get.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cancel',
                    style: TextStyle(
                      // color: userController.isDark ? Colors.white : Colors.white,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (chatId == null)
            InkWell(
              onTap: () async {
                Get.dialog(LoadingDialog(), barrierDismissible: false);
                DocumentSnapshot<Map<String, dynamic>> snap =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(offersReceivedModel.ownerId)
                        .get();
                UserModel ownerDetails = UserModel.fromJson(snap);
                ChatModel? chatModel = await ChatController().getChat(
                    userController.userModel!.userId,
                    ownerDetails.userId,
                    offersModel.offerId);
                if (chatModel == null) {
                  await ChatController().createChat(
                      userController.userModel!,
                      ownerDetails,
                      offersReceivedModel.id,
                      offersModel,
                      'New Message',
                      '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                      'chat');
                  ChatModel? newchat = await ChatController().getChat(
                      userController.userModel!.userId,
                      ownerDetails.userId,
                      offersModel.offerId);
                  OffersController().updateNotificationForOffers(
                      senderId: userController.userModel!.userId,
                      offerId: offersModel.offerId,
                      userId: userController.userModel!.userId,
                      offersReceived: offersReceivedModel.id,
                      checkByList: offersModel.checkByList,
                      isAdd: false,
                      notificationTitle: '',
                      notificationSubtitle: '');

                  Get.close(1);
                  Get.to(() => MessagePage(
                        chatModel: newchat!,
                        garageModel: garageModel,
                        offersModel: offersModel,
                        secondUser: ownerDetails,
                      ));
                } else {
                  OffersController().updateNotificationForOffers(
                      offerId: offersModel.offerId,
                      userId: userController.userModel!.userId,
                      isAdd: false,
                      offersReceived: offersReceivedModel.id,
                      senderId: userController.userModel!.userId,
                      checkByList: offersModel.checkByList,
                      notificationTitle: '',
                      notificationSubtitle: '');

                  await ChatController().updateChatRequestId(
                      chatModel.id, offersReceivedModel.id);
                  Get.close(1);

                  Get.to(() => MessagePage(
                        chatModel: chatModel,
                        secondUser: ownerDetails,
                        garageModel: garageModel,
                        offersModel: offersModel,
                      ));
                }
              },
              child: Container(
                height: 50,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/messenger.png',
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Chat',
                      style: TextStyle(
                        // color: userController.isDark ? Colors.white : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              OffersController().updateNotificationForOffers(
                  offerId: offersModel.offerId,
                  userId: userController.userModel!.userId,
                  isAdd: false,
                  offersReceived: offersReceivedModel.id,
                  checkByList: offersModel.checkByList,
                  senderId: userController.userModel!.userId,
                  notificationTitle: '',
                  notificationSubtitle: '');
              Get.to(() => ServiceRequestDetails(
                  offersModel: offersModel,
                  offersReceivedModel: offersReceivedModel));
            },
            child: Container(
              height: 50,
              width: chatId != null ? Get.width * 0.45 : Get.width * 0.35,
              decoration: BoxDecoration(
                color: userController.isDark ? Colors.white : primaryColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              ),
              child: Center(
                child: Text(
                  'See Details',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
