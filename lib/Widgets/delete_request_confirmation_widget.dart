import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';

class DeleteRequestConfirmationWidget extends StatelessWidget {
  const DeleteRequestConfirmationWidget({
    super.key,
    required this.userController,
    required this.offersModel,
  });

  final UserController userController;
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
                    height: 10,
                  ),
                  Text(
                    'The request will be marked as deleted and moved to History.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.close(1);
                      QuerySnapshot<Map<String, dynamic>> chatsSnap =
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .where('offerId', isEqualTo: offersModel.offerId)
                              .get();

                      for (var element in chatsSnap.docs) {
                        await ChatController().updateChatToClose(
                            element.id, 'The request has been deleted.');
                      }
                      QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
                          await FirebaseFirestore.instance
                              .collection('offersReceived')
                              .where('offerId', isEqualTo: offersModel.offerId)
                              .get();
                      for (var element in offersReceivedSnap.docs) {
                        await FirebaseFirestore.instance
                            .collection('offersReceived')
                            .doc(element.id)
                            .update({'checkByList': [], 'status': 'Rejected'});
                      }
                      await FirebaseFirestore.instance
                          .collection('offers')
                          .doc(offersModel.offerId)
                          .update({
                        'status': 'inactive',
                        'offersReceived': [],
                        'checkByList': [],
                      });
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
