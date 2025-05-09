import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/service_request_details.dart';

import '../Controllers/offers_controller.dart';
import '../Controllers/pdf_generator.dart';
import '../Models/offers_model.dart';

import '../Models/user_model.dart';
import '../Pages/Invoice/review_share_invoice.dart';
import '../const.dart';
import 'loading_dialog.dart';
import 'service_to_owner_rating_sheet.dart';

class ServiceCompletedRequestPageButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServiceCompletedRequestPageButtonWidget(
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
          if (offersReceivedModel.ratingTwo == 0.0)
            InkWell(
              onTap: () {
                Get.to(() => ServiceToOwnerRatingSheet(
                    offersReceivedModel: offersReceivedModel,
                    offersModel: offersModel,
                    isDark: userController.isDark));
              },
              child: Container(
                height: 50,
                width: Get.width * 0.42,
                decoration: BoxDecoration(
                  color: userController.isDark ? Colors.white : primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Feedback',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
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

              DocumentSnapshot<Map<String, dynamic>> serviceSnap =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(offersReceivedModel.offerBy)
                      .get();
              DocumentSnapshot<Map<String, dynamic>> ownerSnap =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(offersReceivedModel.ownerId)
                      .get();
              File? file = await PDFGenerator.createInvoicePDF(
                  offersReceivedModel: offersReceivedModel,
                  offersModel: offersModel,
                  onwerModel: UserModel.fromJson(ownerSnap),
                  isEmail: true,
                  currentUserEmail: userController.userModel!.email,
                  serviceModel: UserModel.fromJson(serviceSnap));
              Get.close(1);

              Get.to(() => ReviewShareInvoice(
                    pdfFile: file!,
                    invoiceNumber: offersReceivedModel.randomId,
                  ));
            },
            child: Container(
              height: 50,
              width: offersReceivedModel.ratingTwo == 0.0
                  ? Get.width * 0.42
                  : Get.width * 0.9,
              decoration: BoxDecoration(
                color: userController.isDark ? Colors.white : primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'View Invoice',
                  style: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCompletedRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServiceCompletedRequestButtonWidget(
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
          if (offersReceivedModel.ratingTwo == 0.0)
            InkWell(
              onTap: () {
                OffersController().updateNotificationForOffers(
                    offerId: offersModel.offerId,
                    userId: userController.userModel!.userId,
                    isAdd: false,
                    senderId: userController.userModel!.userId,
                    offersReceived: offersReceivedModel.id,
                    checkByList: offersModel.checkByList,
                    notificationTitle: '',
                    notificationSubtitle: '');
                Get.to(() => ServiceToOwnerRatingSheet(
                    offersReceivedModel: offersReceivedModel,
                    offersModel: offersModel,
                    isDark: userController.isDark));
              },
              child: Container(
                height: 50,
                width: Get.width * 0.43,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit Feedback',
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        // color: Colors.white,
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
                  senderId: userController.userModel!.userId,
                  isAdd: false,
                  notificationTitle: '',
                  checkByList: offersModel.checkByList,
                  offersReceived: offersReceivedModel.id,
                  notificationSubtitle: '');
              Get.to(() => ServiceRequestDetails(
                  offersModel: offersModel,
                  offersReceivedModel: offersReceivedModel));
            },
            child: Container(
              height: 50,
              width: offersReceivedModel.ratingTwo == 0.0
                  ? Get.width * 0.43
                  : Get.width * 0.88,
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
