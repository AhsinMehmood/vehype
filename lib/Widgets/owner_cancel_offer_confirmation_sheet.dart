import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/const.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';

class OwnerCancelOfferConfirmationSheet extends StatefulWidget {
  const OwnerCancelOfferConfirmationSheet({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.offersReceivedModel,
  });

  final UserController userController;
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;

  @override
  State<OwnerCancelOfferConfirmationSheet> createState() =>
      _OwnerCancelOfferConfirmationSheetState();
}

class _OwnerCancelOfferConfirmationSheetState
    extends State<OwnerCancelOfferConfirmationSheet> {
  final TextEditingController cancelReason = TextEditingController();
  bool isAgree = false;
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.9,
        ),
        builder: (s) {
          return Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: widget.userController.isDark ? primaryColor : Colors.white,
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
                    'The request will be marked as cancelled and moved to History.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cancellation Reason*',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    cursorColor: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    controller: cancelReason,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: widget.userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            )),
                        hintText: 'Explain the reason...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )

                        // counter: const SizedBox.shrink(),
                        ),
                    // initialValue: '',
                    maxLength: 256,

                    textCapitalization: TextCapitalization.sentences,

                    maxLines: 4,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      // color: changeColor(color: '7B7B7B'),
                      fontSize: 16,
                    ),
                    // maxLength: 25,
                    // onChanged: (String value) => editProfileProvider
                    //     .updateTexts(userModel, 'name', value),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isAgree = !isAgree;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.8,
                          child: Checkbox(
                              activeColor: widget.userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              checkColor: widget.userController.isDark
                                  ? Colors.green
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              value: isAgree,
                              onChanged: (s) {
                                setState(() {
                                  isAgree = !isAgree;
                                });
                              }),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'I acknowledge VEHYPE\'s ratings policy. ',
                                      style: TextStyle(
                                          fontFamily: 'Avenir',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: widget.userController.isDark
                                              ? Colors.white
                                              : primaryColor
                                          //  color: Colors.black,
                                          ),
                                    ),
                                    TextSpan(
                                      text: 'See how rating works',
                                      style: TextStyle(
                                        fontFamily: 'Avenir',
                                        decorationColor: Colors.blueAccent,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await launchUrl(Uri.parse(
                                              'https://vehype.com/help#'));
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (cancelReason.text.trim().isEmpty) {
                        toastification.show(
                            context: context,
                            type: ToastificationType.error,
                            title: Text(
                                'Please provide a reason to cancel the offer'),
                            autoCloseDuration: const Duration(seconds: 3));
                        return;
                      }
                      if (isAgree == false) {
                        toastification.show(
                            context: context,
                            type: ToastificationType.error,
                            title: Text(
                                'Acknowledge to our rating\'s policy to cancel the offer'),
                            autoCloseDuration: const Duration(seconds: 3));
                        return;
                      }
                      Get.close(1);
                      OffersController().cancelOfferByOwner(
                          widget.offersReceivedModel,
                          widget.offersModel,
                          widget.userController.userModel!.userId,
                          widget.offersReceivedModel.offerBy,
                          cancelReason.text.trim());
                      DocumentSnapshot<Map<String, dynamic>> ownerSnap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.offersReceivedModel.offerBy)
                              .get();

                      NotificationController().sendNotification(
                          userIds: [UserModel.fromJson(ownerSnap).userId],
                          offerId: widget.offersModel.offerId,
                          requestId: widget.offersReceivedModel.id,
                          title: 'Offer Cancelled',
                          subtitle:
                              '${widget.userController.userModel!.name} has cancelled the request. Click here to review.');

                      OffersController().updateNotificationForOffers(
                          offerId: widget.offersModel.offerId,
                          userId: widget.offersReceivedModel.offerBy,
                          senderId: widget.userController.userModel!.userId,
                          isAdd: true,
                          offersReceived: widget.offersReceivedModel.id,
                          checkByList: widget.offersModel.checkByList,
                          notificationTitle:
                              '${widget.userController.userModel!.name} has cancelled the request.',
                          notificationSubtitle:
                              '${widget.userController.userModel!.name} has cancelled the request. Click here to review.');

                      ChatModel? chatModel = await ChatController().getChat(
                          widget.userController.userModel!.userId,
                          widget.offersModel.ownerId,
                          widget.offersModel.offerId);
                      if (chatModel != null) {
                        ChatController().updateChatToClose(chatModel.id,
                            '${widget.userController.userModel!.name} has cancelled the request.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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
                      width: Get.width * 0.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.userController.isDark
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
