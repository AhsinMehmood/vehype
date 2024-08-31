import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/notification_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';

class DeleteVehicleConfirmation extends StatefulWidget {
  final String chatId;
  const DeleteVehicleConfirmation({super.key, required this.chatId});

  @override
  State<DeleteVehicleConfirmation> createState() =>
      _DeleteVehicleConfirmationState();
}

class _DeleteVehicleConfirmationState extends State<DeleteVehicleConfirmation> {
  bool isAgree = false;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      padding: const EdgeInsets.all(15),
      width: Get.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: userController.isDark ? primaryColor : Colors.white),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Delete Vehicle',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Are you sure you want to delete this vehicle? All active and in-progress requests for this vehicle will be canceled, and service owners will be notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
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
                        activeColor:
                            userController.isDark ? Colors.white : primaryColor,
                        checkColor:
                            userController.isDark ? Colors.green : Colors.white,
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
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor
                                    //  color: Colors.black,
                                    ),
                              ),
                              TextSpan(
                                text: 'See how rating works',
                                style: TextStyle(
                                  decorationColor: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await launchUrl(
                                        Uri.parse('https://vehype.com/help#'));
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
                Get.close(1);
                Get.dialog(LoadingDialog(), barrierDismissible: false);
                if (isAgree == false) {
                  toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      title: Text(
                          'Acknowledge to our rating\'s policy to cancel the offer'),
                      autoCloseDuration: const Duration(seconds: 3));
                  return;
                }
                // Get.close(1);
                QuerySnapshot<Map<String, dynamic>> offersSnap =
                    await FirebaseFirestore.instance
                        .collection('offers')
                        .where('garageId', isEqualTo: widget.chatId)
                        .where('status',
                            whereIn: ['active', 'inProgress']).get();
                List<OffersModel> vehicleOffers = [];
                for (QueryDocumentSnapshot<Map<String, dynamic>> element
                    in offersSnap.docs) {
                  vehicleOffers.add(OffersModel.fromJson(element));
                }
                for (OffersModel offersModel in vehicleOffers) {
                  if (offersModel.status == 'active') {
                    QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
                        await FirebaseFirestore.instance
                            .collection('offersReceived')
                            .where('offerId', isEqualTo: offersModel.offerId)
                            .get();
                    for (var element in offersReceivedSnap.docs) {
                      await FirebaseFirestore.instance
                          .collection('offersReceived')
                          .doc(element.id)
                          .update({
                        'checkByList': [],
                        'status': 'Rejected',
                      });
                    }
                    await FirebaseFirestore.instance
                        .collection('offers')
                        .doc(offersModel.offerId)
                        .update({
                      'status': 'inactive',
                      'offersReceived': [],
                      'checkByList': [],
                    });
                  } else {
                    QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
                        await FirebaseFirestore.instance
                            .collection('offersReceived')
                            .where('offerId', isEqualTo: offersModel.offerId)
                            .get();
                    for (QueryDocumentSnapshot<Map<String, dynamic>> element
                        in offersReceivedSnap.docs) {
                      OffersReceivedModel offersReceivedModel =
                          OffersReceivedModel.fromJson(element);
                      OffersController().cancelOfferByOwner(
                          offersReceivedModel,
                          offersModel,
                          userController.userModel!.userId,
                          offersReceivedModel.offerBy,
                          'The request was automatically canceled.');
                      DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersReceivedModel.offerBy)
                              .get();
                      NotificationController().sendNotification(
                          userIds: [offerByQuery.id],
                          offerId: offersModel.offerId,
                          requestId: offersReceivedModel.id,
                          title: 'Offer Cancelled',
                          subtitle:
                              '${userController.userModel!.name} has cancelled the request. Click here to review.');
                      QuerySnapshot<Map<String, dynamic>> chatsSnap =
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .where('offerId', isEqualTo: offersModel.offerId)
                              .get();

                      for (var element in chatsSnap.docs) {
                        await ChatController().updateChatToClose(
                            element.id, 'The request has been deleted.');
                      }
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: offersReceivedModel.offerBy,
                          senderId: userController.userModel!.userId,
                          isAdd: true,
                          offersReceived: offersReceivedModel.id,
                          checkByList: offersModel.checkByList,
                          notificationTitle:
                              '${userController.userModel!.name} has cancelled the request.',
                          notificationSubtitle:
                              '${userController.userModel!.name} has cancelled the request. Tap to review.');
                    }
                  }
                }

                await FirebaseFirestore.instance
                    .collection('garages')
                    .doc(widget.chatId)
                    .update({
                  'ownerId': '',
                  'deleteId': userController.userModel!.userId,
                });

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
