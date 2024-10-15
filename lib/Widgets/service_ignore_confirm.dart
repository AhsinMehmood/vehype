import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../const.dart';

class ServiceIgnoreConfirm extends StatelessWidget {
  const ServiceIgnoreConfirm({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.userModel,
  });

  final UserController userController;
  final OffersModel offersModel;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      onClosing: () {},
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      builder: (s) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: userController.isDark ? primaryColor : Colors.white,
          ),
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Are you sure you want to ignore this request?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.close(1);
                    await FirebaseFirestore.instance
                        .collection('offers')
                        .doc(offersModel.offerId)
                        .update({
                      'ignoredBy': FieldValue.arrayUnion([userModel.userId]),
                    });
                 
                    ChatModel? chatModel = await ChatController().getChat(
                        userModel.userId,
                        offersModel.ownerId,
                        offersModel.offerId);
                    if (chatModel != null) {
                      ChatController().updateChatToClose(
                          chatModel.id, 'The request was marked as ignore.');
                    }
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
                    'Confirm',
                    style: TextStyle(
                      fontSize: 17,
                      // fontFamily: 'Avenir',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    Get.close(1);
                  },
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor:
                  //       userController.isDark ? primaryColor : Colors.white,
                  //   elevation: 1.0,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(6),

                  //   ),

                  //   maximumSize: Size(Get.width * 0.6, 50),
                  //   minimumSize: Size(Get.width * 0.6, 50),
                  // ),
                  child: Container(
                    height: 50,
                    width: Get.width * 0.6,
                    decoration: BoxDecoration(
                        // color: userC
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
                          // fontFamily: 'Avenir',
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
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
      },
    );
  }
}
