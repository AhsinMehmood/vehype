import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';

class UndoIgnoreProvider extends StatelessWidget {
  const UndoIgnoreProvider({
    super.key,
    required this.offersModel,
    required this.userController,
  });

  final OffersModel offersModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        FirebaseFirestore.instance
            .collection('offers')
            .doc(offersModel.offerId)
            .update({
          'ignoredBy':
              FieldValue.arrayRemove([userController.userModel!.userId]),
        });
        ChatModel? chatModel = await ChatController().getChat(
            userController.userModel!.userId,
            offersModel.ownerId,
            offersModel.offerId);
        if (chatModel != null) {
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatModel.id)
              .update({
            'isClosed': false,
            'closeReason': '',
          });
        }
      },
      child: Container(
        width: Get.width * 0.9,
        height: 50,
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: userController.isDark ? Colors.white : primaryColor,
          borderRadius: BorderRadius.circular(6),
          // border: Border.all()
        ),
        child: Center(
          child: Text(
            'Undo Ignore',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: userController.isDark ? primaryColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
