import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Pages/service_request_details.dart';
import 'package:vehype/Widgets/service_ignore_confirm.dart';
import 'package:vehype/Widgets/undo_ignore_provider.dart';

import '../Controllers/offers_controller.dart';
import '../Models/chat_model.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../Pages/choose_account_type.dart';
import '../Pages/message_page.dart';
import '../const.dart';
import 'loading_dialog.dart';
import 'select_date_and_price.dart';

class ServiceNewRequestPageButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;

  final GarageModel garageModel;
  const ServiceNewRequestPageButtonWidget(
      {super.key,
      required this.offersModel,
      required this.garageModel,
      this.chatId});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return offersModel.ignoredBy.contains(userController.userModel!.userId)
        ? UndoIgnoreProvider(
            offersModel: offersModel, userController: userController)
        : Container(
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
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    if (userController.userModel!.email == 'No email set') {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Login to continue',
                        duration: const Duration(
                          seconds: 3,
                        ),
                        backgroundColor:
                            userController.isDark ? Colors.white : primaryColor,
                        mainButton: TextButton(
                          onPressed: () {
                            Get.to(() => ChooseAccountTypePage());
                            Get.closeCurrentSnackbar();
                          },
                          child: Text(
                            'Login Page',
                            style: TextStyle(
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ));
                    } else {
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: userController.userModel!.userId,
                          offersReceived: null,
                          checkByList: offersModel.checkByList,
                          isAdd: false,
                          senderId: userController.userModel!.userId,

                          notificationTitle: '',
                          notificationSubtitle: '');
                      showDialog(
                          context: context,
                          // backgroundColor: userController.isDark
                          //     ? primaryColor
                          //     : Colors.white,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.only(
                          //     topLeft: Radius.circular(22),
                          //     topRight: Radius.circular(22),
                          //   ),
                          // ),
                          builder: (context) {
                            return ServiceIgnoreConfirm(
                                userController: userController,
                                offersModel: offersModel,
                                userModel: userController.userModel!);
                          });
                    }
                  },
                  child: Container(
                    height: 50,
                    width: chatId != null ? Get.width * 0.35 : Get.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ignore',
                          style: TextStyle(
                            color: Colors.white,

                            // color: userController.isDark ? Colors.white : Colors.white,
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
                      DocumentSnapshot<Map<String, dynamic>> onwerSnap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersModel.ownerId)
                              .get();

                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: userController.userModel!.userId,
                          offersReceived: null,
                          isAdd: false,
                          senderId: userController.userModel!.userId,

                          checkByList: offersModel.checkByList,
                          notificationTitle: '',
                          notificationSubtitle: '');
                      UserModel ownerDetails = UserModel.fromJson(onwerSnap);
                      ChatModel? chatModel = await ChatController().getChat(
                          userController.userModel!.userId,
                          offersModel.ownerId,
                          offersModel.offerId);
                      if (chatModel == null) {
                        await ChatController().createChat(
                            userController.userModel!,
                            ownerDetails,
                            '',
                            offersModel,
                            'New Message',
                            '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                            'chat');
                        ChatModel? newchat = await ChatController().getChat(
                          userController.userModel!.userId,
                          offersModel.ownerId,
                          offersModel.offerId,
                        );
                        // ChatController(). updateOfferId(newchat!, userModel.userId);

                        Get.close(1);
                        Get.to(() => MessagePage(
                              chatModel: newchat!,
                              secondUser: ownerDetails,
                              offersModel: offersModel,
                              garageModel: garageModel,
                            ));
                      } else {
                        Get.close(1);

                        Get.to(() => MessagePage(
                              chatModel: chatModel,
                              garageModel: garageModel,
                              offersModel: offersModel,
                              secondUser: ownerDetails,
                            ));
                      }
                    },
                    child: Container(
                      height: 50,
                      width: Get.width * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/messenger.png',
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
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

                    OffersController().updateNotificationForOffers(
                        offerId: offersModel.offerId,
                        userId: userController.userModel!.userId,
                        offersReceived: null,
                        isAdd: false,
                        checkByList: offersModel.checkByList,
                          senderId: userController.userModel!.userId,

                        notificationTitle: '',
                        notificationSubtitle: '');
                    Get.close(1);
                    Get.to(() => SelectDateAndPrice(
                          offersModel: offersModel,
                          offersReceivedModel: null,
                          ownerModel: UserModel.fromJson(ownerSnap),
                        ));
                  },
                  child: Container(
                    height: 50,
                    width: chatId != null ? Get.width * 0.45 : Get.width * 0.35,
                    decoration: BoxDecoration(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Create Offer',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
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

class ServiceNewRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final GarageModel garageModel;

  const ServiceNewRequestButtonWidget(
      {super.key,
      required this.offersModel,
      this.chatId,
      required this.garageModel});

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
              if (userController.userModel!.email == 'No email set') {
                Get.showSnackbar(GetSnackBar(
                  message: 'Login to continue',
                  duration: const Duration(
                    seconds: 3,
                  ),
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  mainButton: TextButton(
                    onPressed: () {
                      Get.to(() => ChooseAccountTypePage());
                      Get.closeCurrentSnackbar();
                    },
                    child: Text(
                      'Login Page',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                      ),
                    ),
                  ),
                ));
              } else {
                OffersController().updateNotificationForOffers(
                    offerId: offersModel.offerId,
                    userId: userController.userModel!.userId,
                    offersReceived: null,
                          senderId: userController.userModel!.userId,

                    checkByList: offersModel.checkByList,
                    isAdd: false,
                    notificationTitle: '',
                    notificationSubtitle: '');
                Get.bottomSheet(
                  ServiceIgnoreConfirm(
                      userController: userController,
                      offersModel: offersModel,
                      userModel: userController.userModel!),
                  // backgroundColor: userController.isDark
                  //     ? primaryColor
                  //     : Colors.white,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(22),
                  //     topRight: Radius.circular(22),
                  //   ),
                  // ),
                  enableDrag: true,
                  // showDragHandle: true,
                );
              }
            },
            child: Container(
              height: 50,
              width: chatId != null ? Get.width * 0.35 : Get.width * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.red,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ignore',
                    style: TextStyle(
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
                DocumentSnapshot<Map<String, dynamic>> onwerSnap =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(offersModel.ownerId)
                        .get();
                UserModel ownerDetails = UserModel.fromJson(onwerSnap);

                OffersController().updateNotificationForOffers(
                    offerId: offersModel.offerId,
                    userId: userController.userModel!.userId,
                          senderId: userController.userModel!.userId,

                    isAdd: false,
                    notificationTitle: '',
                    checkByList: offersModel.checkByList,
                    offersReceived: null,
                    notificationSubtitle: '');
                ChatModel? chatModel = await ChatController().getChat(
                    userController.userModel!.userId,
                    offersModel.ownerId,
                    offersModel.offerId);
                if (chatModel == null) {
                  await ChatController().createChat(
                      userController.userModel!,
                      ownerDetails,
                      '',
                      offersModel,
                      'New Message',
                      '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                      'chat');
                  ChatModel? newchat = await ChatController().getChat(
                    userController.userModel!.userId,
                    offersModel.ownerId,
                    offersModel.offerId,
                  );
                  // ChatController(). updateOfferId(newchat!, userModel.userId);

                  Get.close(1);
                  Get.to(() => MessagePage(
                        chatModel: newchat!,
                        secondUser: ownerDetails,
                        garageModel: garageModel,
                        offersModel: offersModel,
                      ));
                } else {
                  Get.close(1);

                  Get.to(() => MessagePage(
                        chatModel: chatModel,
                        garageModel: garageModel,
                        offersModel: offersModel,
                        secondUser: ownerDetails,
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
                  offersReceived: null,
                  checkByList: offersModel.checkByList,
                          senderId: userController.userModel!.userId,

                  notificationTitle: '',
                  notificationSubtitle: '');
              Get.to(() => ServiceRequestDetails(
                  offersModel: offersModel, offersReceivedModel: null));
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
