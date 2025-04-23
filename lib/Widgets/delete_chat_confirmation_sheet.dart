import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

class DeleteChatConfirmationSheet extends StatelessWidget {
  final String chatId;
  const DeleteChatConfirmationSheet({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: userController.isDark ? primaryColor : Colors.white),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Delete Chat',
              style: TextStyle(
                fontWeight: FontWeight.w800,
       
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Are you sure you want to delete this conversation?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                Get.close(1);
                Get.dialog(LoadingDialog(), barrierDismissible: false);
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .delete();
                Get.close(2);
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.6, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: userController.isDark ? primaryColor : Colors.white,
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
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
