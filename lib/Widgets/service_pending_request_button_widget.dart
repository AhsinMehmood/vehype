import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/service_request_details.dart';

import '../Models/chat_model.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';

import '../Pages/message_page.dart';
import '../Pages/repair_page.dart';
import '../const.dart';
import 'loading_dialog.dart';
import 'select_date_and_price.dart';

class ServicePendingPageButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServicePendingPageButtonWidget(
      {super.key,
      required this.offersModel,
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
                                    'Are you sure? The vehicle owner will be notified, and they can still rate you.',
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
                                      Get.dialog(LoadingDialog(),
                                          barrierDismissible: false);

                                      await FirebaseFirestore.instance
                                          .collection('offersReceived')
                                          .doc(offersReceivedModel.id)
                                          .update({
                                        'status': 'Cancelled',
                                        'cancelBy': 'provider',
                                      });

                                      UserController().addToNotifications(
                                          userController.userModel!,
                                          offersReceivedModel.ownerId,
                                          'offer',
                                          offersReceivedModel.id,
                                          'Offer Update',
                                          '${userController.userModel!.name} Cancelled the Offer.');
                                      sendNotification(
                                          offersModel.ownerId,
                                          userController.userModel!.name,
                                          'Cancelled The Offer',
                                          'contents',
                                          offersReceivedModel.id,
                                          'offer',
                                          '');
                                      Get.close(2);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 1.0,
                                        maximumSize: Size(Get.width * 0.6, 50),
                                        minimumSize: Size(Get.width * 0.6, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        )),
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Avenir',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Get.close(1);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        elevation: 1.0,
                                        maximumSize: Size(Get.width * 0.6, 50),
                                        minimumSize: Size(Get.width * 0.6, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        )),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Avenir',
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
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
                        secondUser: ownerDetails,
                      ));
                } else {
                  await ChatController().updateChatRequestId(
                      chatModel.id, offersReceivedModel.id);
                  Get.close(1);

                  Get.to(() => MessagePage(
                        chatModel: chatModel,
                        secondUser: ownerDetails,
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
              DocumentSnapshot<Map<String, dynamic>> ownerSnap =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(offersModel.ownerId)
                      .get();
              Get.close(1);
              Get.to(() => SelectDateAndPrice(
                    offersModel: offersModel,
                    offersReceivedModel: offersReceivedModel,
                    ownerModel: UserModel.fromJson(ownerSnap),
                  ));
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
                  'Update Offer',
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

class ServicePendingRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServicePendingRequestButtonWidget(
      {super.key,
      required this.offersModel,
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
                                    'Are you sure? The vehicle owner will be notified, and they can still rate you.',
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
                                      Get.dialog(LoadingDialog(),
                                          barrierDismissible: false);

                                      await FirebaseFirestore.instance
                                          .collection('offersReceived')
                                          .doc(offersReceivedModel.id)
                                          .update({
                                        'status': 'Cancelled',
                                        'cancelBy': 'provider',
                                      });

                                      UserController().addToNotifications(
                                          userController.userModel!,
                                          offersReceivedModel.ownerId,
                                          'offer',
                                          offersReceivedModel.id,
                                          'Offer Update',
                                          '${userController.userModel!.name} Cancelled the Offer.');
                                      sendNotification(
                                          offersModel.ownerId,
                                          userController.userModel!.name,
                                          'Cancelled The Offer',
                                          'contents',
                                          offersReceivedModel.id,
                                          'offer',
                                          '');
                                      Get.close(2);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 1.0,
                                        maximumSize: Size(Get.width * 0.6, 50),
                                        minimumSize: Size(Get.width * 0.6, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        )),
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Avenir',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Get.close(1);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        elevation: 1.0,
                                        maximumSize: Size(Get.width * 0.6, 50),
                                        minimumSize: Size(Get.width * 0.6, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        )),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Avenir',
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
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
                        secondUser: ownerDetails,
                      ));
                } else {
                  await ChatController().updateChatRequestId(
                      chatModel.id, offersReceivedModel.id);
                  Get.close(1);

                  Get.to(() => MessagePage(
                        chatModel: chatModel,
                        secondUser: ownerDetails,
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
